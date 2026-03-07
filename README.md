# Ansible Learn

这是一个面向初学者的 `Ansible` 学习仓库。

当前这套教程默认使用：

- `uv + .venv` 作为本地 Python / Ansible 环境
- `Incus` 容器作为被管理节点
- `Ansible` 通过 `SSH` 管理这些节点

## 推荐阅读顺序

1. `00-prestart/README.md`
2. `00-prestart/ansible.md`
3. `00-prestart/ssh.md`
4. `00-prestart/incus.md`
5. `01-quickstart/README.md`

## 目录说明

- `00-prestart/`：开始实操前需要完成的本机环境准备
- `01-quickstart/`：第一章，目标是跑通最小可用的 `Ansible + Incus` 实验环境
- `scripts/`：仓库级公共脚本，不绑定某一章

## 当前学习路径

- 先完成 `00-prestart/` 里的环境准备
- 再进入 `01-quickstart/` 跑通实验环境

## 文件约定

- 需要用户本地复制后再修改的文件，统一使用 `.example` 后缀
- 本地实际使用的文件去掉 `.example` 后缀，并加入对应目录的 `.gitignore`
- `Ansible` 示例默认使用 YAML

## 说明

如果你只是想直接开始动手，最短路径是：

1. 先看 `00-prestart/README.md`
2. 然后进入 `01-quickstart/README.md`
