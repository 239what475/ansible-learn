# Ansible + Incus 09: Imports and Includes

这一节建立在 `08-tags-and-check-mode` 的基础上，继续学习 `import_tasks` 和 `include_tasks`。

## 文件

- `prepare.sh`：复制 `08-tags-and-check-mode` 生成的 `inventory.yml`
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `imports_and_includes.yml`：这一章的主 playbook
- `tasks/`：被主 playbook 拆分出去的任务文件

说明尽量写在 playbook、任务文件、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `09-imports-and-includes` 目录中执行。
如果你当前还在仓库根目录，先执行：

```bash
cd 09-imports-and-includes
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `08-tags-and-check-mode/prepare.sh`
- `08-tags-and-check-mode/tags_and_check_mode.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook imports_and_includes.yml
```

如果你只想看主 playbook 里有哪些任务会被静态导入，可以先做语法检查：

```bash
uv run ansible-playbook --syntax-check imports_and_includes.yml
```

如果你想临时关闭动态包含的那一段，可以这样执行：

```bash
uv run ansible-playbook imports_and_includes.yml -e '{"enable_dynamic_section": false}'
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook imports_and_includes.yml` 可以成功执行
- 你能看懂 `import_tasks` 和 `include_tasks` 的区别，以及为什么要把任务拆到多个文件里
