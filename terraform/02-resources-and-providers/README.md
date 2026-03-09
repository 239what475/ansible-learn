# 02: resources and providers

这一章只聚焦两件事：

- `provider` 到底是什么
- `resource` 到底是什么

这一章使用 `Docker provider` 做本地实验，重点是把 `Terraform` 的资源模型看清楚。

## 文件

- `main.tf`：这一章的最小示例配置
- `.gitignore`：忽略运行时目录和状态文件

## 前提

这一章的前提：

- `terraform version` 可以正常运行
- `docker version` 可以正常运行
- 当前用户能连接到 Docker daemon

## 这一章想建立的直觉

你先只记这几句话：

- `provider`
  - 是 Terraform 连接某类系统的插件入口
- `resource`
  - 是 Terraform 管理的具体对象
- `resource` 不是脚本步骤
  - 它描述的是“目标状态里应该有这个对象”
- 一个资源可以引用另一个资源的属性
  - Terraform 会据此自动建立依赖关系
- 资源地址通常长这样
  - `资源类型.本地名字`
  - 例如：
    - `docker_image.alpine`
    - `docker_image.busybox`
    - `docker_container.demo`

## 建议顺序

```text
main.tf -> terraform init -> terraform plan -out=chapter02.tfplan -> terraform show chapter02.tfplan -> terraform apply chapter02.tfplan -> terraform state list -> terraform show -> terraform destroy
```

## 这一章你会看到什么

第一次跑 `terraform plan` 时，建议重点观察：

- 有两个 `docker_image` 资源
  - `docker_image.alpine`
  - `docker_image.busybox`
- 有一个 `docker_container` 资源
  - `docker_container.demo`
- `docker_container.demo` 会引用 `docker_image.alpine.image_id`
  - 这就是资源之间的属性引用
  - 也是 Terraform 自动推断依赖关系的依据

当你执行：

```bash
terraform state list
```

你会看到 state 里当前记录了哪些资源，例如：

- `docker_container.demo`
- `docker_image.alpine`
- `docker_image.busybox`

这一步很重要，因为它能帮助你把下面三件事区分开：

- 配置文件里声明了哪些资源
- 真实环境里现在有什么资源
- state 里当前记录了哪些资源

## 这一章再多看一个点：资源地址

Terraform 后面会反复出现“资源地址”这个概念。
这一章先只记最常见的形式：

- `docker_image.alpine`
- `docker_image.busybox`
- `docker_container.demo`

你可以先这样理解：

- 前半段
  - `docker_image`
  - `docker_container`
  - 是资源类型
- 后半段
  - `alpine`
  - `busybox`
  - `demo`
  - 是你在当前配置里给这个资源起的本地名字

所以：

- `docker_image.alpine.image_id`

这句的意思就是：

- 取资源 `docker_image.alpine` 的 `image_id` 属性

## 为什么这一章没有写 `depends_on`

因为这里已经有了这句：

- `image = docker_image.alpine.image_id`

只要一个资源直接引用了另一个资源的属性，
Terraform 通常就能自动推断依赖关系。

也就是说，这一章里：

- `docker_container.demo`
  - 会自动依赖
- `docker_image.alpine`

所以 Terraform 会先准备镜像，再创建容器。

只有在“没有直接属性引用，但你仍然想强制指定顺序”时，
才更需要显式写 `depends_on`。

这里再补两个很常用的命令概念：

- `terraform plan`
  - 默认只是在终端里展示计划
  - 不会自动生成一个 `.tfplan` 文件

- `terraform plan -out=chapter02.tfplan`
  - 才会把这次计划真正保存到 `chapter02.tfplan`
  - 保存下来之后，你可以用：
    - `terraform show chapter02.tfplan`
    - `terraform apply chapter02.tfplan`

- `terraform show`
  - 可以先理解成“把当前 state 的详细内容展开给你看”
  - 这里默认看的不是 `.tfplan`，而是当前 state

- `terraform show chapter02.tfplan`
  - 可以先理解成“把刚才保存下来的 plan 文件内容展开给你看”
  - 只有你之前真的执行过：
    - `terraform plan -out=chapter02.tfplan`
  - 这种写法才有意义

所以这里要明确区分两种不同对象：

- `chapter02.tfplan`
  - 是计划文件
  - 只有显式 `-out=...` 才会生成
- `terraform.tfstate`
  - 是状态文件
  - `apply` 完成后会更新
  - 所以即使没有 `.tfplan` 文件，`terraform show` 仍然可以查看当前 state

所以你可以先把它们的分工记成：

- `plan`
  - 生成计划
- `show`
  - 查看已经存在的 state / plan 内容

## 完成标准

做到下面这些，就可以进入下一章：

- 你能解释 `provider` 和 `resource` 的区别
- 你能读懂 `resource "类型" "名字"` 这两个部分分别是什么
- 你知道为什么 `docker_container` 会依赖 `docker_image`
- 你知道 `terraform state list` 会列出当前 state 里记录了哪些资源
