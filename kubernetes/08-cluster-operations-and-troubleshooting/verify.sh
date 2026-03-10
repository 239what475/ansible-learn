#!/usr/bin/env bash
set -euo pipefail

CHAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPS_NAMESPACE="${OPS_NAMESPACE:-ops-demo}"
GOOD_IMAGE="nginx:1.27"
BAD_IMAGE="nginx:does-not-exist"

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: missing command: $cmd" >&2
    exit 1
  }
}

ensure_namespace_absent() {
  kubectl delete namespace "$OPS_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true

  for _ in $(seq 1 60); do
    if ! kubectl get namespace "$OPS_NAMESPACE" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done

  echo "ERROR: namespace $OPS_NAMESPACE still exists after cleanup" >&2
  exit 1
}

cleanup() {
  kubectl delete namespace "$OPS_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true
}

trap cleanup EXIT

require_cmd kubectl

ensure_namespace_absent
kubectl apply -f "$CHAPTER_DIR/ops-demo-namespace.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/web-demo-deployment.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/web-demo-service.yaml" >/dev/null
kubectl rollout status deployment/web-demo -n "$OPS_NAMESPACE" --timeout=180s >/dev/null

kubectl get nodes >/dev/null
kubectl get deployment,replicaset,pod,service -n "$OPS_NAMESPACE" -o wide >/dev/null
kubectl describe deployment web-demo -n "$OPS_NAMESPACE" >/dev/null

healthy_pod="$(kubectl get pod -n "$OPS_NAMESPACE" -l app=web-demo -o jsonpath='{.items[0].metadata.name}')"
kubectl describe pod "$healthy_pod" -n "$OPS_NAMESPACE" >/dev/null
kubectl logs "$healthy_pod" -n "$OPS_NAMESPACE" --tail=20 >/dev/null
kubectl rollout history deployment/web-demo -n "$OPS_NAMESPACE" >/dev/null

kubectl set image deployment/web-demo -n "$OPS_NAMESPACE" nginx="$BAD_IMAGE" >/dev/null
kubectl rollout status deployment/web-demo -n "$OPS_NAMESPACE" --timeout=30s >/dev/null 2>&1 || true

reasons="$(kubectl get pods -n "$OPS_NAMESPACE" -l app=web-demo -o jsonpath='{range .items[*]}{.status.containerStatuses[0].state.waiting.reason}{"\n"}{end}')"
printf '%s\n' "$reasons" | grep -Eq 'ErrImagePull|ImagePullBackOff'

failing_pod="$(kubectl get pods -n "$OPS_NAMESPACE" -l app=web-demo -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.containerStatuses[0].state.waiting.reason}{"\n"}{end}' | awk '$2 ~ /ErrImagePull|ImagePullBackOff/ {print $1; exit}')"
[[ -n "$failing_pod" ]] || {
  echo "ERROR: expected a failing pod after broken rollout" >&2
  exit 1
}

kubectl describe pod "$failing_pod" -n "$OPS_NAMESPACE" >/dev/null
kubectl get events -n "$OPS_NAMESPACE" --sort-by=.metadata.creationTimestamp >/dev/null

kubectl rollout undo deployment/web-demo -n "$OPS_NAMESPACE" >/dev/null
kubectl rollout status deployment/web-demo -n "$OPS_NAMESPACE" --timeout=180s >/dev/null

current_image="$(kubectl get deployment web-demo -n "$OPS_NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].image}')"
[[ "$current_image" == "$GOOD_IMAGE" ]] || {
  echo "ERROR: expected image $GOOD_IMAGE after rollback, got $current_image" >&2
  exit 1
}

echo "OK: observe, diagnose, and rollback flow passed."
