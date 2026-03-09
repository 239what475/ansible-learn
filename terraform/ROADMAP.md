# Terraform 学习路线图

## 目标

- 先学会 `Terraform` 的核心工作流和状态模型
- 再学会模块、环境拆分和项目组织
- 最后把 `Terraform` 和 `Ansible` 串起来，形成更完整的自动化链路

## 当前状态

- 这条基础主线已经完成 `00 ~ 10`
- 当前实现主要基于：
  - 前半段用 `Docker` 建立 Terraform 核心模型直觉
  - 后半段继续用 `Docker` 和本地文件交接，把 `Terraform + Ansible` 串起来
- 也就是说，这条主线目前还没有切到 `Incus`，后续如果需要更贴近真实节点的实验，再单独扩展

## 建议顺序

- `00-prestart`
  - 安装 `Terraform`
  - 认识 `terraform version`
  - 认识 `terraform fmt`、`validate`

- `01-init-plan-apply-destroy`
  - 认识 `init`
  - 认识 `plan`
  - 认识 `apply`
  - 认识 `destroy`
  - 默认先用 `Docker` 做最小本地实验

- `02-resources-and-providers`
  - 认识 `provider`
  - 认识 `resource`
  - 理解“声明资源”而不是“执行脚本”
  - 继续用 `Docker provider` 建立资源模型直觉

- `03-variables-outputs-locals`
  - 学 `variable`
  - 学 `output`
  - 学 `locals`

- `04-functions-and-expressions`
  - 学常用函数
  - 学表达式
  - 学条件和集合处理

- `05-state-and-lifecycle`
  - 学 `state`
  - 学资源变更
  - 学 `lifecycle`
  - 这一阶段仍优先保持 `Docker` 实验环境，避免过早引入过多系统细节

- `06-data-sources-and-dependencies`
  - 学 `data`
  - 学依赖关系
  - 学引用其他资源和已有资源
  - 继续把资源图和依赖关系看清楚

- `07-modules`
  - 学模块拆分
  - 学输入输出
  - 学模块复用
  - 继续使用本地可控实验环境，重点放在模块结构本身

- `08-environments-and-tfvars`
  - 学环境拆分
  - 学 `tfvars`
  - 学目录组织
  - 用不同环境文件驱动同一份配置

- `09-mini-project`
  - 做一个完整的 `Terraform` 小项目
  - 把前面的概念串起来
  - 当前实现使用 `Docker + module + templatefile`

- `10-terraform-and-ansible`
  - 学 `Terraform` 和 `Ansible` 的分工
  - 学如何把资源输出交给 `Ansible`
  - 为后续 `Kubernetes` 主线做准备
  - 当前实现是 `Terraform` 生成交接文件，`Ansible` 本地消费这些文件

## 当前建议

- 先从 `00-prestart` 开始
- 前几章先不绑定具体云厂商
- 当前 `00 ~ 10` 已经足够完成一轮 `Terraform` 基础学习
- 如果后面继续扩展，可以考虑两条方向：
  - 引入 `Incus` 或云 provider，补“更真实资源环境”
  - 直接进入 `Kubernetes` 主线，把 `Terraform + Ansible + K8s` 串起来
