#!/usr/bin/env bash
set -euo pipefail

CHAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTH_NAMESPACE="${AUTH_NAMESPACE:-auth-demo}"
SERVICEACCOUNT_NAME="viewer"

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: missing command: $cmd" >&2
    exit 1
  }
}

ensure_namespace_absent() {
  kubectl delete namespace "$AUTH_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true

  for _ in $(seq 1 60); do
    if ! kubectl get namespace "$AUTH_NAMESPACE" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done

  echo "ERROR: namespace $AUTH_NAMESPACE still exists after cleanup" >&2
  exit 1
}

cleanup() {
  kubectl delete namespace "$AUTH_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true
}

trap cleanup EXIT

require_cmd kubectl

ensure_namespace_absent
kubectl apply -f "$CHAPTER_DIR/auth-demo-namespace.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/viewer-serviceaccount.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/pod-reader-role.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/pod-reader-binding.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/viewer-check-pod.yaml" >/dev/null

kubectl wait -n "$AUTH_NAMESPACE" --for=condition=Ready pod/viewer-check --timeout=180s >/dev/null
kubectl get serviceaccount,role,rolebinding,pod -n "$AUTH_NAMESPACE" >/dev/null

pod_sa_name="$(kubectl get pod viewer-check -n "$AUTH_NAMESPACE" -o jsonpath='{.spec.serviceAccountName}')"
[[ "$pod_sa_name" == "$SERVICEACCOUNT_NAME" ]] || {
  echo "ERROR: expected serviceAccountName=$SERVICEACCOUNT_NAME, got $pod_sa_name" >&2
  exit 1
}

can_list_pods="$(kubectl auth can-i list pods -n "$AUTH_NAMESPACE" --as="system:serviceaccount:${AUTH_NAMESPACE}:${SERVICEACCOUNT_NAME}")"
[[ "$can_list_pods" == "yes" ]] || {
  echo "ERROR: expected pod list permission in $AUTH_NAMESPACE" >&2
  exit 1
}

can_get_secrets="$(kubectl auth can-i get secrets -n "$AUTH_NAMESPACE" --as="system:serviceaccount:${AUTH_NAMESPACE}:${SERVICEACCOUNT_NAME}" || true)"
[[ "$can_get_secrets" == "no" ]] || {
  echo "ERROR: expected no secret read permission in $AUTH_NAMESPACE" >&2
  exit 1
}

can_list_default_pods="$(kubectl auth can-i list pods -n default --as="system:serviceaccount:${AUTH_NAMESPACE}:${SERVICEACCOUNT_NAME}" || true)"
[[ "$can_list_default_pods" == "no" ]] || {
  echo "ERROR: expected no pod list permission in default namespace" >&2
  exit 1
}

projected_namespace="$(kubectl exec -n "$AUTH_NAMESPACE" viewer-check -- cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)"
[[ "$projected_namespace" == "$AUTH_NAMESPACE" ]] || {
  echo "ERROR: expected projected namespace $AUTH_NAMESPACE, got $projected_namespace" >&2
  exit 1
}

echo "OK: serviceaccount, role, rolebinding, and RBAC checks passed."
