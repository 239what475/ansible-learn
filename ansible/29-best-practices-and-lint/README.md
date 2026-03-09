# Ansible + Incus 29: Best Practices and Lint

这一节建立在 `28-debugging-and-troubleshooting` 的基础上，继续学习常见编写规范、可读性习惯，以及 `ansible-lint` 这类静态检查工具在项目里的位置。

## 文件

- `prepare.sh`：复制 `28-debugging-and-troubleshooting` 的 inventory
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `best_practices_and_lint.yml`：这一章的主示例 playbook
- `sample_playbook.yml`：这一章专门拿来做 syntax-check、list-tasks、list-tags、lint 演示的示例 playbook

说明尽量写在 playbook、inventory、配置文件和示例文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `29-best-practices-and-lint` 目录中执行。
如果你当前还没有实际 inventory，可以先执行：

```bash
./prepare.sh
```

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook best_practices_and_lint.yml
```

## 完成标准

跑完后，你应该能观察到：

- 怎么在控制端对一个 playbook 做 `--syntax-check`
- 怎么看 `--list-tasks` 和 `--list-tags`
- 当前环境里有没有 `ansible-lint`
- `sample_playbook.yml` 里体现了哪些更容易维护的写法
