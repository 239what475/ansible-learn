# 这是子模块本体。
# 你可以把它理解成一个“静态站点部署模块”：
# - 输入：镜像、名字、端口、页面文案
# - 资源：网络 + 容器
# - 输出：站点 URL 和运行摘要

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

variable "image_id" {
  description = "根模块传入的镜像 ID"
  type        = string
}

variable "container_name" {
  description = "站点容器名"
  type        = string
}

variable "network_name" {
  description = "站点容器要加入的 Docker 网络名"
  type        = string
}

variable "published_port" {
  description = "站点对外发布端口"
  type        = number
}

variable "environment_name" {
  description = "环境名，写进模板里方便观察"
  type        = string
}

variable "site_title" {
  description = "首页标题"
  type        = string
}

variable "site_message" {
  description = "首页消息"
  type        = string
}

variable "environment_summary" {
  description = "根模块整理好的环境摘要"
  type        = string
}

locals {
  # 这里用 `templatefile` 函数加载模板文件并渲染成 HTML 文本。
  # 你可以先把它理解成 Terraform 版的“模板渲染”。
  index_html = templatefile("${path.module}/templates/index.html.tftpl", {
    site_title          = var.site_title
    site_message        = var.site_message
    environment_name    = var.environment_name
    environment_summary = var.environment_summary
    container_name      = var.container_name
  })

  site_url = "http://localhost:${var.published_port}"
}

resource "docker_network" "site" {
  name = var.network_name
}

resource "docker_container" "site" {
  name  = var.container_name
  image = var.image_id

  ports {
    internal = 80
    external = var.published_port
  }

  # `upload {}` 会把内容直接写进容器文件系统。
  # 这里用它覆盖 Nginx 默认首页，方便你直接看到环境差异。
  upload {
    content = local.index_html
    file    = "/usr/share/nginx/html/index.html"
  }

  networks_advanced {
    name = docker_network.site.name
  }
}

output "summary" {
  value = {
    container_name = docker_container.site.name
    container_id   = docker_container.site.id
    network_name   = docker_network.site.name
    published_port = var.published_port
    site_url       = local.site_url
  }
}
