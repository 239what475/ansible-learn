#!/usr/bin/env bash
set -euo pipefail

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: missing command: $cmd" >&2
    exit 1
  }
}

require_cmd kubectl

kubectl get nodes >/dev/null
kubectl get pods -A -o wide >/dev/null
kubectl get svc -A >/dev/null

for pod_name in \
  kube-apiserver-minikube \
  etcd-minikube \
  kube-controller-manager-minikube \
  kube-scheduler-minikube
do
  kubectl get pod -n kube-system "$pod_name" >/dev/null
done

kubectl get svc -n default kubernetes >/dev/null
kubectl get svc -n kube-system kube-dns >/dev/null

echo "OK: control-plane components and core services are visible in the cluster."
