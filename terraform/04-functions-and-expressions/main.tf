# 这一章聚焦 `Terraform` 里的函数和表达式。
# 目标不是把函数背全，而是先建立三个直觉：
# - 可以用函数把原始输入整理得更适合资源使用
# - 可以用条件表达式在不同值之间做选择
# - 可以用 `for` 表达式把一个集合转换成另一个集合

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
  description = "原始项目名，故意允许大小写和下划线，方便演示字符串处理"
  type        = string
  default     = "Terraform_Functions_From_Defaults"
}

variable "environment_name" {
  description = "环境名，后面会统一整理成小写"
  type        = string
  default     = "TEST"
}

variable "name_suffix" {
  description = "可选后缀，用来演示条件表达式"
  type        = string
  default     = "demo"
}

variable "published_port" {
  description = "把容器内 80 端口映射到宿主机的哪个端口"
  type        = number
  default     = 18084
}

variable "enable_debug" {
  description = "是否打开调试模式，用来演示布尔条件表达式"
  type        = bool
  default     = false
}

variable "extra_tags" {
  description = "一组示例标签，用来演示列表函数和 for 表达式"
  type        = list(string)
  default     = ["ops", "demo", "ops", "web"]
}

locals {
  # `lower(...)`：转成小写。
  # `replace(...)`：把字符串中的某一部分替换掉。
  # 这里故意把原始项目名里的 `_` 替换成 `-`，再统一转小写。
  normalized_project_name = lower(replace(var.project_name, "_", "-"))

  # 这里再演示一次 `lower(...)`。
  normalized_environment = lower(var.environment_name)

  # `distinct(...)`：去重。
  # `sort(...)`：排序。
  # 这两个放一起用，很适合把一个“乱一点的输入列表”整理成更稳定的结果。
  normalized_tags = sort(distinct(var.extra_tags))

  # 这里用最基础的字符串插值拼出一个基础名字。
  base_container_name = "${local.normalized_project_name}-${local.normalized_environment}"

  # 条件表达式的形式是：
  # - `条件 ? 条件为真时的值 : 条件为假时的值`
  # 这一句表示：
  # - 如果 `name_suffix` 不是空字符串，就把它拼到名字后面
  # - 否则就只使用基础名字
  container_name = var.name_suffix != "" ? "${local.base_container_name}-${var.name_suffix}" : local.base_container_name

  # 这里同样是条件表达式。
  debug_mode_text = var.enable_debug ? "enabled" : "disabled"

  # `join(",", 列表)`：把列表拼成字符串。
  tag_summary = join(",", local.normalized_tags)

  # `format(...)` 可以先理解成“按格式模板组装字符串”。
  endpoint = format("http://localhost:%d", var.published_port)

  # `for` 表达式可以把一个列表变成另一个列表。
  # 这里把：
  # - ["demo", "web"]
  # 转成：
  # - ["TAG_DEMO=true", "TAG_WEB=true"]
  generated_tag_env = [for tag in local.normalized_tags : "TAG_${upper(tag)}=true"]

  # `concat(...)`：把多个列表拼成一个列表。
  container_env = concat(
    [
      "PROJECT_NAME=${local.normalized_project_name}",
      "ENVIRONMENT_NAME=${local.normalized_environment}",
      "DEBUG_MODE=${local.debug_mode_text}",
      "TAG_SUMMARY=${local.tag_summary}",
    ],
    local.generated_tag_env
  )
}

resource "docker_image" "nginx" {
  name = "nginx:latest"

  # 这一章的重点是函数和表达式，不是镜像清理策略。
  # `keep_locally = true` 表示：
  # - `destroy` 时不强制删除宿主机本地的镜像文件
  # 这样在“同一台机器上还有别的容器也在用 nginx:latest”时，
  # 当前章节的 `destroy` 不会因为镜像删除冲突而失败。
  keep_locally = true
}

resource "docker_container" "demo" {
  name  = local.container_name
  image = docker_image.nginx.image_id
  env   = local.container_env

  ports {
    internal = 80
    external = var.published_port
  }
}

# 这一组输出帮助你观察“输入值经过函数和表达式整理后变成了什么”。
output "expression_summary" {
  value = {
    raw_project_name        = var.project_name
    normalized_project_name = local.normalized_project_name
    raw_environment_name    = var.environment_name
    normalized_environment  = local.normalized_environment
    normalized_tags         = local.normalized_tags
    generated_tag_env       = local.generated_tag_env
    debug_mode_text         = local.debug_mode_text
    tag_summary             = local.tag_summary
    endpoint                = local.endpoint
  }
}

# 这一组输出帮助你观察“最终喂给资源”的值。
output "resource_summary" {
  value = {
    container_name = docker_container.demo.name
    published_port = var.published_port
    container_env  = local.container_env
  }
}
