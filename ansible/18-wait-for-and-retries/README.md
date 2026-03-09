# Ansible + Incus 18: Wait For and Retries

这一节建立在 `17-archive-unarchive-fetch` 的基础上，继续学习 `wait_for`、`until`、`retries` 和 `delay`。

## 文件

- `prepare.sh`：复制 `17-archive-unarchive-fetch` 生成的 `inventory.yml`
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `wait_for_and_retries.yml`：这一章的示例 playbook

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `18-wait-for-and-retries` 目录中执行。
如果你当前还在 `ansible/` 根目录，先执行：

```bash
cd 18-wait-for-and-retries
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `17-archive-unarchive-fetch/prepare.sh`
- `17-archive-unarchive-fetch/archive_unarchive_fetch.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook wait_for_and_retries.yml
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook wait_for_and_retries.yml` 可以成功执行
- 你能看懂 `wait_for` 和 `until + retries + delay` 的区别
