# Ansible + Incus 08: Tags and Check Mode

这一节建立在 `07-blocks-and-error-handling` 的基础上，继续学习 `tags`、`--tags`、`--skip-tags`、`--check` 和 `--diff`。

## 文件

- `prepare.sh`：复制 `07-blocks-and-error-handling` 生成的 `inventory.yml`
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `tags_and_check_mode.yml`：这一章的示例 playbook

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `08-tags-and-check-mode` 目录中执行。
如果你当前还在仓库根目录，先执行：

```bash
cd 08-tags-and-check-mode
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `07-blocks-and-error-handling/prepare.sh`
- `07-blocks-and-error-handling/blocks_and_error_handling.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook tags_and_check_mode.yml
```

只运行带 `config` 标签的任务：

```bash
uv run ansible-playbook tags_and_check_mode.yml --tags config
```

跳过带 `report` 标签的任务：

```bash
uv run ansible-playbook tags_and_check_mode.yml --skip-tags report
```

预演改动但不真正落地：

```bash
uv run ansible-playbook tags_and_check_mode.yml --check
```

连同文件差异一起看：

```bash
uv run ansible-playbook tags_and_check_mode.yml --check --diff
```

如果前一次已经执行过、文件内容没有变化，`--diff` 可能不会显示任何差异。
想强制观察差异，可以临时覆盖变量：

```bash
uv run ansible-playbook tags_and_check_mode.yml --check --diff -e demo_message='preview-message'
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook tags_and_check_mode.yml` 可以成功执行
- 你能看懂 `tags`、`--tags`、`--skip-tags`、`--check` 和 `--diff` 的作用
