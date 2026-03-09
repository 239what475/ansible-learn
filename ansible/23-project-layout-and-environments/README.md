# Ansible + Incus 23: Project Layout and Environments

这一节建立在 `22-secrets-and-vault` 的基础上，继续学习更真实的 Ansible 项目目录结构，以及 `dev` / `prod` 环境拆分。

## 文件

- `prepare.sh`：复制 `22-secrets-and-vault` 生成的 `inventory.yml` 到 `dev` / `prod`
- `ansible.cfg`：当前目录使用的 Ansible 配置，默认指向 `dev` 环境
- `inventories/dev/`：开发环境 inventory、`group_vars`、`host_vars`
- `inventories/prod/`：生产环境 inventory、`group_vars`、`host_vars`
- `playbooks/site.yml`：这一章的统一入口 playbook

说明尽量写在 playbook、inventory、`group_vars` 和 `host_vars` 的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `23-project-layout-and-environments` 目录中执行。
如果你当前还在仓库根目录，先执行：

```bash
cd 23-project-layout-and-environments
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `22-secrets-and-vault/prepare.sh`
- `22-secrets-and-vault/secrets_and_vault.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook playbooks/site.yml
uv run ansible-playbook -i inventories/prod/inventory.yml playbooks/site.yml
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- 默认运行时走 `dev` 环境
- 显式指定 `-i inventories/prod/inventory.yml` 时能切到 `prod`
- 你能看懂 inventory、`group_vars`、`host_vars` 在不同环境目录下是怎么配合工作的
