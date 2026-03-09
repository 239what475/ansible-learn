# Ansible + Incus 28: Debugging and Troubleshooting

这一节建立在 `27-collections-and-galaxy` 的基础上，继续学习如何在控制端和被管理主机上排查问题。

## 文件

- `prepare.sh`：复制 `27-collections-and-galaxy` 的 inventory
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `debugging_and_troubleshooting.yml`：这一章的示例 playbook

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `28-debugging-and-troubleshooting` 目录中执行。
如果你当前还没有实际 inventory，可以先执行：

```bash
./prepare.sh
```

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook debugging_and_troubleshooting.yml
```

## 完成标准

跑完后，你应该能观察到：

- 控制端如何查看当前 inventory 图和单主机详情
- `debug: var=` 和 `debug: msg=` 的区别
- `register` 结果里常见字段如 `stdout`、`stderr`、`rc`
- `assert`、`type_debug`、`to_nice_yaml` 这些排错常用手段
