#!/usr/bin/env bash
set -euo pipefail

CHAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY_NAMESPACE="${VERIFY_NAMESPACE:-chapter05-verify}"
TMP_DIR="$(mktemp -d)"
MINIKUBE_IP=""

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

render_manifest() {
  local src="$1"
  local dest="$2"

  sed \
    -e "s/name: edge-demo$/name: ${VERIFY_NAMESPACE}/" \
    -e "s/namespace: edge-demo/namespace: ${VERIFY_NAMESPACE}/g" \
    "$src" > "$dest"
}

cleanup() {
  kubectl delete namespace "$VERIFY_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

require_cmd kubectl
require_cmd minikube
require_cmd curl

minikube addons enable ingress >/dev/null
kubectl get ingressclass nginx >/dev/null
kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx --timeout=300s >/dev/null

ensure_namespace_absent
render_manifest "$CHAPTER_DIR/edge-demo-namespace.yaml" "$TMP_DIR/namespace.yaml"
render_manifest "$CHAPTER_DIR/data-demo-pvc.yaml" "$TMP_DIR/data-demo-pvc.yaml"
render_manifest "$CHAPTER_DIR/storage-demo-pod.yaml" "$TMP_DIR/storage-demo-pod.yaml"
render_manifest "$CHAPTER_DIR/web-demo-deployment.yaml" "$TMP_DIR/web-demo-deployment.yaml"
render_manifest "$CHAPTER_DIR/web-demo-service.yaml" "$TMP_DIR/web-demo-service.yaml"
render_manifest "$CHAPTER_DIR/web-demo-ingress.yaml" "$TMP_DIR/web-demo-ingress.yaml"

kubectl apply -f "$TMP_DIR/namespace.yaml" >/dev/null
kubectl apply -f "$TMP_DIR/data-demo-pvc.yaml" >/dev/null
kubectl wait -n "$VERIFY_NAMESPACE" --for=jsonpath='{.status.phase}'=Bound pvc/data-demo --timeout=180s >/dev/null

kubectl apply -f "$TMP_DIR/storage-demo-pod.yaml" >/dev/null
kubectl wait -n "$VERIFY_NAMESPACE" --for=condition=Ready pod/storage-demo --timeout=180s >/dev/null

storage_output="$(kubectl exec -n "$VERIFY_NAMESPACE" storage-demo -- sh -c 'ls -l /data && cat /data/hello.txt')"
printf '%s\n' "$storage_output" | grep -q 'storage-ok'

kubectl apply -f "$TMP_DIR/web-demo-deployment.yaml" >/dev/null
kubectl rollout status -n "$VERIFY_NAMESPACE" deployment/web-demo --timeout=180s >/dev/null
kubectl apply -f "$TMP_DIR/web-demo-service.yaml" >/dev/null
kubectl apply -f "$TMP_DIR/web-demo-ingress.yaml" >/dev/null

kubectl get ingress -n "$VERIFY_NAMESPACE" web-demo >/dev/null

MINIKUBE_IP="$(minikube ip)"

http_code=""
for _ in $(seq 1 30); do
  http_code="$(curl -sS -o /dev/null -w '%{http_code}' -H 'Host: web-demo.local' "http://${MINIKUBE_IP}" || true)"
  if [[ "$http_code" == "200" ]]; then
    break
  fi
  sleep 2
done

[[ "$http_code" == "200" ]] || {
  echo "ERROR: expected ingress HTTP 200, got ${http_code:-<empty>}" >&2
  exit 1
}

echo "OK: storage and ingress verification passed."
