# 05: state and lifecycle

这一章只聚焦两件事：

- `state` 到底在记录什么
- `lifecycle` 到底在影响什么

## 文件

- `main.tf`：这一章的完整示例
- `.gitignore`：忽略运行目录、状态文件和本地实验产物

## 前提

- `terraform version` 可以正常运行
- `docker version` 可以正常运行
- 当前用户能连接到 Docker daemon

## 这一章想建立的直觉

先只记下面四句话：

- `state`
  - 是 Terraform 当前记住的资源状态记录
- `terraform state list`
  - 帮你看“state 里现在有哪些资源地址”
- `lifecycle`
  - 是资源变更时要额外遵守的规则
- `lifecycle` 不是资源本身属性
  - 它更像 Terraform 处理变更时的策略

## 建议顺序

```text
main.tf -> terraform init -> terraform apply -auto-approve -> terraform state list -> terraform show -> terraform plan -var='container_message=changed outside of lifecycle' -> terraform destroy -auto-approve
```

## 这一章会碰到哪些 lifecycle 选项

- `ignore_changes = [env]`
  - 表示 `env` 这项变化先忽略
- `create_before_destroy = true`
  - 表示如果必须替换资源，就尽量先创建新的，再删旧的

另外，这一章也会补充认识：

- `prevent_destroy = true`
  - 常用来保护关键资源
  - 但它不直接放进这一章的可运行示例里
  - 否则会把整章的 `destroy` 流程直接拦住

## 学习时建议重点观察什么

建议重点观察三件事：

- `terraform state list`
  - 看到 state 里记录了哪些资源地址
- `terraform show`
  - 看到 state 里资源的详细属性
- 修改 `container_message` 后重新 `terraform plan`
  - 观察 `ignore_changes = [env]` 的效果

## 关于 `prevent_destroy`

这一章只把它作为概念补充，不直接启用。

原因很简单：

- `prevent_destroy` 一旦启用
- 当前资源的 `destroy` 就会被保护规则拦住
- 这样整章的演示很难保持“apply 和 destroy 都能完整跑通”

你先记住它的用途就够了：

- 它通常用来保护关键资源
- 例如数据库、共享存储、核心网络资源
- 它更像“防误删保险丝”

## 关于 `ignore_changes`

这一章把：

- `env`

放进了：

- `ignore_changes`

所以后面如果你只改：

- `container_message`

Terraform 会知道：

- 配置里 `env` 和 state 里记录的值不一样了

但因为这项属性被显式忽略，所以 plan 不会把它当成必须修正的变更。

## 完成标准

做到下面这些，就可以进入下一章：

- 你能解释 `state` 是做什么的
- 你知道 `terraform state list` 和 `terraform show` 的区别
- 你能解释 `ignore_changes`、`prevent_destroy`、`create_before_destroy` 分别在控制什么
- 你知道为什么这一章只把 `prevent_destroy` 作为概念补充，而没有直接启用
