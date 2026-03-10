#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

LOG_FILE="${TMPDIR:-/tmp}/kubernetes_chapters_validate.log"
SUMMARY_FILE="${TMPDIR:-/tmp}/kubernetes_chapters_validate_summary.txt"

: > "$LOG_FILE"
: > "$SUMMARY_FILE"

run_chapter() {
  local dir="$1"

  echo "=== $dir ===" >> "$SUMMARY_FILE"

  if (
    cd "$ROOT/$dir"
    ./verify.sh
  ) >> "$LOG_FILE" 2>&1; then
    echo "OK   $dir" >> "$SUMMARY_FILE"
  else
    echo "FAIL $dir" >> "$SUMMARY_FILE"
    return 1
  fi
}

fail_count=0

for dir in \
  00-prestart \
  01-architecture-and-core-concepts \
  02-kubectl-basics \
  03-workloads-and-services \
  04-configmap-secret-namespace \
  05-ingress-and-storage \
  06-rbac-and-serviceaccount \
  07-helm
do
  if ! run_chapter "$dir"; then
    fail_count=$((fail_count + 1))
  fi
done

echo "---" >> "$SUMMARY_FILE"
echo "fail_count=$fail_count" >> "$SUMMARY_FILE"

cat "$SUMMARY_FILE"

if [[ "$fail_count" -ne 0 ]]; then
  echo "--- LAST 200 LOG LINES ---"
  tail -n 200 "$LOG_FILE"
  exit 1
fi
