#!/usr/bin/env bash
set -euo pipefail

# 这个脚本不再创建容器，只复用 01-quickstart 已经准备好的节点信息。
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_INVENTORY="$SCRIPT_DIR/../01-quickstart/inventory.yml"
TARGET_INVENTORY="$SCRIPT_DIR/inventory.yml"

if [[ ! -f "$SOURCE_INVENTORY" ]]; then
  echo "ERROR: 未找到 $SOURCE_INVENTORY" >&2
  echo '请先完成 01-quickstart，并确保已经生成 inventory.yml。' >&2
  exit 1
fi

cp "$SOURCE_INVENTORY" "$TARGET_INVENTORY"

echo '==> 已复制 inventory.yml'
echo '==> 下一步执行：'
echo 'uv run ansible-playbook common_modules.yml'
