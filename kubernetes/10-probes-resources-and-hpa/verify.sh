#!/usr/bin/env bash
set -euo pipefail

CHAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_NAMESPACE="${RUNTIME_NAMESPACE:-runtime-demo}"

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: missing command: $cmd" >&2
    exit 1
  }
}

ensure_namespace_absent() {
  kubectl delete namespace "$RUNTIME_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true

  for _ in $(seq 1 60); do
    if ! kubectl get namespace "$RUNTIME_NAMESPACE" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done

  echo "ERROR: namespace $RUNTIME_NAMESPACE still exists after cleanup" >&2
  exit 1
}

wait_for_metrics() {
  for _ in $(seq 1 60); do
    if kubectl top nodes >/dev/null 2>&1; then
      return 0
    fi
    sleep 5
  done

  echo "ERROR: metrics API did not become available in time" >&2
  exit 1
}

ensure_metrics_server_ready() {
  if kubectl rollout status deployment/metrics-server -n kube-system --timeout=180s >/dev/null 2>&1; then
    return 0
  fi

  # 某些环境里 addon 已启用，但 Pod 可能因为镜像引用问题卡在拉取阶段。
  kubectl set image deployment/metrics-server -n kube-system metrics-server=registry.k8s.io/metrics-server/metrics-server:v0.8.1 >/dev/null
  kubectl rollout status deployment/metrics-server -n kube-system --timeout=180s >/dev/null
}

wait_for_hpa_metrics() {
  for _ in $(seq 1 60); do
    current_utilization="$(kubectl get hpa cpu-burner -n "$RUNTIME_NAMESPACE" -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}' 2>/dev/null || true)"
    if [[ "$current_utilization" =~ ^[0-9]+$ ]]; then
      return 0
    fi
    sleep 5
  done

  echo "ERROR: HPA metrics did not become available in time" >&2
  exit 1
}

wait_for_scale_up() {
  for _ in $(seq 1 60); do
    desired_replicas="$(kubectl get hpa cpu-burner -n "$RUNTIME_NAMESPACE" -o jsonpath='{.status.desiredReplicas}' 2>/dev/null || true)"
    available_replicas="$(kubectl get deployment cpu-burner -n "$RUNTIME_NAMESPACE" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"

    if [[ "${desired_replicas:-0}" =~ ^[0-9]+$ ]] && [[ "${available_replicas:-0}" =~ ^[0-9]+$ ]]; then
      if [[ "$desired_replicas" -ge 2 && "$available_replicas" -ge 2 ]]; then
        return 0
      fi
    fi
    sleep 5
  done

  echo "ERROR: cpu-burner did not scale above 1 replica in time" >&2
  exit 1
}

cleanup() {
  command -v kubectl >/dev/null 2>&1 && kubectl delete namespace "$RUNTIME_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true
}

trap cleanup EXIT

require_cmd kubectl
require_cmd minikube

minikube addons enable metrics-server >/dev/null
ensure_metrics_server_ready
wait_for_metrics

ensure_namespace_absent
kubectl apply -f "$CHAPTER_DIR/runtime-demo-namespace.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/probe-web-deployment.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/probe-web-service.yaml" >/dev/null
kubectl rollout status deployment/probe-web -n "$RUNTIME_NAMESPACE" --timeout=240s >/dev/null
kubectl get deployment,service,pod -n "$RUNTIME_NAMESPACE" >/dev/null

startup_path="$(kubectl get deployment probe-web -n "$RUNTIME_NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].startupProbe.httpGet.path}')"
[[ "$startup_path" == "/" ]] || {
  echo "ERROR: expected startupProbe path /, got $startup_path" >&2
  exit 1
}

readiness_path="$(kubectl get deployment probe-web -n "$RUNTIME_NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}')"
[[ "$readiness_path" == "/" ]] || {
  echo "ERROR: expected readinessProbe path /, got $readiness_path" >&2
  exit 1
}

liveness_path="$(kubectl get deployment probe-web -n "$RUNTIME_NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}')"
[[ "$liveness_path" == "/" ]] || {
  echo "ERROR: expected livenessProbe path /, got $liveness_path" >&2
  exit 1
}

cpu_request="$(kubectl get deployment probe-web -n "$RUNTIME_NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')"
[[ "$cpu_request" == "100m" ]] || {
  echo "ERROR: expected probe-web cpu request 100m, got $cpu_request" >&2
  exit 1
}

memory_limit="$(kubectl get deployment probe-web -n "$RUNTIME_NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}')"
[[ "$memory_limit" == "128Mi" ]] || {
  echo "ERROR: expected probe-web memory limit 128Mi, got $memory_limit" >&2
  exit 1
}

kubectl apply -f "$CHAPTER_DIR/cpu-burner-deployment.yaml" >/dev/null
kubectl apply -f "$CHAPTER_DIR/cpu-burner-hpa.yaml" >/dev/null
kubectl rollout status deployment/cpu-burner -n "$RUNTIME_NAMESPACE" --timeout=180s >/dev/null
wait_for_hpa_metrics
wait_for_scale_up

max_replicas="$(kubectl get hpa cpu-burner -n "$RUNTIME_NAMESPACE" -o jsonpath='{.spec.maxReplicas}')"
[[ "$max_replicas" == "4" ]] || {
  echo "ERROR: expected HPA maxReplicas 4, got $max_replicas" >&2
  exit 1
}

current_target="$(kubectl get hpa cpu-burner -n "$RUNTIME_NAMESPACE" -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}')"
[[ "$current_target" =~ ^[0-9]+$ ]] || {
  echo "ERROR: expected numeric HPA utilization target, got $current_target" >&2
  exit 1
}

echo "OK: probes, resources, metrics-server, and HPA verification passed."
