#!/usr/bin/env bash
set -euo pipefail

CHAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: missing command: $cmd" >&2
    exit 1
  }
}

delete_chapter_resources() {
  kubectl delete service/web-demo --ignore-not-found >/dev/null 2>&1 || true
  kubectl delete deployment/web-demo --ignore-not-found >/dev/null 2>&1 || true
  kubectl delete pod/pod-demo --ignore-not-found >/dev/null 2>&1 || true
}

ensure_resources_absent() {
  delete_chapter_resources

  for _ in $(seq 1 60); do
    if ! kubectl get service web-demo >/dev/null 2>&1 \
      && ! kubectl get deployment web-demo >/dev/null 2>&1 \
      && ! kubectl get pod pod-demo >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done

  echo "ERROR: chapter 03 resources still exist after cleanup" >&2
  exit 1
}

cleanup() {
  delete_chapter_resources
}

trap cleanup EXIT

require_cmd kubectl

ensure_resources_absent

kubectl apply -f "$CHAPTER_DIR/pod-demo.yaml" >/dev/null
kubectl wait --for=condition=Ready pod/pod-demo --timeout=180s >/dev/null

kubectl apply -f "$CHAPTER_DIR/web-demo-deployment.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/web-demo-service.yaml" >/dev/null
kubectl rollout status deployment/web-demo --timeout=180s >/dev/null
kubectl get deployment,service,pod -o wide >/dev/null
kubectl describe service web-demo >/dev/null

kubectl scale deployment/web-demo --replicas=3 >/dev/null
kubectl rollout status deployment/web-demo --timeout=180s >/dev/null

pod_count="$(kubectl get pods -l app=web-demo --no-headers | wc -l | tr -d ' ')"
[[ "$pod_count" -eq 3 ]] || {
  echo "ERROR: expected 3 web-demo pods after scale, got $pod_count" >&2
  exit 1
}

kubectl set image deployment/web-demo nginx=nginx:1.27-alpine >/dev/null
kubectl rollout status deployment/web-demo --timeout=180s >/dev/null

image_name="$(kubectl get deployment web-demo -o jsonpath='{.spec.template.spec.containers[0].image}')"
[[ "$image_name" == "nginx:1.27-alpine" ]] || {
  echo "ERROR: unexpected image after rollout: $image_name" >&2
  exit 1
}

echo "OK: pod, deployment, service, scale, and rollout verification passed."
