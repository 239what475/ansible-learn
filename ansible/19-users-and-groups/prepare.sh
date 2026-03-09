#!/usr/bin/env bash
set -euo pipefail

# 这一章直接复用 18-wait-for-and-retries 已经准备好的 inventory。
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_INVENTORY="$SCRIPT_DIR/../18-wait-for-and-retries/inventory.yml"
TARGET_INVENTORY="$SCRIPT_DIR/inventory.yml"

if [[ ! -f "$SOURCE_INVENTORY" ]]; then
  echo "ERROR: 未找到 $SOURCE_INVENTORY" >&2
  echo '请先完成 18-wait-for-and-retries，并确保已经生成 inventory.yml。' >&2
  exit 1
fi

cp "$SOURCE_INVENTORY" "$TARGET_INVENTORY"

echo '==> 已复制 inventory.yml'
echo '==> 下一步执行：'
echo 'uv run ansible-playbook users_and_groups.yml'
