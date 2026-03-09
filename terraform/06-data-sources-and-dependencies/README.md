# 06: data sources and dependencies

这一章只聚焦两件事：

- `data` 是什么
- Terraform 是怎么推断依赖关系的

## 文件

- `main.tf`：这一章的完整示例
- `.gitignore`：忽略运行目录、状态文件和本地实验产物

## 前提

- `terraform version` 可以正常运行
- `docker version` 可以正常运行
- 当前用户能连接到 Docker daemon

## 这一章想建立的直觉

先只记下面四句话：

- `resource`
  - 表示 Terraform 要管理、会写进 state 的对象
- `data`
  - 表示 Terraform 只读取、不负责创建的外部信息
- 资源之间只要有属性引用
  - Terraform 通常就能自动推断依赖关系
- `depends_on`
  - 是显式依赖
  - 常用于“没有直接属性引用，但仍然想要求顺序”的场景

## 建议顺序

```text
main.tf -> terraform init -> terraform fmt -> terraform validate -> terraform plan -out=chapter06.tfplan -> terraform show chapter06.tfplan -> terraform apply -auto-approve chapter06.tfplan -> terraform state list -> terraform output -> terraform destroy -auto-approve
```

## 这一章会看到什么

- 一个 `data "docker_registry_image"` 数据源
  - 用来读取镜像仓库里的镜像信息
- 一个 `docker_image` 资源
  - 用来把镜像真正拉到本机 Docker 环境里
- 一个 `docker_network` 资源
  - 用来创建容器网络
- 一个 `docker_container` 资源
  - 同时引用镜像资源、网络资源和数据源结果

## 这一章建议重点观察什么

建议重点观察三件事：

- `terraform show chapter06.tfplan`
  - 看 plan 里同时出现了 `data` 和 `resource`
- `terraform state list`
  - 看哪些对象进了 state
- `terraform output`
  - 看数据源结果和资源结果是怎么一起被导出的

## 关于 data source

这一章里最重要的区别是：

- `data "docker_registry_image" "nginx"`
  - 只读取镜像仓库信息
  - 不负责创建资源
- `resource "docker_image" "nginx"`
  - 才是真的把镜像拉到本机 Docker 里
  - 也会进入 state

所以你后面如果运行：

- `terraform state list`

这次实际会看到：

- `data.docker_registry_image.nginx`
- `docker_container.demo`
- `docker_image.nginx`
- `docker_network.demo`

这里要注意区分两件事：

- `data.docker_registry_image.nginx`
  - 也可能出现在 `state list` 里
  - 因为 Terraform 需要记录这次读取到的数据结果，供后续表达式继续使用
- 但它仍然不是“由 Terraform 创建并负责销毁的资源”
  - 它更像一次只读查询的结果记录
  - 不应该和 `docker_container.demo`、`docker_network.demo` 这种真正受 Terraform 生命周期管理的资源混为一谈

## 关于依赖关系

这一章里会同时出现两种依赖：

- 自动依赖
  - 例如容器引用了：
    - `docker_image.nginx.image_id`
    - `docker_network.demo.name`
  - Terraform 会自动知道：
    - 容器依赖镜像和网络

- 显式依赖
  - 通过：
    - `depends_on = [docker_network.demo]`
  - 这一章里保留它，是为了让你看到语法
  - 但当前例子里其实已经通过属性引用建立了自动依赖
  - 所以这里的 `depends_on` 更偏教学演示，不是必须写法

## 完成标准

做到下面这些，就可以进入下一章：

- 你能解释 `data` 和 `resource` 的区别
- 你知道为什么数据源通常不是“创建资源”
- 你能解释 Terraform 为什么能自动推断依赖关系
- 你知道 `depends_on` 是干什么的，以及什么时候它只是教学演示
