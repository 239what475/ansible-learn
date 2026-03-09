#!/usr/bin/env bash
set -euo pipefail

# 这个脚本从 `terraform/` 根目录开始，顺序执行 01 ~ 10 的章节实验。
# 目标是尽量按平时学习时的方式，把每一章真正跑一遍，而不是只做语法检查。

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$ROOT/.." && pwd)"
ANSIBLE_PLAYBOOK_BIN="$REPO_ROOT/.venv/bin/ansible-playbook"

LOG_FILE="${TMPDIR:-/tmp}/terraform_chapters_validate.log"
SUMMARY_FILE="${TMPDIR:-/tmp}/terraform_chapters_validate_summary.txt"

if ! command -v terraform >/dev/null 2>&1; then
  echo "ERROR: 未找到 terraform，请先完成 terraform/00-prestart。" >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: 未找到 docker，请先安装并启动 Docker。" >&2
  exit 1
fi

if [[ ! -x "$ANSIBLE_PLAYBOOK_BIN" ]]; then
  echo "ERROR: 未找到可执行的 ansible-playbook: $ANSIBLE_PLAYBOOK_BIN" >&2
  echo "请先在仓库根目录重建 .venv 并安装 Ansible。" >&2
  exit 1
fi

: > "$LOG_FILE"
: > "$SUMMARY_FILE"

run_in_dir() {
  local dir="$1"
  shift

  (
    cd "$ROOT/$dir"
    bash -lc "$*"
  ) >> "$LOG_FILE" 2>&1
}

record_step() {
  local kind="$1"
  local dir="$2"
  local detail="$3"
  echo "[$kind] $dir :: $detail" >> "$SUMMARY_FILE"
}

cleanup_chapter() {
  local dir="$1"

  if run_in_dir "$dir" "terraform init -input=false >/dev/null && terraform destroy -auto-approve >/dev/null"; then
    record_step "cleanup" "$dir" "destroy"
  else
    record_step "cleanup" "$dir" "skip"
  fi
}

run_step() {
  local dir="$1"
  local label="$2"
  local cmd="$3"

  record_step "step" "$dir" "$label"
  run_in_dir "$dir" "$cmd"
}

fail_count=0

run_chapter() {
  local dir="$1"
  shift

  echo "=== $dir ===" >> "$SUMMARY_FILE"
  cleanup_chapter "$dir"

  local step
  for step in "$@"; do
    local label="${step%%:::*}"
    local cmd="${step#*:::}"

    if run_step "$dir" "$label" "$cmd"; then
      echo "OK   $dir :: $label" >> "$SUMMARY_FILE"
    else
      echo "FAIL $dir :: $label" >> "$SUMMARY_FILE"
      fail_count=$((fail_count + 1))
      return
    fi
  done
}

run_chapter "01-init-plan-apply-destroy" \
  "init:::terraform init" \
  "fmt:::terraform fmt" \
  "validate:::terraform validate" \
  "plan:::terraform plan -out=chapter01.tfplan" \
  "show-plan:::terraform show chapter01.tfplan | sed -n '1,180p'" \
  "apply:::terraform apply -auto-approve chapter01.tfplan" \
  "output:::terraform output" \
  "docker-ps:::docker ps --filter name=hello-terraform" \
  "destroy:::terraform destroy -auto-approve"

run_chapter "02-resources-and-providers" \
  "init:::terraform init" \
  "fmt:::terraform fmt" \
  "validate:::terraform validate" \
  "plan:::terraform plan -out=chapter02.tfplan" \
  "show-plan:::terraform show chapter02.tfplan | sed -n '1,200p'" \
  "apply:::terraform apply -auto-approve chapter02.tfplan" \
  "state-list:::terraform state list" \
  "docker-ps:::docker ps --filter name=terraform-resource-demo" \
  "destroy:::terraform destroy -auto-approve"

run_chapter "03-variables-outputs-locals" \
  "init:::terraform init" \
  "fmt:::terraform fmt" \
  "validate:::terraform validate" \
  "plan:::terraform plan -out=chapter03.tfplan -var-file=terraform.tfvars.example" \
  "show-plan:::terraform show chapter03.tfplan | sed -n '1,220p'" \
  "apply:::terraform apply -auto-approve chapter03.tfplan" \
  "output:::terraform output" \
  "docker-ps:::docker ps --filter name=terraform-demo-from-tfvars-test" \
  "destroy:::terraform destroy -auto-approve"

run_chapter "04-functions-and-expressions" \
  "init:::terraform init" \
  "fmt:::terraform fmt" \
  "validate:::terraform validate" \
  "plan:::terraform plan -out=chapter04.tfplan" \
  "show-plan:::terraform show chapter04.tfplan | sed -n '1,220p'" \
  "apply:::terraform apply -auto-approve chapter04.tfplan" \
  "output:::terraform output" \
  "docker-ps:::docker ps --filter name=terraform-functions-from-defaults-test-demo" \
  "destroy:::terraform destroy -auto-approve"

run_chapter "05-state-and-lifecycle" \
  "init:::terraform init" \
  "fmt:::terraform fmt" \
  "validate:::terraform validate" \
  "apply-default:::terraform apply -auto-approve" \
  "show-state:::terraform show | sed -n '1,220p'" \
  "plan-ignore-changes:::terraform plan -var='container_message=changed outside of lifecycle' | sed -n '1,160p'" \
  "plan-replacement:::terraform plan -var='environment_name=blue' -var='published_port=18086' | sed -n '1,220p'" \
  "destroy:::terraform destroy -auto-approve"

run_chapter "06-data-sources-and-dependencies" \
  "init:::terraform init" \
  "fmt:::terraform fmt" \
  "validate:::terraform validate" \
  "plan:::terraform plan -out=chapter06.tfplan" \
  "show-plan:::terraform show chapter06.tfplan | sed -n '1,220p'" \
  "apply:::terraform apply -auto-approve chapter06.tfplan" \
  "state-list:::terraform state list" \
  "output:::terraform output" \
  "docker-ps:::docker ps --filter name=terraform-data-demo" \
  "destroy:::terraform destroy -auto-approve"

run_chapter "07-modules" \
  "init:::terraform init" \
  "fmt:::terraform fmt -recursive" \
  "validate:::terraform validate" \
  "plan:::terraform plan -out=chapter07.tfplan" \
  "show-plan:::terraform show chapter07.tfplan | sed -n '1,240p'" \
  "apply:::terraform apply -auto-approve chapter07.tfplan" \
  "output:::terraform output" \
  "docker-ps:::docker ps --filter name=terraform-module-demo-dev" \
  "destroy:::terraform destroy -auto-approve"

run_chapter "08-environments-and-tfvars" \
  "init:::terraform init" \
  "fmt:::terraform fmt" \
  "validate:::terraform validate" \
  "plan-dev:::terraform plan -out=dev.tfplan -var-file=environments/dev.tfvars.example" \
  "show-dev:::terraform show dev.tfplan | sed -n '1,220p'" \
  "apply-dev:::terraform apply -auto-approve dev.tfplan" \
  "output-dev:::terraform output" \
  "docker-ps-dev:::docker ps --filter name=terraform-env-demo-dev" \
  "destroy-dev:::terraform destroy -auto-approve" \
  "plan-prod:::terraform plan -out=prod.tfplan -var-file=environments/prod.tfvars.example" \
  "show-prod:::terraform show prod.tfplan | sed -n '1,220p'" \
  "apply-prod:::terraform apply -auto-approve prod.tfplan" \
  "output-prod:::terraform output" \
  "docker-ps-prod:::docker ps --filter name=terraform-env-demo-prod" \
  "destroy-prod:::terraform destroy -auto-approve"

run_chapter "09-mini-project" \
  "init:::terraform init" \
  "fmt:::terraform fmt -recursive" \
  "validate:::terraform validate" \
  "plan-dev:::terraform plan -out=dev.tfplan -var-file=environments/dev.tfvars.example" \
  "show-dev:::terraform show dev.tfplan | sed -n '1,260p'" \
  "apply-dev:::terraform apply -auto-approve dev.tfplan" \
  "output-dev:::terraform output" \
  "docker-ps-dev:::docker ps --filter name=terraform-mini-site-dev" \
  "inspect-dev:::docker exec terraform-mini-site-dev sh -lc 'sed -n \"1,120p\" /usr/share/nginx/html/index.html'" \
  "destroy-dev:::terraform destroy -auto-approve" \
  "plan-prod:::terraform plan -out=prod.tfplan -var-file=environments/prod.tfvars.example" \
  "show-prod:::terraform show prod.tfplan | sed -n '1,260p'" \
  "apply-prod:::terraform apply -auto-approve prod.tfplan" \
  "output-prod:::terraform output" \
  "docker-ps-prod:::docker ps --filter name=terraform-mini-site-prod" \
  "inspect-prod:::docker exec terraform-mini-site-prod sh -lc 'sed -n \"1,120p\" /usr/share/nginx/html/index.html'" \
  "destroy-prod:::terraform destroy -auto-approve"

run_chapter "10-terraform-and-ansible" \
  "init:::terraform init" \
  "fmt:::terraform fmt" \
  "validate:::terraform validate" \
  "plan:::terraform plan -out=chapter10.tfplan -var-file=terraform.tfvars.example" \
  "show-plan:::terraform show chapter10.tfplan | sed -n '1,260p'" \
  "apply:::terraform apply -auto-approve chapter10.tfplan" \
  "output:::terraform output" \
  "show-inventory:::sed -n '1,40p' generated/inventory.yml" \
  "show-vars:::sed -n '1,80p' generated/terraform_vars.yml" \
  "docker-ps:::docker ps --filter name=terraform-ansible-demo-dev" \
  "inspect-site:::docker exec terraform-ansible-demo-dev sh -lc 'sed -n \"1,120p\" /usr/share/nginx/html/index.html'" \
  "ansible-handoff:::cd ansible && \"$ANSIBLE_PLAYBOOK_BIN\" playbooks/consume_terraform.yml" \
  "show-report:::sed -n '1,80p' generated/ansible_report.yml" \
  "destroy:::terraform destroy -auto-approve"

echo "---" >> "$SUMMARY_FILE"
echo "fail_count=$fail_count" >> "$SUMMARY_FILE"

cat "$SUMMARY_FILE"

if [[ "$fail_count" -ne 0 ]]; then
  echo "--- LAST 200 LOG LINES ---"
  tail -n 200 "$LOG_FILE"
  exit 1
fi
