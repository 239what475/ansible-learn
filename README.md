# SRE Tools Learn

这是一个面向初学者、按工具逐步扩展的 `SRE` 学习仓库。

当前已经完整整理好的学习主线是：

- `ansible/`：从 `00` 到 `30` 的 `Ansible` 教程与 mini project
- `terraform/`：从 `00` 到 `10` 的 `Terraform` 基础主线
- `kubernetes/`：当前已开始 `00-prestart`，采用 `kubectl + minikube` 路线，并直接准备本地三节点实验集群

后续计划继续补充：

- 以及更多常见的 `SRE / Platform Engineering` 工具链内容

## 当前推荐入口

如果你现在要继续学习，请先从这里开始：

- `ansible/README.md`
- `ansible/ROADMAP.md`
- `terraform/README.md`
- `terraform/ROADMAP.md`
- `kubernetes/README.md`
- `kubernetes/ROADMAP.md`

## 当前目录结构

- `ansible/`：当前最完整的一条学习主线，包含实验章节和脚本
- `terraform/`：已经完成一条 `00 ~ 10` 的基础学习主线
- `kubernetes/`：刚开始搭建，当前已补 `00-prestart`，默认使用本地三节点 `minikube` 集群
- `ROADMAP.md`：仓库级路线说明
- `AGENTS.md`：仓库级约定

## 说明

- 目前仓库统一使用根目录下的 `.venv`
- `uv` 缓存使用用户默认路径，不固定在仓库内
- 根目录继续只做总导航和总约定
