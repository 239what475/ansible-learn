# Ansible + Incus 26: Strategy and Failure Control

这一节建立在 `25-async-and-poll` 的基础上，继续学习 `strategy`、`any_errors_fatal` 和 `max_fail_percentage`。

## 文件

- `prepare.sh`：复制 `25-async-and-poll` 的 inventory
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `strategy_and_failure_control.yml`：这一章的示例 playbook

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `26-strategy-and-failure-control` 目录中执行。
如果你当前还没有实际 inventory，可以先执行：

```bash
./prepare.sh
```

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook strategy_and_failure_control.yml
```

## 可选演示

默认运行只演示 `linear` 和 `free` 两种策略。
两个“故意失败”的失败控制示例需要显式指定标签：

```bash
uv run ansible-playbook strategy_and_failure_control.yml --tags any_errors_fatal_demo
uv run ansible-playbook strategy_and_failure_control.yml --tags max_fail_percentage_demo
```

## 完成标准

跑完默认示例后，你应该能观察到：

- `linear` 下，较快主机也要等较慢主机完成当前任务，才能进入下一任务
- `free` 下，较快主机可以先进入下一任务
- `any_errors_fatal` 和 `max_fail_percentage` 这两个示例默认不会执行，需要显式带 tag 才会触发
