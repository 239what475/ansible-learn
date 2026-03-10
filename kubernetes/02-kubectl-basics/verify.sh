#!/usr/bin/env bash
set -euo pipefail

VERIFY_POD_NAME="${VERIFY_POD_NAME:-demo-shell}"

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: missing command: $cmd" >&2
    exit 1
  }
}

ensure_pod_absent() {
  kubectl delete pod "$VERIFY_POD_NAME" --ignore-not-found >/dev/null 2>&1 || true

  for _ in $(seq 1 60); do
    if ! kubectl get pod "$VERIFY_POD_NAME" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done

  echo "ERROR: pod $VERIFY_POD_NAME still exists after cleanup" >&2
  exit 1
}

cleanup() {
  kubectl delete pod "$VERIFY_POD_NAME" --ignore-not-found >/dev/null 2>&1 || true
}

trap cleanup EXIT

require_cmd kubectl

ensure_pod_absent
kubectl run "$VERIFY_POD_NAME" \
  --image=busybox:1.36 \
  --restart=Never \
  -- sh -c 'while true; do echo demo-log; sleep 5; done' >/dev/null

kubectl wait --for=condition=Ready "pod/$VERIFY_POD_NAME" --timeout=180s >/dev/null
kubectl get pod "$VERIFY_POD_NAME" >/dev/null
kubectl describe pod "$VERIFY_POD_NAME" >/dev/null

logs_output="$(kubectl logs "$VERIFY_POD_NAME" --tail=5)"
printf '%s\n' "$logs_output" | grep -q 'demo-log'

exec_output="$(kubectl exec "$VERIFY_POD_NAME" -- sh -c 'echo inside-pod && pwd')"
printf '%s\n' "$exec_output" | grep -q 'inside-pod'

echo "OK: get/describe/logs/exec worked against pod/$VERIFY_POD_NAME."
