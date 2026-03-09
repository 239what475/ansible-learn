# 这一章把两个容易混在一起的点拆开看：
# - `state`：Terraform 现在“记住了什么”
# - `lifecycle`：Terraform 在变更资源时，要额外遵守什么规则
#
# 这一章不会追求把所有 lifecycle 选项一次讲完，
# 先抓两个会在可运行示例里直接出现的选项：
# - `create_before_destroy`
# - `ignore_changes`
#
# 同时补充认识：
# - `prevent_destroy`

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

variable "project_name" {
  description = "项目名，用来参与资源命名"
  type        = string
  default     = "terraform-state-demo"
}

variable "environment_name" {
  description = "环境名"
  type        = string
  default     = "dev"
}

variable "published_port" {
  description = "把容器内 80 端口映射到宿主机的哪个端口"
  type        = number
  default     = 18085
}

variable "container_message" {
  description = "演示资源参数变化时 plan 会发生什么"
  type        = string
  default     = "managed by terraform state demo"
}

locals {
  container_name = "${var.project_name}-${var.environment_name}"
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "demo" {
  name  = local.container_name
  image = docker_image.nginx.image_id
  env = [
    "CONTAINER_MESSAGE=${var.container_message}",
  ]

  ports {
    internal = 80
    external = var.published_port
  }

  lifecycle {
    # `ignore_changes` 的意思可以先理解成：
    # - 就算外部世界把这里列出的属性改了
    # - Terraform 在后续 plan/apply 时也先不要把它当成必须纠正的差异
    #
    # 这一章故意把 `env` 放进来，是为了让你后面更容易做实验：
    # - 即使你改 `container_message`
    # - Terraform 也会因为 `ignore_changes = [env]` 而忽略这部分变化
    ignore_changes = [env]

    # `prevent_destroy` 也是很常见的 lifecycle 选项，
    # 作用可以先理解成“防止误删关键资源”。
    #
    # 但它不能像普通资源参数那样直接依赖变量动态开关，
    # 所以这一章不把它直接启用在可运行示例里。
    # 否则整章的 `destroy` 流程会被它拦住，示例不容易完整跑通。
    #
    # 如果你在真实项目里要保护关键资源，常见写法会是：
    # prevent_destroy = true

    # `create_before_destroy` 表示：
    # - 如果某种变更必须通过“替换资源”来实现
    # - Terraform 会尽量先创建新资源，再销毁旧资源
    #
    # 这一章主要是先认识这个开关的语义。
    create_before_destroy = true
  }
}

output "state_demo_summary" {
  value = {
    container_name    = docker_container.demo.name
    published_port    = var.published_port
    prevent_destroy   = "not enabled in this runnable example"
    ignored_attribute = "env"
  }
}
