#!/usr/bin/env bash
set -euo pipefail

CHAIN="DOCKER-USER"
INCUS_BRIDGE="incusbr0"

ensure_rule() {
  local direction="$1"

  if sudo iptables -C "$CHAIN" "$direction" "$INCUS_BRIDGE" -j ACCEPT 2>/dev/null; then
    echo "==> 规则已存在：$CHAIN $direction $INCUS_BRIDGE -j ACCEPT"
  else
    echo "==> 添加规则：$CHAIN $direction $INCUS_BRIDGE -j ACCEPT"
    sudo iptables -I "$CHAIN" 1 "$direction" "$INCUS_BRIDGE" -j ACCEPT
  fi
}

command -v iptables >/dev/null 2>&1 || { echo 'ERROR: 未找到命令 iptables' >&2; exit 1; }
command -v ip >/dev/null 2>&1 || { echo 'ERROR: 未找到命令 ip' >&2; exit 1; }

if ! ip link show "$INCUS_BRIDGE" >/dev/null 2>&1; then
  echo "ERROR: 未找到网桥 $INCUS_BRIDGE" >&2
  echo '请先确认 Incus 已初始化，或者实际桥接名称不是 incusbr0。' >&2
  exit 1
fi

if ! sudo iptables -nL "$CHAIN" >/dev/null 2>&1; then
  echo "ERROR: 未找到 iptables 链 $CHAIN" >&2
  echo '这通常表示 Docker 还没有启动，或者当前环境没有 Docker 写入的防火墙规则。' >&2
  exit 1
fi

echo '==> 开始处理 Docker 与 Incus 的网络兼容规则'
ensure_rule -i
ensure_rule -o

echo '==> 完成'
echo "==> 现在来自 $INCUS_BRIDGE 的流量会在 $CHAIN 链中优先放行"
