# 这一章先只盯住 `main.tf`，不要急着一开始就把全部 Terraform 语法背下来。
# 这份文件的目标只是帮助你先建立最基本的结构感：
# - `terraform {}`：声明 Terraform 版本要求和 provider 依赖
# - `provider "docker" {}`：告诉 Terraform 这一章要和 Docker 打交道
# - `resource "..." "..." {}`：声明“我希望系统里存在这样的资源”
# - `output`：把 apply 完成后的结果打印出来，方便观察

terraform {
  required_version = ">= 1.5.0"

  # `required_providers` 可以先理解成“这一章依赖哪些 provider”。
  # 这里指定使用 Docker provider，并固定一个大版本范围。
  # `docker_image`、`docker_container` 这类资源类型，本质上就是由这个 Docker provider 插件提供的。
  # 更准确地说：
  # - 是 provider 插件提供资源类型
  # - `provider "docker" {}` 负责配置这个 provider
  # 不是 `provider "docker" {}` 这段代码现场“定义”出这些资源类型。
  required_providers {
    docker = {
      # `source` 表示这个 provider 从哪里下载。
      # `kreuzwerker/docker` 可以先理解成：
      # - `kreuzwerker`：发布者 / namespace
      # - `docker`：provider 名称
      # 它不是 Terraform 核心自带的 HashiCorp 官方 provider，
      # 而是 Terraform Registry 上常见的第三方 Docker provider。
      source  = "kreuzwerker/docker"

      # `~>` 不是简单的“大于”。
      # 它表示“限制在一个兼容范围内升级”。
      # `~> 3.0` 可以先近似理解成：
      # - `>= 3.0`
      # - `< 4.0`
      # 也就是允许使用 `3.x`，但不自动跨到 `4.x`。
      version = "~> 3.0"
    }
  }
}

# `provider "docker" {}` 本身不是资源。
# 它更像是在说：后面这些资源要通过 Docker 这套 API 去管理。
# 这个大括号里就是 provider 自己的配置位置。
# 当前示例之所以留空，是因为本地 Docker 实验可以直接使用默认连接方式。
# 如果后面要显式指定 Docker socket、endpoint、认证信息等，通常就写在这里。
provider "docker" {}

# 如果后面你同时引入多个 provider，不同 provider 可能会各自提供自己的资源类型。
# Terraform 的资源类型名通常会带上 provider 前缀，例如：
# - `docker_image`
# - `docker_container`
# - `aws_instance`
# - `kubernetes_namespace`
# 所以大多数情况下，类型名本身就已经帮助你区分来源。
# 如果真遇到“看起来很像”的类型，也不是靠 `provider "..." {}` 现场切换解析，
# 而是看资源类型名本身属于哪个 provider。

# `resource` 是 Terraform 最核心的概念之一。
# 这里声明的是一个 Docker 镜像资源。
# Terraform 不会在你写下这段配置时立刻去拉镜像，
# 而是先把“期望状态”记录在配置里，等你执行 `plan` / `apply` 再真正处理。
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

# 这里再声明一个容器资源，并引用上面的镜像资源。
# 这能帮助你开始建立“资源之间可以相互引用”的直觉。
# `docker_container.hello_terraform` 这个名字也值得注意：
# - 前半段 `docker_container` 是资源类型
# - 后半段 `hello_terraform` 是这份配置里给它起的本地名字
# 后面引用它时，就会写成 `docker_container.hello_terraform.xxx`
resource "docker_container" "hello_terraform" {
  name  = "hello-terraform"

  # `docker_image.nginx.image_id` 不是字符串，也不是像 Ansible 那样的 magic variable。
  # 它是 Terraform 的“资源属性引用”写法：
  # - `docker_image`：资源类型
  # - `nginx`：这份配置里这个资源的本地名字
  # - `image_id`：这个资源在 apply 后暴露出来的属性
  # 所以这里的意思是：
  # “把前面那个 docker_image.nginx 资源生成出来的 image_id，拿来作为当前容器的 image 值。”
  # 这种写法会让 Terraform 自动建立依赖关系：
  # - 先处理 `docker_image.nginx`
  # - 再处理 `docker_container.hello_terraform`
  image = docker_image.nginx.image_id

  # `ports` 是这个资源里的一个嵌套块。
  # 这里表示把容器内的 80 端口映射到宿主机的 8080。
  ports {
    internal = 80
    external = 8080
  }
}

# `output` 用来把这次 apply 后的结果打印出来。
# 这一章先只把容器名和镜像 ID 暴露出来，方便观察。
# 你可以把它理解成“给当前 Terraform 项目导出一些结果”。
output "container_name" {
  value = docker_container.hello_terraform.name
}

output "image_id" {
  # 这里的 `value = docker_image.nginx.image_id` 也是同样的资源属性引用。
  # Terraform 会在 apply 后把这个资源的 `image_id` 取出来，作为输出结果打印给你。
  value = docker_image.nginx.image_id
}
