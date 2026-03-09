# Ansible + Incus 24: Handlers, Meta, and Flush

这一节建立在 `23-project-layout-and-environments` 的基础上，继续学习 handler、`notify` 和 `meta: flush_handlers`。

## 文件

- `prepare.sh`：复制 `23-project-layout-and-environments` 的 `dev` inventory
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `handlers_meta_and_flush.yml`：这一章的示例 playbook

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `24-handlers-meta-and-flush` 目录中执行。
如果你当前还在 `ansible/` 根目录，先执行：

```bash
cd 24-handlers-meta-and-flush
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `23-project-layout-and-environments/prepare.sh`
- `23-project-layout-and-environments/playbooks/site.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook handlers_meta_and_flush.yml
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook handlers_meta_and_flush.yml` 可以成功执行
- 你能看懂 handler 默认为什么延后执行，以及 `meta: flush_handlers` 为什么能提前触发它们
