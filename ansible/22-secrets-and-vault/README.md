# Ansible + Incus 22: Secrets and Vault

这一节建立在 `21-synchronize-and-rsync` 的基础上，继续学习 `ansible-vault`、敏感变量和 `no_log`。

## 文件

- `prepare.sh`：复制 `21-synchronize-and-rsync` 生成的 `inventory.yml`
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `vault.yml.example`：本地明文变量模板，复制后再加密使用
- `.vault_pass.txt.example`：本地密码文件模板，复制后修改，不提交到 Git
- `secrets_and_vault.yml`：这一章的示例 playbook

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `22-secrets-and-vault` 目录中执行。
如果你当前还在 `ansible/` 根目录，先执行：

```bash
cd 22-secrets-and-vault
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `21-synchronize-and-rsync/prepare.sh`
- `21-synchronize-and-rsync/synchronize_and_rsync.yml`

## 快速开始

```bash
./prepare.sh
cp .vault_pass.txt.example .vault_pass.txt
cp vault.yml.example vault.yml
# 先按你自己的内容修改上面两个文件
uv run ansible-vault encrypt --encrypt-vault-id default vault.yml
uv run ansible-playbook secrets_and_vault.yml
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `vault.yml` 已经被 `ansible-vault encrypt` 加密
- `uv run ansible-playbook secrets_and_vault.yml` 可以成功执行
- 你能看懂 `vault` 和 `no_log` 的作用区别
