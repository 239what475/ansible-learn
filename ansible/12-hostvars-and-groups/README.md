# Ansible + Incus 12: Hostvars and Groups

这一节建立在 `11-serial-and-batches` 的基础上，继续学习 `groups`、`hostvars` 和 `set_fact`。

## 文件

- `prepare.sh`：复制 `11-serial-and-batches` 生成的 `inventory.yml`
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `hostvars_and_groups.yml`：这一章的示例 playbook
- `controller-output/`：运行时在控制端生成的本地输出目录，不提交到 Git

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `12-hostvars-and-groups` 目录中执行。
如果你当前还在 `ansible/` 根目录，先执行：

```bash
cd 12-hostvars-and-groups
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `11-serial-and-batches/prepare.sh`
- `11-serial-and-batches/serial_and_batches.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook hostvars_and_groups.yml
```

如果你只想先看 node1 上的局部输出：

```bash
uv run ansible-playbook hostvars_and_groups.yml -l node1
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook hostvars_and_groups.yml` 可以成功执行
- 你能看懂 `groups['incus_nodes']`、`hostvars['node1']` 和 `set_fact` 的作用
