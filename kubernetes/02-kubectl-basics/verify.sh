#!/usr/bin/env bash
set -euo pipefail

VERIFY_NAMESPACE="${VERIFY_NAMESPACE:-chapter02-verify}"
VERIFY_POD_NAME="${VERIFY_POD_NAME:-demo-shell}"

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
kubectl run "$VERIFY_POD_NAME" -n "$VERIFY_NAMESPACE" \
  --image=busybox:1.36 \
  --restart=Never \
  -- sh -c 'while true; do echo demo-log; sleep 5; done' >/dev/null

kubectl wait -n "$VERIFY_NAMESPACE" --for=condition=Ready "pod/$VERIFY_POD_NAME" --timeout=180s >/dev/null
kubectl get pod "$VERIFY_POD_NAME" -n "$VERIFY_NAMESPACE" >/dev/null
kubectl describe pod "$VERIFY_POD_NAME" -n "$VERIFY_NAMESPACE" >/dev/null

logs_output="$(kubectl logs -n "$VERIFY_NAMESPACE" "$VERIFY_POD_NAME" --tail=5)"
printf '%s\n' "$logs_output" | grep -q 'demo-log'

exec_output="$(kubectl exec -n "$VERIFY_NAMESPACE" "$VERIFY_POD_NAME" -- sh -c 'echo inside-pod && pwd')"
printf '%s\n' "$exec_output" | grep -q 'inside-pod'

echo "OK: get/describe/logs/exec worked against $VERIFY_NAMESPACE/$VERIFY_POD_NAME."
