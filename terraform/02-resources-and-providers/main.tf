# 这一章使用 Docker provider 演示 Terraform 里 provider 和 resource 的分工。
# 这一章建议你把注意力集中在下面几个关键词上：
# - provider
# - resource
# - 资源地址
# - 资源属性引用
# - 自动依赖关系

terraform {
  required_version = ">= 1.5.0"

  # 这里选择 Docker provider。
  # 原因很直接：Docker 资源在本地就能实验，适合先把 provider 和 resource 的关系看清楚。
  # `resource "docker_image" ...`、`resource "docker_container" ...`
  # 这些类型名之所以能用，是因为 Docker provider 插件提供了这些资源类型。
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# `provider` 是 Terraform 和某一类外部系统之间的入口。
# 当前这个 provider 负责让 Terraform 去管理 Docker 里的资源。
# 它本身不是资源，也不是要被创建出来的对象。
provider "docker" {}

# `docker_image` 是 Docker provider 提供的一种资源类型。
# 你可以先理解成“Terraform 能管理的 Docker 对象类型之一”。
# 这个资源的地址是：
# - `docker_image.alpine`
# 以后在 `plan`、`state list`、`show` 输出里，你会反复看到这种
# “资源类型.本地名字” 的写法。
resource "docker_image" "alpine" {
  name = "alpine:latest"
}

# 这里故意再声明第二个镜像资源，帮助你建立一个直觉：
# - 资源类型可以相同
# - 但资源本地名字必须不同
# 所以这里是：
# - `docker_image.alpine`
# - `docker_image.busybox`
# 这也说明：
# - “资源类型”不等于“资源实例”
# - 同一种资源类型下面，可以声明多个不同实例
resource "docker_image" "busybox" {
  name = "busybox:latest"
}

# 这里声明一个容器资源，并引用前面的镜像资源属性。
# Terraform 看到 `docker_image.alpine.image_id` 之后，
# 会自动推断当前容器依赖前面的镜像资源。
# 所以这一章没有显式写 `depends_on`：
# - 只要已经有资源属性引用
# - Terraform 通常就能自己推断依赖顺序
resource "docker_container" "demo" {
  name  = "terraform-resource-demo"
  image = docker_image.alpine.image_id

  # 这里必须给 Alpine 一个“不会立刻退出的前台命令”。
  # 原因是：
  # - Docker 容器的生命周期取决于前台主进程（PID 1）
  # - 如果主进程马上结束，容器也会立刻退出
  # - `alpine` 这种镜像默认不是像 `nginx` 那样的长期服务型镜像
  # 所以如果这里不显式给一个保活命令，
  # 当前容器通常会在创建后很快停止，后面的 `docker ps` 观察就不直观了。
  # 这一章这样写，不是为了业务逻辑，而是为了稳定演示：
  # - 容器资源被成功创建
  # - 容器保持 running
  # - `terraform state list` 和 `docker ps` 都更容易观察
  command = ["sh", "-c", "while true; do sleep 3600; done"]
}

# `output` 在这一章只承担观察结果的作用。
output "managed_resources" {
  value = [
    docker_image.alpine.name,
    docker_image.busybox.name,
    docker_container.demo.name,
  ]
}
