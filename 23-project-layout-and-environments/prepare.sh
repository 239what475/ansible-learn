#!/usr/bin/env bash
set -euo pipefail

# 这一章直接复用 22-secrets-and-vault 已经准备好的 inventory。
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_INVENTORY="$SCRIPT_DIR/../22-secrets-and-vault/inventory.yml"
DEV_INVENTORY="$SCRIPT_DIR/inventories/dev/inventory.yml"
PROD_INVENTORY="$SCRIPT_DIR/inventories/prod/inventory.yml"

if [[ ! -f "$SOURCE_INVENTORY" ]]; then
  echo "ERROR: 未找到 $SOURCE_INVENTORY" >&2
  echo '请先完成 22-secrets-and-vault，并确保已经生成 inventory.yml。' >&2
  exit 1
fi

cp "$SOURCE_INVENTORY" "$DEV_INVENTORY"
cp "$SOURCE_INVENTORY" "$PROD_INVENTORY"

echo '==> 已复制 inventories/dev/inventory.yml'
echo '==> 已复制 inventories/prod/inventory.yml'
echo '==> 下一步执行：'
echo 'uv run ansible-playbook playbooks/site.yml'
echo 'uv run ansible-playbook -i inventories/prod/inventory.yml playbooks/site.yml'
