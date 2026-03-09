# Ansible + Incus 10: Delegation and Run Once

这一节建立在 `09-imports-and-includes` 的基础上，继续学习 `delegate_to` 和 `run_once`。

## 文件

- `prepare.sh`：复制 `09-imports-and-includes` 生成的 `inventory.yml`
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `delegation_and_run_once.yml`：这一章的示例 playbook
- `controller-output/`：运行时在控制端生成的本地输出目录，不提交到 Git

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `10-delegation-and-run-once` 目录中执行。
如果你当前还在 `ansible/` 根目录，先执行：

```bash
cd 10-delegation-and-run-once
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `09-imports-and-includes/prepare.sh`
- `09-imports-and-includes/imports_and_includes.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook delegation_and_run_once.yml
```

你也可以只先观察一台主机：

```bash
uv run ansible-playbook delegation_and_run_once.yml -l node1
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook delegation_and_run_once.yml` 可以成功执行
- 你能看懂 `run_once`、`delegate_to: localhost`，以及它们组合起来的作用
