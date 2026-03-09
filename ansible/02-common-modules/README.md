# Ansible + Incus 02: Common Modules

这一节基于 `01-quickstart` 已经准备好的 `node1` 和 `node2`，继续学习 Ansible 最常用的模块和幂等性。

## 目标

- 学会最常见的模块写法
- 通过重复执行 playbook 观察什么叫幂等性

## 文件

- `prepare.sh`：复制 `01-quickstart` 生成的 `inventory.yml`
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `common_modules.yml`：演示 `file`、`copy`、`apt`、`command`、`shell` 的示例 playbook

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `02-common-modules` 目录中执行。
如果你当前还在 `ansible/` 根目录，先执行：

```bash
cd 02-common-modules
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `01-quickstart/ping.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook common_modules.yml
```

如果你想观察幂等性，再执行一次同样的命令：

```bash
uv run ansible-playbook common_modules.yml
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook common_modules.yml` 可以成功执行
- 你能观察出第一次和第二次执行时 `changed` / `ok` 的差异
