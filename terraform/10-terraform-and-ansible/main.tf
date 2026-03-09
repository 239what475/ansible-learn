# 这一章演示 Terraform 和 Ansible 的一个最小交接流程：
# 1. Terraform 创建容器和网络
# 2. Terraform 生成一份 inventory 和一份变量文件
# 3. Ansible 读取这些文件，再继续做后续处理

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "docker" {}
provider "local" {}

variable "project_name" {
  description = "项目名，会参与容器和网络命名"
  type        = string
  default     = "terraform-ansible-demo"
}

variable "environment_name" {
  description = "环境名"
  type        = string
  default     = "dev"
}

variable "published_port" {
  description = "容器对外映射端口"
  type        = number
  default     = 18110
}

variable "site_title" {
  description = "首页标题"
  type        = string
  default     = "Terraform + Ansible Demo"
}

variable "site_message" {
  description = "首页消息"
  type        = string
  default     = "hello from terraform"
}

locals {
  container_name = "${var.project_name}-${var.environment_name}"
  network_name   = "${var.project_name}-${var.environment_name}-network"
  site_url       = "http://localhost:${var.published_port}"
  generated_dir  = "${path.module}/generated"

  # 这里把要交给 Ansible 的值先整理成一个 map。
  # 后面再用 `yamlencode(...)` 写成本地 YAML 文件。
  ansible_handoff = {
    terraform_project_name     = var.project_name
    terraform_environment_name = var.environment_name
    terraform_container_name   = local.container_name
    terraform_network_name     = local.network_name
    terraform_site_url         = local.site_url
    terraform_published_port   = var.published_port
  }
}

resource "docker_image" "nginx" {
  # 这一章的重点是 Terraform 和 Ansible 的交接，不是 data source。
  # 这里直接声明镜像资源，避免 `destroy` 时再额外访问 Docker Registry。
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_network" "site" {
  name = local.network_name
}

resource "docker_container" "site" {
  name  = local.container_name
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.published_port
  }

  # 这里直接把首页内容写进 Nginx 默认站点目录，
  # 让后面的 Ansible 可以直接消费这个站点 URL。
  upload {
    file    = "/usr/share/nginx/html/index.html"
    content = <<-EOT
      <!doctype html>
      <html lang="zh-CN">
        <head>
          <meta charset="utf-8" />
          <title>${var.site_title}</title>
        </head>
        <body>
          <h1>${var.site_title}</h1>
          <p>${var.site_message}</p>
          <ul>
            <li>environment = ${var.environment_name}</li>
            <li>container_name = ${local.container_name}</li>
            <li>site_url = ${local.site_url}</li>
          </ul>
        </body>
      </html>
    EOT
  }

  networks_advanced {
    name = docker_network.site.name
  }
}

# 这份 inventory 是 Terraform 明确交给 Ansible 的第一份文件。
# 这里先用最小可运行形式，只让 Ansible 管理 localhost。
resource "local_file" "ansible_inventory" {
  filename = "${local.generated_dir}/inventory.yml"
  content  = <<-EOT
    all:
      hosts:
        localhost:
          ansible_connection: local
  EOT
}

# 这份变量文件是第二份交接文件。
# Terraform 把已经确定下来的资源信息写进去，Ansible 直接读，不自己重复计算。
resource "local_file" "ansible_vars" {
  filename = "${local.generated_dir}/terraform_vars.yml"
  content  = <<-EOT
    terraform_project_name: ${local.ansible_handoff.terraform_project_name}
    terraform_environment_name: ${local.ansible_handoff.terraform_environment_name}
    terraform_container_name: ${local.ansible_handoff.terraform_container_name}
    terraform_network_name: ${local.ansible_handoff.terraform_network_name}
    terraform_site_url: ${local.ansible_handoff.terraform_site_url}
    terraform_published_port: ${local.ansible_handoff.terraform_published_port}
  EOT
}

output "terraform_summary" {
  value = {
    container_name = docker_container.site.name
    network_name   = docker_network.site.name
    site_url       = local.site_url
    inventory_file = local_file.ansible_inventory.filename
    vars_file      = local_file.ansible_vars.filename
  }
}
