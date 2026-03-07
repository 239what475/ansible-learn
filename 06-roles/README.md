# Ansible + Incus 06: Roles

这一节建立在 `05-group-vars-and-host-vars` 的基础上，继续学习 `role` 的基本结构和使用方式。

## 文件

- `prepare.sh`：复制 `05-group-vars-and-host-vars` 生成的 `inventory.yml`
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `roles_demo.yml`：这一章的示例 playbook
- `roles/`：这一章的 role 目录

说明尽量写在 playbook、role 文件、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `06-roles` 目录中执行。
如果你当前还在仓库根目录，先执行：

```bash
cd 06-roles
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `05-group-vars-and-host-vars/prepare.sh`
- `05-group-vars-and-host-vars/group_host_vars.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook roles_demo.yml
```

如果你想先只观察一台主机，可以这样执行：

```bash
uv run ansible-playbook roles_demo.yml -l node1
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook roles_demo.yml` 可以成功执行
- 你能看懂 role 的目录结构，以及 `defaults`、`tasks`、`handlers`、`templates` 的分工
