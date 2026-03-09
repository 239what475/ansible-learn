# Ansible + Incus 16: Editing Config Files

这一节建立在 `15-services-and-systemd` 的基础上，继续学习 `lineinfile`、`blockinfile` 和 `replace`。

## 文件

- `prepare.sh`：复制 `15-services-and-systemd` 生成的 `inventory.yml`
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `editing_config_files.yml`：这一章的示例 playbook

说明尽量写在 playbook、inventory 和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `16-lineinfile-blockinfile-replace` 目录中执行。
如果你当前还在 `ansible/` 根目录，先执行：

```bash
cd 16-lineinfile-blockinfile-replace
```

这一节默认你已经完成：

- `01-quickstart/prepare.sh`
- `15-services-and-systemd/prepare.sh`
- `15-services-and-systemd/services_and_systemd.yml`

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook editing_config_files.yml
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook editing_config_files.yml` 可以成功执行
- 你能看懂 `lineinfile`、`blockinfile`、`replace` 的区别，以及什么时候该用哪一个
