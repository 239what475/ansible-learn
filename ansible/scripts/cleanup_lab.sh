#!/usr/bin/env bash
set -euo pipefail

# 这个脚本只做一件事：删除教程里默认使用的 Incus 实验节点。
# 目前默认节点名固定为 node1 和 node2。

NODES=(node1 node2)

command -v incus >/dev/null 2>&1 || {
  echo "ERROR: 未找到 incus 命令" >&2
  exit 1
}

for node in "${NODES[@]}"; do
  if incus info "$node" >/dev/null 2>&1; then
    echo "==> 删除实例: $node"
    incus delete -f "$node"
  else
    echo "==> 跳过不存在的实例: $node"
  fi
done

echo "==> 清理完成"
