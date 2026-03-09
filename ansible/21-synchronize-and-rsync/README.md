# Ansible + Incus 21: Synchronize and Rsync

这一节建立在 `20-cron-and-scheduled-tasks` 的基础上，继续学习 `ansible.posix.synchronize` 和 `rsync` 风格的文件同步。

## 文件

- `prepare.sh`：复制 `20-cron-and-scheduled-tasks` 生成的 `inventory.yml`
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `synchronize_and_rsync.yml`：这一章的示例 playbook
- `sync-src/`：控制端本地的示例源目录，运行时生成，不提交到 Git
- `sync-pulled/`：从远程主机拉回本地的目录，运行时生成，不提交到 Git

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `21-synchronize-and-rsync` 目录中执行。
如果你当前还在 `ansible/` 根目录，先执行：

```bash
cd 21-synchronize-and-rsync
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `20-cron-and-scheduled-tasks/prepare.sh`
- `20-cron-and-scheduled-tasks/cron_and_scheduled_tasks.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook synchronize_and_rsync.yml
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook synchronize_and_rsync.yml` 可以成功执行
- 你能看懂 `push`、`pull`、本地源目录和远程目标目录的区别
