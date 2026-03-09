# Ansible + Incus 04: Conditions, Loops and Templates

这一节建立在 `03-variables-and-facts` 的基础上，继续学习 `when`、`loop` 和 `template`。

## 文件

- `prepare.sh`：复制 `03-variables-and-facts` 生成的 `inventory.yml`
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `conditions_loops_templates.yml`：这一章的示例 playbook
- `templates/lesson_report.j2`：配合 `template` 模块使用的模板文件

说明尽量写在 playbook、template、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `04-conditions-loops-templates` 目录中执行。
如果你当前还在 `ansible/` 根目录，先执行：

```bash
cd 04-conditions-loops-templates
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `03-variables-and-facts/prepare.sh`
- `03-variables-and-facts/variables_and_facts.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook conditions_loops_templates.yml
```

如果你想先只观察一台主机，可以这样执行：

```bash
uv run ansible-playbook conditions_loops_templates.yml -l node1
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook conditions_loops_templates.yml` 可以成功执行
- 你能看懂 `when`、`loop`、`item`、`template` 和模板里的 Jinja 语法
