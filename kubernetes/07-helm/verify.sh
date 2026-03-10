#!/usr/bin/env bash
set -euo pipefail

CHAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="$CHAPTER_DIR/web-demo"
VERIFY_NAMESPACE="${VERIFY_NAMESPACE:-helm-demo}"
RELEASE_NAME="${RELEASE_NAME:-web-demo}"

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: missing command: $cmd" >&2
    exit 1
  }
}

ensure_namespace_absent() {
  helm uninstall "$RELEASE_NAME" -n "$VERIFY_NAMESPACE" >/dev/null 2>&1 || true
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
  command -v helm >/dev/null 2>&1 && helm uninstall "$RELEASE_NAME" -n "$VERIFY_NAMESPACE" >/dev/null 2>&1 || true
  command -v kubectl >/dev/null 2>&1 && kubectl delete namespace "$VERIFY_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true
}

trap cleanup EXIT

require_cmd helm
require_cmd kubectl

ensure_namespace_absent

helm lint "$CHART_DIR" >/dev/null

rendered_output="$(helm template "$RELEASE_NAME" "$CHART_DIR" -f "$CHAPTER_DIR/values-dev.yaml")"
printf '%s\n' "$rendered_output" | grep -q 'kind: Deployment'
printf '%s\n' "$rendered_output" | grep -q 'kind: Service'
printf '%s\n' "$rendered_output" | grep -q 'replicas: 2'
printf '%s\n' "$rendered_output" | grep -q 'image: nginx:1.27-alpine'

helm upgrade --install "$RELEASE_NAME" "$CHART_DIR" -n "$VERIFY_NAMESPACE" --create-namespace >/dev/null
kubectl rollout status deployment/web-demo -n "$VERIFY_NAMESPACE" --timeout=180s >/dev/null
kubectl get service web-demo -n "$VERIFY_NAMESPACE" >/dev/null

helm upgrade "$RELEASE_NAME" "$CHART_DIR" -n "$VERIFY_NAMESPACE" -f "$CHAPTER_DIR/values-dev.yaml" >/dev/null
kubectl rollout status deployment/web-demo -n "$VERIFY_NAMESPACE" --timeout=180s >/dev/null

replica_count="$(kubectl get deployment web-demo -n "$VERIFY_NAMESPACE" -o jsonpath='{.spec.replicas}')"
[[ "$replica_count" == "2" ]] || {
  echo "ERROR: expected replicas=2 after upgrade, got $replica_count" >&2
  exit 1
}

image_name="$(kubectl get deployment web-demo -n "$VERIFY_NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].image}')"
[[ "$image_name" == "nginx:1.27-alpine" ]] || {
  echo "ERROR: expected image nginx:1.27-alpine after upgrade, got $image_name" >&2
  exit 1
}

helm_values="$(helm get values "$RELEASE_NAME" -n "$VERIFY_NAMESPACE")"
printf '%s\n' "$helm_values" | grep -q 'replicaCount: 2'
printf '%s\n' "$helm_values" | grep -q 'tag: 1.27-alpine'

echo "OK: helm lint, template, install, upgrade, and uninstall flow passed."
