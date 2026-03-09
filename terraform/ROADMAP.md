# Terraform 学习路线图

## 目标

- 先学会 `Terraform` 的核心工作流和状态模型
- 再学会模块、环境拆分和项目组织
- 最后把 `Terraform` 和 `Ansible` 串起来，形成更完整的自动化链路

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

- `02-resources-and-providers`
  - 认识 `provider`
  - 认识 `resource`
  - 理解“声明资源”而不是“执行脚本”

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

- `06-data-sources-and-dependencies`
  - 学 `data`
  - 学依赖关系
  - 学引用其他资源和已有资源

- `07-modules`
  - 学模块拆分
  - 学输入输出
  - 学模块复用

- `08-environments-and-tfvars`
  - 学环境拆分
  - 学 `tfvars`
  - 学目录组织

- `09-mini-project`
  - 做一个完整的 `Terraform` 小项目
  - 把前面的概念串起来

- `10-terraform-and-ansible`
  - 学 `Terraform` 和 `Ansible` 的分工
  - 学如何把资源输出交给 `Ansible`
  - 为后续 `Kubernetes` 主线做准备

## 当前建议

- 先从 `00-prestart` 开始
- 前几章先不绑定具体云厂商
- 先把 `Terraform` 的通用模型学清楚，再考虑 provider 细节
