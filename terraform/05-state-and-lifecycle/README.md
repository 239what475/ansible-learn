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
main.tf -> terraform init -> terraform apply -auto-approve -> terraform state list -> terraform show -> terraform plan -var='container_message=changed outside of lifecycle' -> terraform plan -var='environment_name=blue' -var='published_port=18086' -> terraform apply -auto-approve -var='environment_name=blue' -var='published_port=18086' -> terraform destroy -auto-approve
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
- 修改 `environment_name` 后重新 `terraform plan`
  - 观察容器名变化如何导致“替换资源”
  - 再理解 `create_before_destroy = true` 为什么是一个生命周期规则
  - 这一章建议同时再改一个新端口，避免新旧容器争抢同一个宿主机端口

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

## 关于 `create_before_destroy`

这一章除了“忽略变化”的例子，还建议你再做一个“触发替换”的例子：

```bash
terraform plan -var='environment_name=blue' -var='published_port=18086'
```

这里要额外强调一句：

- 这条命令是为了做一个最小实验
- 用来观察 lifecycle 行为
- 不是推荐的长期配置方式

也就是说，这里的 `-var` 更像：

- 临时覆盖
- 教学探针

而不是日常项目里主要的配置入口。

在更真实的 Terraform 项目里，通常更推荐：

- 把不同环境的值放进：
  - `terraform.tfvars`
  - `dev.tfvars`
  - `prod.tfvars`
  - 或更明确的环境目录结构
- 然后让命令负责：
  - `plan`
  - `apply`
  - `destroy`

也就是把“配置”放回文件里，而不是长期依赖命令行参数。

这里的关键不是 `environment_name` 这个名字本身，
而是它会影响：

- `local.container_name = "${var.project_name}-${var.environment_name}"`

所以一旦 `environment_name` 变了，
容器的：

- `name`

也会跟着变。

对当前这个 Docker 容器资源来说，`name` 这类字段通常不能原地修改，
Terraform 会倾向于把它判断成：

- 旧资源销毁
- 新资源创建

但这里还有一个现实限制：

- 旧容器已经占用了：
  - `0.0.0.0:18085`
- 如果你只改名字，不改端口
  - 新容器也还是想占 `18085`
  - 那么即使 Terraform 想“先创建新容器，再销毁旧容器”
  - Docker 也会因为端口冲突直接报错

所以这一章要真正看到：

- `create_before_destroy = true`

的成功路径，更合适的实验方式是：

- 同时改 `environment_name`
- 也改 `published_port`

例如：

```bash
terraform apply -auto-approve -var='environment_name=blue' -var='published_port=18086'
```

这时你就能把：

- `ignore_changes`
- `create_before_destroy`

这两个生命周期选项区别开：

- `ignore_changes`
  - 控制“某些字段变化先忽略”
- `create_before_destroy`
  - 控制“如果已经决定要替换资源，替换顺序怎么安排”

也可以顺手再记一句：

- 不能只改一个“会触发替换”的字段，
  就指望 `create_before_destroy` 总能成功
- 如果新旧资源在外部世界里根本不能共存
  - 例如两个容器不能同时绑定同一个宿主机端口
  - 那么“先创建再销毁”仍然可能失败

## 关于 destroy 命令是否继续带 `-var`

这一章里不建议把 `destroy` 也写成一长串带 `-var` 的命令。

更合适的收尾方式是：

```bash
terraform destroy -auto-approve
```

原因是：

- 这一章要强调的是：
  - Terraform 通过 `state` 记录当前受管理对象
- 所以销毁阶段更适合直接观察：
  - Terraform 如何基于当前 state 删除资源

也就是说：

- 替换实验时，`apply` 需要带上那组 `-var`
  - 因为你要主动把配置切到另一种目标状态
- 但销毁阶段，这一章不需要再把同一串 `-var` 重复一遍
  - 否则会把重点从 “state 的作用” 带偏成 “命令行参数怎么重复传”

## 完成标准

做到下面这些，就可以进入下一章：

- 你能解释 `state` 是做什么的
- 你知道 `terraform state list` 和 `terraform show` 的区别
- 你能解释 `ignore_changes`、`prevent_destroy`、`create_before_destroy` 分别在控制什么
- 你知道为什么这一章只把 `prevent_destroy` 作为概念补充，而没有直接启用
