# 这一章只聚焦三类最常见的 Terraform 值来源：
# - `variable`
# - `locals`
# - `output`
#
# 你可以先建立一个简单直觉：
# - `variable`：外部输入
# - `locals`：在当前配置里根据输入整理出来的中间值
# - `output`：把最终结果导出给人看，或者给别的模块/流程继续使用

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

# `variable` 可以先理解成“这份 Terraform 配置对外暴露的输入参数”。
# 以后你可以通过：
# - 默认值
# - `terraform.tfvars`
# - `-var`
# - `-var-file`
# 这些方式给它赋值。
#
# 这里的 `default` 表示：
# - 如果外部没有显式传值
# - 就先使用这个默认值
# - 如果外部通过 `terraform.tfvars`、`-var-file`、`-var` 提供了同名值
# - 那这些外部输入通常会覆盖这里的默认值
variable "project_name" {
  description = "这一章示例使用的项目名"
  type        = string
  default     = "terraform-vars-demo"
}

variable "environment_name" {
  description = "当前环境名，用来参与容器命名"
  type        = string
  default     = "dev"
}

variable "container_port" {
  description = "把容器内 80 端口映射到宿主机的哪个端口"
  type        = number
  default     = 8082
}

variable "base_message" {
  description = "这一章用来演示变量和 locals 组合的基础消息"
  type        = string
  default     = "managed by terraform"
}

# `locals` 不是外部输入，而是“当前配置自己整理出来的中间值”。
# 它非常适合放：
# - 拼接后的名字
# - 复用多次的表达式
# - 把多个输入整理成更清晰的最终值
#
# 这里你可以重点观察：
# - `var.xxx`：表示读取输入变量
# - `local.xxx`：表示读取当前 locals 里定义好的值
#
# 一个很重要的区别是：
# - `variable` 可以被外部输入覆盖
# - `locals` 不能像 `variable` 那样被 `tfvars` 直接赋值
# - `locals` 的值来自这里写下来的表达式
# 所以你如果想让 `local.container_name` 变化，
# 不是直接去“覆盖 local”，而是去改变它依赖的 `var.xxx`。
locals {
  # 这个值不是用户直接输入的，而是我们根据两个输入变量拼出来的。
  container_name = "${var.project_name}-${var.environment_name}"

  # `locals` 很适合把“最终展示用”的值提前整理好。
  full_message = "${var.base_message} (${var.environment_name})"

  # 这一行只演示：`locals` 里也可以直接引用输入变量 `var.xxx`。
  container_url = "http://localhost:${var.container_port}"

  # Docker provider 这里的 `env` 需要的是一个字符串列表，
  # 所以我们把几项变量和 locals 整理成容器环境变量列表。
  # 这里再额外演示：`locals` 里也可以继续引用别的 `local.xxx`。
  container_env = [
    "PROJECT_NAME=${var.project_name}",
    "ENVIRONMENT_NAME=${var.environment_name}",
    "FULL_MESSAGE=${local.full_message}",
  ]
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "demo" {
  # 这里故意使用 `local.container_name`，帮助你区分：
  # - `var.xxx` 是原始输入
  # - `local.xxx` 是整理后的中间值
  name  = local.container_name
  image = docker_image.nginx.image_id
  env   = local.container_env

  ports {
    internal = 80
    external = var.container_port
  }
}

# `output` 可以引用：
# - `var.xxx`
# - `local.xxx`
# - `资源类型.资源名.属性`
#
# 所以这一章里我们故意分三组输出，帮助你看清来源。

# 这一组只展示“原始输入”。
output "input_values" {
  value = {
    project_name     = var.project_name
    environment_name = var.environment_name
    container_port   = var.container_port
    base_message     = var.base_message
  }
}

# 这一组展示“由 locals 整理后的值”。
output "derived_values" {
  value = {
    container_name = local.container_name
    full_message   = local.full_message
    container_url  = local.container_url
  }
}

# 这一组展示“真正由资源 apply 后得到或确认的值”。
output "runtime_values" {
  value = {
    container_name = docker_container.demo.name
    image_name     = docker_image.nginx.name
    image_id       = docker_image.nginx.image_id
  }
}
