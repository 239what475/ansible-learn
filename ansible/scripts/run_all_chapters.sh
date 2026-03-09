#!/usr/bin/env bash
set -euo pipefail

# 这个脚本从 `ansible/` 根目录开始，顺序执行 01 ~ 30 的章节实验。
# 它的目的不是只做语法检查，而是尽量按用户平时学习时的方式，把每一章真正跑一遍。

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$ROOT/.." && pwd)"
ANSIBLE_PLAYBOOK_BIN="$REPO_ROOT/.venv/bin/ansible-playbook"
CLEANUP_BIN="$ROOT/scripts/cleanup_lab.sh"

LOG_FILE="${TMPDIR:-/tmp}/ansible_chapters_validate.log"
SUMMARY_FILE="${TMPDIR:-/tmp}/ansible_chapters_validate_summary.txt"

if [[ ! -x "$ANSIBLE_PLAYBOOK_BIN" ]]; then
  echo "ERROR: 未找到可执行的 ansible-playbook: $ANSIBLE_PLAYBOOK_BIN" >&2
  echo "请先在仓库根目录重建 .venv 并安装 Ansible。" >&2
  exit 1
fi

if [[ ! -x "$CLEANUP_BIN" ]]; then
  echo "ERROR: 未找到可执行的清理脚本: $CLEANUP_BIN" >&2
  exit 1
fi

: > "$LOG_FILE"
: > "$SUMMARY_FILE"

echo "[cleanup] reset incus lab nodes" >> "$SUMMARY_FILE"
(
  cd "$ROOT"
  "$CLEANUP_BIN"
) >> "$LOG_FILE" 2>&1

run_prepare() {
  local dir="$1"

  if [[ -x "$ROOT/$dir/prepare.sh" ]]; then
    echo "[prepare] $dir" >> "$SUMMARY_FILE"
    (
      cd "$ROOT/$dir"
      ./prepare.sh
    ) >> "$LOG_FILE" 2>&1
  fi
}

run_playbook() {
  local dir="$1"
  local playbook="$2"

  echo "[playbook] $dir :: $playbook" >> "$SUMMARY_FILE"
  (
    cd "$ROOT/$dir"
    "$ANSIBLE_PLAYBOOK_BIN" "$playbook"
  ) >> "$LOG_FILE" 2>&1
}

fail_count=0

run_dir() {
  local dir="$1"
  shift

  echo "=== $dir ===" >> "$SUMMARY_FILE"

  if ! run_prepare "$dir"; then
    echo "FAIL prepare :: $dir" >> "$SUMMARY_FILE"
    fail_count=$((fail_count + 1))
    return
  fi

  local playbook
  for playbook in "$@"; do
    if run_playbook "$dir" "$playbook"; then
      echo "OK   $dir :: $playbook" >> "$SUMMARY_FILE"
    else
      echo "FAIL $dir :: $playbook" >> "$SUMMARY_FILE"
      fail_count=$((fail_count + 1))
    fi
  done
}

run_dir 01-quickstart ping.yml install_common.yml
run_dir 02-common-modules common_modules.yml
run_dir 03-variables-and-facts variables_and_facts.yml
run_dir 04-conditions-loops-templates conditions_loops_templates.yml
run_dir 05-group-vars-and-host-vars group_host_vars.yml
run_dir 06-roles roles_demo.yml
run_dir 07-blocks-and-error-handling blocks_and_error_handling.yml
run_dir 08-tags-and-check-mode tags_and_check_mode.yml
run_dir 09-imports-and-includes imports_and_includes.yml
run_dir 10-delegation-and-run-once delegation_and_run_once.yml
run_dir 11-serial-and-batches serial_and_batches.yml
run_dir 12-hostvars-and-groups hostvars_and_groups.yml
run_dir 13-asserts-and-validation asserts_and_validation.yml
run_dir 14-become-and-privilege-escalation become_and_privilege_escalation.yml
run_dir 15-services-and-systemd services_and_systemd.yml
run_dir 16-lineinfile-blockinfile-replace editing_config_files.yml
run_dir 17-archive-unarchive-fetch archive_unarchive_fetch.yml
run_dir 18-wait-for-and-retries wait_for_and_retries.yml
run_dir 19-users-and-groups users_and_groups.yml
run_dir 20-cron-and-scheduled-tasks cron_and_scheduled_tasks.yml
run_dir 21-synchronize-and-rsync synchronize_and_rsync.yml
run_dir 22-secrets-and-vault secrets_and_vault.yml
run_dir 23-project-layout-and-environments playbooks/site.yml
run_dir 24-handlers-meta-and-flush handlers_meta_and_flush.yml
run_dir 25-async-and-poll async_and_poll.yml
run_dir 26-strategy-and-failure-control strategy_and_failure_control.yml
run_dir 27-collections-and-galaxy collections_and_galaxy.yml
run_dir 28-debugging-and-troubleshooting debugging_and_troubleshooting.yml
run_dir 29-best-practices-and-lint best_practices_and_lint.yml
run_dir 30-mini-project-node-bootstrap site.yml

echo "---" >> "$SUMMARY_FILE"
echo "fail_count=$fail_count" >> "$SUMMARY_FILE"

cat "$SUMMARY_FILE"

if [[ "$fail_count" -ne 0 ]]; then
  echo "--- LAST 200 LOG LINES ---"
  tail -n 200 "$LOG_FILE"
  exit 1
fi
