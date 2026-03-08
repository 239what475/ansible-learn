# Ansible + Incus 25: Async and Poll

这一节建立在 `24-handlers-meta-and-flush` 的基础上，继续学习异步任务、`poll` 和 `async_status`。

## 文件

- `prepare.sh`：复制 `24-handlers-meta-and-flush` 的 inventory
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `async_and_poll.yml`：这一章的示例 playbook

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `25-async-and-poll` 目录中执行。
如果你当前还没有实际 inventory，可以先执行：

```bash
./prepare.sh
```

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook async_and_poll.yml
```

## 完成标准

跑完后，你应该能观察到：

- `poll: 1` 的任务虽然是 async，但 Ansible 仍然会等待它完成
- `poll: 0` 的任务会立刻返回 `ansible_job_id`
- `async_status` 会按轮询方式检查后台任务是否完成
- `mode: cleanup` 会清理远程的异步状态缓存文件
