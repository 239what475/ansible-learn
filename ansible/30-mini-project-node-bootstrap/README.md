# Ansible + Incus 30: Mini Project - Node Bootstrap

这一节是 `01 ~ 29` 的综合小项目。
目标不是再引入很多新语法，而是把前面学过的内容串起来，做一个更接近真实项目结构的 `Ansible` 节点初始化示例。

## 文件

- `prepare.sh`：复制 `29-best-practices-and-lint` 的 inventory
- `ansible.cfg`：当前目录使用的 Ansible 配置
- `inventory.yml.example`：主机清单模板
- `group_vars/`：项目级公共变量
- `host_vars/`：主机级差异变量
- `site.yml`：项目入口 playbook
- `roles/node_bootstrap/`：这一章的核心 role

## 使用前提

下面的命令默认都在 `30-mini-project-node-bootstrap` 目录中执行。
如果你当前还没有实际 inventory，可以先执行：

```bash
./prepare.sh
```

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook site.yml
```

## 完成标准

跑完后，你应该能观察到：

- 项目如何把变量、role、模板和入口 playbook 组织起来
- 被管理主机上会生成一个小型“初始化结果目录”
- 控制端本地会生成一份汇总报告
- 同一个项目里可以同时用到：
  - `group_vars`
  - `host_vars`
  - `role`
  - `template`
  - `handler`
  - `service`
  - `cron`
  - `delegate_to` / `connection: local`
