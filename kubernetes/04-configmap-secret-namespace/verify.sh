#!/usr/bin/env bash
set -euo pipefail

CHAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY_NAMESPACE="${VERIFY_NAMESPACE:-chapter04-verify}"
TMP_DIR="$(mktemp -d)"

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
    -e "s/name: app-demo$/name: ${VERIFY_NAMESPACE}/" \
    -e "s/namespace: app-demo/namespace: ${VERIFY_NAMESPACE}/g" \
    "$src" > "$dest"
}

cleanup() {
  kubectl delete namespace "$VERIFY_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

require_cmd kubectl

ensure_namespace_absent
render_manifest "$CHAPTER_DIR/app-demo-namespace.yaml" "$TMP_DIR/namespace.yaml"
render_manifest "$CHAPTER_DIR/app-config.yaml" "$TMP_DIR/app-config.yaml"
render_manifest "$CHAPTER_DIR/app-secret.yaml" "$TMP_DIR/app-secret.yaml"
render_manifest "$CHAPTER_DIR/env-demo-deployment.yaml" "$TMP_DIR/env-demo-deployment.yaml"

kubectl apply -f "$TMP_DIR/namespace.yaml" >/dev/null
kubectl apply -f "$TMP_DIR/app-config.yaml" >/dev/null
kubectl apply -f "$TMP_DIR/app-secret.yaml" >/dev/null
kubectl apply -f "$TMP_DIR/env-demo-deployment.yaml" >/dev/null

kubectl rollout status -n "$VERIFY_NAMESPACE" deployment/env-demo --timeout=180s >/dev/null
kubectl get configmap,secret,deployment,pod -n "$VERIFY_NAMESPACE" >/dev/null

exec_output="$(kubectl exec -n "$VERIFY_NAMESPACE" deployment/env-demo -- sh -c 'echo APP_MODE=$APP_MODE APP_COLOR=$APP_COLOR DB_USER=$DB_USER DB_PASS=$DB_PASS')"
printf '%s\n' "$exec_output" | grep -q 'APP_MODE=demo'
printf '%s\n' "$exec_output" | grep -q 'APP_COLOR=blue'
printf '%s\n' "$exec_output" | grep -q 'DB_USER=demo'
printf '%s\n' "$exec_output" | grep -q 'DB_PASS=s3cr3t'

echo "OK: namespace, configmap, secret, and env-driven deployment verification passed."
