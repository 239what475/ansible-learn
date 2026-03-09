# 这一章只聚焦“同一份配置如何服务多个环境”。
# 重点不是再学新的 provider 功能，而是看清：
# - 哪些内容应该稳定写在 Terraform 配置里
# - 哪些内容应该拆到环境文件里

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

# 这些变量在不同环境里都存在，但取值会不同。
# 这一章的重点不是命令行 `-var='a=b'`，而是用环境文件去填这些值。
#
# 你可以先把 `main.tf` 理解成：
# - 资源结构定义
# - 变量声明
# 而把 `dev.tfvars` / `prod.tfvars` 理解成：
# - 当前环境到底用什么值
variable "project_name" {
  description = "项目名，会参与容器命名"
  type        = string
  default     = "terraform-envs-default"
}

variable "environment_name" {
  description = "环境名，例如 dev / prod"
  type        = string
  default     = "default"
}

variable "published_port" {
  description = "容器对外暴露到宿主机的端口"
  type        = number
  default     = 18090
}

variable "container_message" {
  description = "写进容器环境变量里的消息"
  type        = string
  default     = "hello from defaults"
}

locals {
  # `locals` 继续负责整理“配置内部想复用的中间值”。
  # 它不会被 `tfvars` 直接覆盖，但会随着 `var.xxx` 的变化间接变化。
  container_name = "${var.project_name}-${var.environment_name}"

  # 这里故意把环境关键信息再整理成一条可读消息，
  # 后面输出时更容易看出“同一份 main.tf，不同环境值”。
  environment_summary = format(
    "project=%s env=%s port=%d",
    var.project_name,
    var.environment_name,
    var.published_port,
  )

  container_env = [
    "APP_ENV=${var.environment_name}",
    "APP_MESSAGE=${var.container_message}",
    "ENVIRONMENT_SUMMARY=${local.environment_summary}",
  ]
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "demo" {
  # 同一份资源定义不变，但容器名字会跟着环境文件变化。
  name  = local.container_name
  image = docker_image.nginx.image_id
  env   = local.container_env

  ports {
    internal = 80
    external = var.published_port
  }
}

# 这一组输出故意同时展示：
# - 原始输入变量
# - locals 整理值
# - 资源最终结果
# 这样你切换 `dev` / `prod` 时更容易对照变化来自哪一层。
output "environment_inputs" {
  value = {
    project_name      = var.project_name
    environment_name  = var.environment_name
    published_port    = var.published_port
    container_message = var.container_message
  }
}

output "environment_locals" {
  value = {
    container_name      = local.container_name
    environment_summary = local.environment_summary
  }
}

output "environment_runtime" {
  value = {
    container_name = docker_container.demo.name
    image_name     = docker_image.nginx.name
    image_id       = docker_image.nginx.image_id
  }
}
