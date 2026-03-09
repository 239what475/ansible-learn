# 这一章开始把前面学过的内容组合成一个更完整的 Terraform 项目。
# 根模块主要负责：
# - 声明 provider
# - 准备共享资源
# - 定义项目入口变量
# - 调用子模块

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

# 这里继续使用 `variable` 作为项目对外暴露的输入。
# 这一章里真正的环境差异主要来自：
# - `environments/dev.tfvars.example`
# - `environments/prod.tfvars.example`
variable "project_name" {
  description = "项目名，会参与站点容器和网络命名"
  type        = string
  default     = "terraform-mini-site"
}

variable "environment_name" {
  description = "当前环境名"
  type        = string
  default     = "dev"
}

variable "published_port" {
  description = "站点映射到宿主机的端口"
  type        = number
  default     = 18100
}

variable "site_title" {
  description = "写进首页模板里的站点标题"
  type        = string
  default     = "Terraform Mini Site"
}

variable "site_message" {
  description = "写进首页模板里的站点消息"
  type        = string
  default     = "hello from terraform"
}

locals {
  # 根模块也可以继续用 `locals` 整理重复表达式。
  container_name = "${var.project_name}-${var.environment_name}"
  network_name   = "${var.project_name}-${var.environment_name}-network"

  environment_summary = format(
    "project=%s env=%s port=%d",
    var.project_name,
    var.environment_name,
    var.published_port,
  )
}

# 这一章继续演示：根模块可以先用 `data` 读远程镜像元信息，
# 再交给 `resource` 真正把镜像纳入 Terraform 生命周期管理。
data "docker_registry_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_image" "nginx" {
  name         = data.docker_registry_image.nginx.name
  keep_locally = true
}

# 这里调用本地子模块。
# `source = "./modules/static_site"` 表示模块代码就在当前目录下。
#
# 你可以先把这一段理解成：
# - 根模块负责准备输入
# - 子模块负责根据输入创建整套静态站点资源
module "site" {
  source = "./modules/static_site"

  image_id            = docker_image.nginx.image_id
  container_name      = local.container_name
  network_name        = local.network_name
  published_port      = var.published_port
  environment_name    = var.environment_name
  site_title          = var.site_title
  site_message        = var.site_message
  environment_summary = local.environment_summary
}

output "project_inputs" {
  value = {
    project_name     = var.project_name
    environment_name = var.environment_name
    published_port   = var.published_port
    site_title       = var.site_title
    site_message     = var.site_message
  }
}

output "project_locals" {
  value = {
    container_name      = local.container_name
    network_name        = local.network_name
    environment_summary = local.environment_summary
  }
}

# 根模块这里直接导出子模块给出的总结结果。
# 这能帮助你看到：
# - 模块不仅能接收输入
# - 也能把结果向外返回
output "site_summary" {
  value = module.site.summary
}
