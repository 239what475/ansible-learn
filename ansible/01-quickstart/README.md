# Ansible + Incus 01: Quickstart

这一节的目标很简单：

- 准备两台 `Incus` 练习节点
- 通过 `SSH` 让 `Ansible` 能连上它们
- 跑通最小的 `ping` 和安装软件包示例

## 文件

- `prepare.sh`：主流程脚本，负责准备这一节的实验环境
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `ping.yml`：最小连通性验证 playbook
- `install_common.yml`：安装常用软件包的示例 playbook
- `ansible.cfg`：当前目录使用的 Ansible 配置

说明尽量写在脚本和配置文件的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `01-quickstart` 目录中执行。
如果你当前还在 `ansible/` 根目录，先执行：

```bash
cd 01-quickstart
```

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook ping.yml
uv run ansible-playbook install_common.yml
```

如果你已经激活了 `.venv`，也可以直接使用：

```bash
ansible-playbook ping.yml
ansible-playbook install_common.yml
```

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook ping.yml` 成功返回 `ok`
- `uv run ansible-playbook install_common.yml` 成功执行
