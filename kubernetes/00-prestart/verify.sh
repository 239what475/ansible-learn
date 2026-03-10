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
require_cmd minikube
require_cmd docker

docker ps >/dev/null
kubectl version --client >/dev/null
minikube version >/dev/null
minikube status >/dev/null

nodes_output="$(kubectl get nodes --no-headers)"
node_count="$(printf '%s\n' "$nodes_output" | sed '/^$/d' | wc -l | tr -d ' ')"
ready_count="$(printf '%s\n' "$nodes_output" | awk '$2 == "Ready" {count++} END {print count + 0}')"
control_plane_count="$(printf '%s\n' "$nodes_output" | awk '$3 ~ /control-plane/ {count++} END {print count + 0}')"

[[ "$node_count" -eq 3 ]] || {
  echo "ERROR: expected 3 nodes, got $node_count" >&2
  exit 1
}

[[ "$ready_count" -eq 3 ]] || {
  echo "ERROR: expected 3 Ready nodes, got $ready_count" >&2
  exit 1
}

[[ "$control_plane_count" -eq 1 ]] || {
  echo "ERROR: expected 1 control-plane node, got $control_plane_count" >&2
  exit 1
}

echo "OK: kubectl/minikube are available and the 3-node cluster is healthy."
