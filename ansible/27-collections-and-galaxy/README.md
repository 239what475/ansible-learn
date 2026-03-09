# Ansible + Incus 27: Collections and Galaxy

这一节建立在 `26-strategy-and-failure-control` 的基础上，继续学习 collection、FQCN、`requirements.yml` 和 `ansible-galaxy`。

## 文件

- `prepare.sh`：复制 `26-strategy-and-failure-control` 的 inventory
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `requirements.yml`：本章示例依赖的 collections 列表
- `collections_and_galaxy.yml`：这一章的示例 playbook

说明尽量写在 playbook、inventory、配置文件和 `requirements.yml` 的就地注释里；阅读时建议直接打开这些文件一起看。

## 使用前提

下面的命令默认都在 `27-collections-and-galaxy` 目录中执行。
如果你当前还没有实际 inventory，可以先执行：

```bash
./prepare.sh
```

## 快速开始

```bash
uv run ansible-galaxy collection install -r requirements.yml
./prepare.sh
uv run ansible-playbook collections_and_galaxy.yml
```

## 完成标准

跑完后，你应该能观察到：

- `requirements.yml` 用来声明项目依赖哪些 collections
- `ansible-galaxy collection list` 是在控制端查看已安装 collections
- `community.general.archive` 里的 `community.general` 就是 collection 名
- `collections:` 关键字可以让本章故意演示短模块名 `archive:` 的来源
