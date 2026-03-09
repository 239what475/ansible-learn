# 这是一个最小子模块。
#
# 子模块的重点不是“它一定要多复杂”，而是：
# - 有输入
# - 有资源
# - 有输出
#
# 这样 root module 才能把它当成一块可复用配置来调用。

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

# 子模块里也要把 provider 来源声明清楚。
# 否则 Terraform 会按默认命名空间去猜：
# - `hashicorp/docker`
#
# 但我们当前真正用的是：
# - `kreuzwerker/docker`
#
# 所以这一段不是在重新配置 provider 参数，
# 而是在告诉 Terraform：
# - 这个子模块依赖的 `docker` provider，来源也是 `kreuzwerker/docker`

variable "image_id" {
  description = "根模块传进来的镜像 ID"
  type        = string
}

variable "container_name" {
  description = "容器名"
  type        = string
}

variable "network_name" {
  description = "网络名"
  type        = string
}

variable "published_port" {
  description = "宿主机端口"
  type        = number
}

# 子模块这里不再单独配置 provider。
# 当前这一章先采用最简单的方式：
# - 由 root module 提供 Docker provider
# - 子模块直接使用这份 provider 上下文
#
# 以后学到更复杂的 provider alias 场景时，
# 再单独展开“模块和 provider 传递”的话题。

resource "docker_network" "demo" {
  name = var.network_name
}

resource "docker_container" "demo" {
  name  = var.container_name
  image = var.image_id

  ports {
    internal = 80
    external = var.published_port
  }

  networks_advanced {
    name = docker_network.demo.name
  }
}

# 子模块通过 output 把内部结果暴露给 root module。
# 这样外层就能用：
# - `module.blue.summary`
# - `module.green.summary`
#
# 来读取这里整理好的结果。
output "summary" {
  value = {
    container_name = docker_container.demo.name
    container_id   = docker_container.demo.id
    network_name   = docker_network.demo.name
    published_port = var.published_port
  }
}
