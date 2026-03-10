#!/usr/bin/env bash
set -euo pipefail

CHAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY_NAMESPACE="${VERIFY_NAMESPACE:-chapter03-verify}"

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: missing command: $cmd" >&2
    exit 1
  }
}

ensure_namespace_absent() {
  kubectl delete namespace "$VERIFY_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true

  for _ in $(seq 1 60); do
    if ! kubectl get namespace "$VERIFY_NAMESPACE" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done

  echo "ERROR: namespace $VERIFY_NAMESPACE still exists after cleanup" >&2
  exit 1
}

cleanup() {
  kubectl delete namespace "$VERIFY_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true
}

trap cleanup EXIT

require_cmd kubectl

ensure_namespace_absent
kubectl create namespace "$VERIFY_NAMESPACE" >/dev/null

kubectl apply -n "$VERIFY_NAMESPACE" -f "$CHAPTER_DIR/pod-demo.yaml" >/dev/null
kubectl wait -n "$VERIFY_NAMESPACE" --for=condition=Ready pod/pod-demo --timeout=180s >/dev/null

kubectl apply -n "$VERIFY_NAMESPACE" -f "$CHAPTER_DIR/web-demo-deployment.yaml" >/dev/null
kubectl apply -n "$VERIFY_NAMESPACE" -f "$CHAPTER_DIR/web-demo-service.yaml" >/dev/null
kubectl rollout status -n "$VERIFY_NAMESPACE" deployment/web-demo --timeout=180s >/dev/null
kubectl get deployment,service,pod -n "$VERIFY_NAMESPACE" -o wide >/dev/null
kubectl describe service web-demo -n "$VERIFY_NAMESPACE" >/dev/null

kubectl scale -n "$VERIFY_NAMESPACE" deployment/web-demo --replicas=3 >/dev/null
kubectl rollout status -n "$VERIFY_NAMESPACE" deployment/web-demo --timeout=180s >/dev/null

pod_count="$(kubectl get pods -n "$VERIFY_NAMESPACE" -l app=web-demo --no-headers | wc -l | tr -d ' ')"
[[ "$pod_count" -eq 3 ]] || {
  echo "ERROR: expected 3 web-demo pods after scale, got $pod_count" >&2
  exit 1
}

kubectl set image -n "$VERIFY_NAMESPACE" deployment/web-demo nginx=nginx:1.27-alpine >/dev/null
kubectl rollout status -n "$VERIFY_NAMESPACE" deployment/web-demo --timeout=180s >/dev/null

image_name="$(kubectl get deployment web-demo -n "$VERIFY_NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].image}')"
[[ "$image_name" == "nginx:1.27-alpine" ]] || {
  echo "ERROR: unexpected image after rollout: $image_name" >&2
  exit 1
}

echo "OK: pod, deployment, service, scale, and rollout verification passed."
