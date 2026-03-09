# 这一章开始把两个很容易混的概念分开：
# - `data`
# - `resource`
#
# 先抓最核心的区别：
# - `resource` 负责“创建 / 修改 / 删除”对象
# - `data` 负责“读取”外部系统里已经存在的信息
#
# 这章继续使用 Docker 做本地实验，避免过早引入别的系统复杂度。

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

variable "image_name" {
  description = "要读取并拉取的镜像名"
  type        = string
  default     = "nginx:latest"
}

variable "container_name" {
  description = "示例容器名"
  type        = string
  default     = "terraform-data-demo"
}

variable "network_name" {
  description = "示例网络名"
  type        = string
  default     = "terraform-data-demo-network"
}

variable "published_port" {
  description = "把容器 80 端口映射到宿主机的哪个端口"
  type        = number
  default     = 18086
}

# `data` 块表示“读取外部信息”，而不是“创建资源”。
# 这里读取的是镜像仓库里关于 `nginx:latest` 的元信息。
#
# 你可以先把它理解成：
# - 去问镜像仓库：“这个镜像现在对应什么 digest？”
# - 然后把读取到的结果给后面的配置继续用
#
# 后面你运行 `terraform state list` 时，这个地址也可能会以：
# - `data.docker_registry_image.nginx`
# 的形式出现。
#
# 但这里不要误解：
# - 它出现，不表示 Terraform “创建了一个资源”
# - 它只是把这次读取到的数据结果记下来，方便后续表达式继续引用
data "docker_registry_image" "nginx" {
  name = var.image_name
}

# 这一块才是真正的资源创建：
# - 把镜像拉到当前 Docker 环境里
# - 并由 Terraform 管理它
#
# 这里引用了：
# - `data.docker_registry_image.nginx.name`
# - `data.docker_registry_image.nginx.sha256_digest`
#
# 这说明：
# - 数据源结果也可以被资源继续引用
resource "docker_image" "nginx" {
  name = data.docker_registry_image.nginx.name
  pull_triggers = [
    data.docker_registry_image.nginx.sha256_digest,
  ]
  keep_locally = true
}

# 这里声明的是一个 Docker 网络资源。
# 你可以先把它理解成：
# - 让 Terraform 通过 Docker provider 创建一个 network
# - 并把这个 network 纳入 Terraform 管理
#
# 这行里的两个名字要分开看：
# - `docker_network`
#   - 资源类型
#   - 表示“这是 Docker provider 提供的网络资源”
# - `demo`
#   - 这个资源在当前配置里的本地名字
#   - 它的资源地址就是：
#     - `docker_network.demo`
#
# `name = var.network_name` 表示：
# - Docker 里真正创建出来的网络名
# - 来自变量 `network_name`
#
# 后面容器会通过：
# - `docker_network.demo.name`
# 引用这个网络，
# 所以这一章里除了“容器依赖镜像”，也顺手演示了“容器依赖网络”。
resource "docker_network" "demo" {
  name = var.network_name
}

resource "docker_container" "demo" {
  name  = var.container_name
  image = docker_image.nginx.image_id

  # 这里顺手把数据源和本地资源的结果都放进 env。
  # 这样后面看配置时，更容易分清：
  # - 哪些值来自 `data`
  # - 哪些值来自 `resource`
  env = [
    "IMAGE_NAME=${data.docker_registry_image.nginx.name}",
    "IMAGE_DIGEST=${data.docker_registry_image.nginx.sha256_digest}",
    "NETWORK_NAME=${docker_network.demo.name}",
  ]

  ports {
    internal = 80
    external = var.published_port
  }

  # `networks_advanced {}` 是容器资源里的嵌套块，
  # 用来描述“这个容器要接到哪个 Docker 网络上”。
  #
  # 这里不是手写一个固定字符串，而是引用：
  # - `docker_network.demo.name`
  #
  # 这样做有两个直接好处：
  # - 少重复：网络名只在网络资源里定义一次
  # - 自动依赖：Terraform 会知道容器依赖这个网络
  #
  # 你可以把它和上面的 `ports {}` 对比着看：
  # - `ports {}` 管端口映射
  # - `networks_advanced {}` 管容器加入哪个网络
  networks_advanced {
    name = docker_network.demo.name
  }

  # `depends_on` 是显式依赖写法。
  #
  # 这一章保留它，是为了让你先认识语法：
  # - 某个对象即使没有直接属性引用
  # - 你也可以强制要求它先依赖另一个对象
  #
  # 但要看清楚：
  # 当前这个例子里，容器已经通过
  # - `image = docker_image.nginx.image_id`
  # - `name = docker_network.demo.name`
  # 自动建立了依赖关系。
  #
  # 所以这里的 `depends_on` 更偏教学展示，不是必须写法。
  depends_on = [docker_network.demo]
}

output "data_source_summary" {
  value = {
    requested_image_name = var.image_name
    resolved_image_name  = data.docker_registry_image.nginx.name
    resolved_digest      = data.docker_registry_image.nginx.sha256_digest
  }
}

output "dependency_summary" {
  value = {
    data_source_address        = "data.docker_registry_image.nginx"
    image_resource_address     = "docker_image.nginx"
    network_resource_address   = "docker_network.demo"
    container_resource_address = "docker_container.demo"
    explicit_depends_on_used   = true
  }
}
