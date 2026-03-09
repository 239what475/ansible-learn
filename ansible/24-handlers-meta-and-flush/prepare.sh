#!/usr/bin/env bash
set -euo pipefail

# 这一章直接复用 23-project-layout-and-environments 的 dev inventory。
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_INVENTORY="$SCRIPT_DIR/../23-project-layout-and-environments/inventories/dev/inventory.yml"
TARGET_INVENTORY="$SCRIPT_DIR/inventory.yml"

if [[ ! -f "$SOURCE_INVENTORY" ]]; then
  echo "ERROR: 未找到 $SOURCE_INVENTORY" >&2
  echo '请先完成 23-project-layout-and-environments，并确保已经生成 dev inventory。' >&2
  exit 1
fi

cp "$SOURCE_INVENTORY" "$TARGET_INVENTORY"

echo '==> 已复制 inventory.yml'
echo '==> 下一步执行：'
echo 'uv run ansible-playbook handlers_meta_and_flush.yml'
