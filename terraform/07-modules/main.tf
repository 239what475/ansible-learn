# 这一章开始把“能跑通一份配置”推进到“能复用一份配置”。
#
# 先抓两个关键概念：
# - 当前目录里的 `main.tf`，本身就是 root module
# - `modules/web_container/main.tf` 是被调用的 child module
#
# 这一章不急着讲远程模块仓库，先只用本地模块路径。

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

# 这一章先把镜像资源留在 root module 里统一创建。
# 这样子模块只关心：
# - 网络
# - 容器
#
# 同时这也能说明：
# - 模块不一定要把所有东西都包进去
# - 也可以把共享资源留在外层，再把结果作为输入传给模块
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

# 这里第一次调用本地模块。
# `source = "./modules/web_container"` 表示：
# - 模块代码就在当前目录下的 `modules/web_container`
#
# `blue` 是这次调用的本地名字，
# 所以后面根模块里可以写：
# - `module.blue.summary`
module "blue" {
  source = "./modules/web_container"

  image_id       = docker_image.nginx.image_id
  container_name = "terraform-module-blue"
  network_name   = "terraform-module-blue-network"
  published_port = 18087
}

# 同一个模块第二次调用。
# 这里最想让你看到的是：
# - Terraform 模块像“可复用配置单元”
# - 同一份模块代码，可以靠不同输入值生成另一套资源
module "green" {
  source = "./modules/web_container"

  image_id       = docker_image.nginx.image_id
  container_name = "terraform-module-green"
  network_name   = "terraform-module-green-network"
  published_port = 18088
}

# 根模块可以直接读取子模块输出。
# 这里的：
# - `module.blue.summary`
# - `module.green.summary`
#
# 就是“通过模块输出把内部结果暴露到外面”。
output "blue_summary" {
  value = module.blue.summary
}

output "green_summary" {
  value = module.green.summary
}
