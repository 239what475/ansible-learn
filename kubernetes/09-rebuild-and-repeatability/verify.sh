#!/usr/bin/env bash
set -euo pipefail

CHAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_NAMESPACE="${MAIN_NAMESPACE:-repeat-demo}"
PROFILE_NAME="${PROFILE_NAME:-repeat-verify}"
ORIGINAL_CONTEXT=""

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: missing command: $cmd" >&2
    exit 1
  }
}

mkctl() {
  minikube -p "$PROFILE_NAME" kubectl -- "$@"
}

restore_original_context() {
  if [[ -n "$ORIGINAL_CONTEXT" ]]; then
    kubectl config use-context "$ORIGINAL_CONTEXT" >/dev/null 2>&1 || true
  fi
}

ensure_main_namespace_absent() {
  kubectl delete namespace "$MAIN_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true

  for _ in $(seq 1 60); do
    if ! kubectl get namespace "$MAIN_NAMESPACE" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done

  echo "ERROR: namespace $MAIN_NAMESPACE still exists after cleanup" >&2
  exit 1
}

ensure_profile_absent() {
  minikube delete -p "$PROFILE_NAME" >/dev/null 2>&1 || true
}

cleanup() {
  restore_original_context
  command -v kubectl >/dev/null 2>&1 && kubectl delete namespace "$MAIN_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true
  command -v minikube >/dev/null 2>&1 && minikube delete -p "$PROFILE_NAME" >/dev/null 2>&1 || true
  restore_original_context
}

trap cleanup EXIT

require_cmd kubectl
require_cmd minikube

ORIGINAL_CONTEXT="$(kubectl config current-context 2>/dev/null || true)"
if [[ -z "$ORIGINAL_CONTEXT" ]]; then
  ORIGINAL_CONTEXT="$(kubectl config get-contexts -o name 2>/dev/null | head -n 1 || true)"
fi

ensure_main_namespace_absent
kubectl apply -f "$CHAPTER_DIR/repeat-demo-namespace.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/repeat-web-deployment.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/repeat-web-service.yaml" >/dev/null
kubectl rollout status deployment/repeat-web -n "$MAIN_NAMESPACE" --timeout=180s >/dev/null
kubectl get deployment,service,pod -n "$MAIN_NAMESPACE" >/dev/null

ensure_main_namespace_absent
kubectl apply -f "$CHAPTER_DIR/repeat-demo-namespace.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/repeat-web-deployment.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/repeat-web-service.yaml" >/dev/null
kubectl rollout status deployment/repeat-web -n "$MAIN_NAMESPACE" --timeout=180s >/dev/null

ensure_profile_absent
minikube start -p "$PROFILE_NAME" --nodes 1 >/dev/null
minikube -p "$PROFILE_NAME" status >/dev/null

mkctl apply -f "$CHAPTER_DIR/repeat-demo-namespace.yaml" >/dev/null
mkctl apply -f "$CHAPTER_DIR/repeat-web-deployment.yaml" >/dev/null
mkctl apply -f "$CHAPTER_DIR/repeat-web-service.yaml" >/dev/null
mkctl rollout status deployment/repeat-web -n "$MAIN_NAMESPACE" --timeout=180s >/dev/null
mkctl get deployment,service,pod -n "$MAIN_NAMESPACE" >/dev/null

minikube delete -p "$PROFILE_NAME" >/dev/null
minikube start -p "$PROFILE_NAME" --nodes 1 >/dev/null
minikube -p "$PROFILE_NAME" status >/dev/null

mkctl apply -f "$CHAPTER_DIR/repeat-demo-namespace.yaml" >/dev/null
mkctl apply -f "$CHAPTER_DIR/repeat-web-deployment.yaml" >/dev/null
mkctl apply -f "$CHAPTER_DIR/repeat-web-service.yaml" >/dev/null
mkctl rollout status deployment/repeat-web -n "$MAIN_NAMESPACE" --timeout=180s >/dev/null

replica_count="$(mkctl get deployment repeat-web -n "$MAIN_NAMESPACE" -o jsonpath='{.spec.replicas}')"
[[ "$replica_count" == "1" ]] || {
  echo "ERROR: expected replicas=1 after profile rebuild, got $replica_count" >&2
  exit 1
}

service_type="$(mkctl get service repeat-web -n "$MAIN_NAMESPACE" -o jsonpath='{.spec.type}')"
[[ "$service_type" == "ClusterIP" ]] || {
  echo "ERROR: expected service type ClusterIP after profile rebuild, got $service_type" >&2
  exit 1
}

echo "OK: repeat apply and profile rebuild flow passed."
