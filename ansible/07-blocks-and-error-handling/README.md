# Ansible + Incus 07: Blocks and Error Handling

这一节建立在 `06-roles` 的基础上，继续学习 `failed_when`、`ignore_errors`、`block`、`rescue` 和 `always`。

## 文件

- `prepare.sh`：复制 `06-roles` 生成的 `inventory.yml`
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `blocks_and_error_handling.yml`：这一章的示例 playbook

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `07-blocks-and-error-handling` 目录中执行。
如果你当前还在 `ansible/` 根目录，先执行：

```bash
cd 07-blocks-and-error-handling
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `06-roles/prepare.sh`
- `06-roles/roles_demo.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook blocks_and_error_handling.yml
```

如果你想先只观察一台主机，可以这样执行：

```bash
uv run ansible-playbook blocks_and_error_handling.yml -l node1
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook blocks_and_error_handling.yml` 可以成功执行
- 你能看懂 `failed_when`、`ignore_errors`、`block`、`rescue` 和 `always` 的作用
