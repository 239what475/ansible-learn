# Ansible Learn

这是一个面向初学者的 `Ansible` 学习仓库。
当前默认使用：

- `uv + .venv` 作为本地 Python / Ansible 环境
- `Incus` 容器作为被管理节点
- `Ansible` 通过 `SSH` 管理这些节点

## 推荐阅读顺序

1. `00-prestart/README.md`
2. `00-prestart/ansible.md`
3. `00-prestart/ssh.md`
4. `00-prestart/incus.md`
5. `01-quickstart/README.md`
6. `02-common-modules/README.md`
7. `03-variables-and-facts/README.md`
8. `04-conditions-loops-templates/README.md`
9. `05-group-vars-and-host-vars/README.md`
10. `06-roles/README.md`

## 目录说明

- `00-prestart/`：开始实操前需要完成的本机环境准备
- `01-quickstart/`：第一章，跑通最小可用的 `Ansible + Incus` 实验环境
- `02-common-modules/`：第二章，学习常用模块和幂等性
- `03-variables-and-facts/`：第三章，学习变量、facts、`register` 和 `debug`
- `04-conditions-loops-templates/`：第四章，学习 `when`、`loop` 和 `template`
- `05-group-vars-and-host-vars/`：第五章，学习 `group_vars`、`host_vars` 和变量覆盖关系
- `06-roles/`：第六章，学习 role 的基本结构和使用方式
- `scripts/`：仓库级公共脚本，不绑定某一章

## 学习路径

- 先完成 `00-prestart/`
- 再进入 `01-quickstart/`
- 然后进入 `02-common-modules/`
- 接着进入 `03-variables-and-facts/`
- 然后进入 `04-conditions-loops-templates/`
- 然后进入 `05-group-vars-and-host-vars/`
- 然后进入 `06-roles/`

## 文件约定

- 需要用户本地复制后再修改的文件，统一使用 `.example` 后缀
- 本地实际使用的文件去掉 `.example` 后缀，并加入对应目录的 `.gitignore`
- `Ansible` 示例默认使用 YAML

## 说明

- `README` 主要负责导航
- 章节里的关键学习点尽量写在 playbook、inventory、配置文件和脚本的就地注释中
