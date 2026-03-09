# 01: init / plan / apply / destroy

这一章的目标很单纯：

- 先跑通一个最小 `Terraform` 项目
- 理解 `init`、`plan`、`apply`、`destroy` 这四个最核心命令
- 先建立“声明资源 -> 预览变更 -> 应用变更 -> 销毁资源”的基本节奏

## 文件

- `main.tf`：这一章的最小示例配置
- `.gitignore`：忽略这一章运行时生成的目录和状态文件

## 前提

这一章默认使用 `Docker provider` 做本地实验。

你至少需要满足：

- `terraform version` 可以正常运行
- `docker version` 可以正常运行
- 当前用户能连接到 Docker daemon

如果 `docker version` 只有客户端信息、没有服务端信息，说明 Docker daemon 当前不可用，先不要继续这一章。

## 建议顺序

```text
main.tf -> terraform init -> terraform plan -> terraform apply -> terraform destroy
```

## 先看 `main.tf`

这一章的配置只做三件事：

- 声明 `docker` provider
- 声明一个 `nginx` 镜像资源
- 声明一个基于这个镜像的容器资源

这里最重要的不是 Docker 本身，而是先看懂 `Terraform` 的基本组织方式：

- `terraform {}`：声明版本和 provider 依赖
- `provider "docker" {}`：告诉 Terraform 这一章要跟 Docker 打交道
- `resource "..." "..." {}`：声明“我希望系统里有这样一个资源”
- `output`：把 apply 后的结果展示出来

## 1. 初始化目录

在这一章目录里运行：

```bash
terraform init
```

这一步会做这些事：

- 下载当前配置需要的 provider
- 初始化 `.terraform/` 目录
- 生成或更新 `.terraform.lock.hcl`

可以先把 `init` 理解成：

- “让这个目录进入可工作的 Terraform 状态”

## 2. 预览变更

```bash
terraform plan
```

这一步不会真正创建资源，而是先告诉你：

- 当前状态下，Terraform 认为需要创建什么
- 这次计划里有哪些资源会被新增、修改或删除

这一章第一次运行时，你应该能看到：

- 一个 `docker_image.nginx`
- 一个 `docker_container.hello_terraform`

第一次看 `plan` 输出时，建议先把内容分成三类：

- 你自己在 `main.tf` 里显式写的值
  - 比如：
    - `name = "nginx:latest"`
    - `name = "hello-terraform"`
    - `ports.internal = 80`
    - `ports.external = 8080`

- provider / 资源类型自动补上的默认值
  - 比如：
    - `must_run = true`
    - `start = true`
    - `logs = false`
    - `network_mode = "bridge"`
  - 这些通常不是你手写的，而是 Docker provider 默认会这样处理

- 只有真正创建资源后才能知道的值
  - plan 里会显示成：
    - `(known after apply)`
  - 比如：
    - `id`
    - `hostname`
    - `image_id`
    - `repo_digest`
  - 这类值要等 `apply` 完成后，Terraform 才能从 Docker 拿到真实结果

学习阶段先重点盯这三处：

- 资源类型和资源名
  - `docker_image.nginx`
  - `docker_container.hello_terraform`
- 你自己手写的关键字段
- 最后一行总结
  - `Plan: 2 to add, 0 to change, 0 to destroy`

这里顺手记一个概念：`refresh`

- 你可能会在 Terraform 资料里看到 `terraform refresh`
- 这个词更重要的地方在于“状态刷新”这个概念
- 可以先理解成：
  - Terraform 去真实环境重新读取资源状态
  - 再把这些结果和本地 state 对齐

当前阶段不需要把 `refresh` 当成这一章的主命令去背。
更重要的是理解：

- `plan`
- `apply`

这些主命令背后，本来就会涉及“重新读取真实资源状态并计算差异”这件事。

## 3. 应用变更

```bash
terraform apply
```

如果你不想每次都手工确认，也可以用：

```bash
terraform apply -auto-approve
```

这一步会真正去做 `plan` 里展示的事情：

- 拉取镜像
- 创建容器
- 写入本地状态文件 `terraform.tfstate`

apply 完成后，你还可以额外检查：

```bash
docker ps --filter name=hello-terraform
```

如果容器已经创建成功，你应该能看到名为 `hello-terraform` 的容器。

## 4. 销毁资源

```bash
terraform destroy
```

如果你不想手工确认，也可以用：

```bash
terraform destroy -auto-approve
```

这一步会根据状态文件，反向删除这一章创建出来的资源。

destroy 完成后，你可以再检查一次：

```bash
docker ps -a --filter name=hello-terraform
```

如果销毁成功，这个容器应该已经不存在。

## 这一章里几个运行产物的意义

- `.terraform/`
  - 当前目录的 Terraform 工作目录
- `.terraform.lock.hcl`
  - provider 依赖锁文件
- `terraform.tfstate`
  - Terraform 用来记录资源状态的本地 state 文件

这一章里：

- `.terraform/` 和 `terraform.tfstate` 不提交
- `.terraform.lock.hcl` 保留到版本控制里，帮助固定 provider 版本选择

## 完成标准

做到下面这些，就可以进入下一章：

- 你知道 `main.tf` 里 `terraform` / `provider` / `resource` / `output` 各自是干什么的
- `terraform init` 能正常完成
- `terraform plan` 能看懂它准备创建什么
- `terraform apply` 能真正创建出本地 Docker 资源
- `terraform destroy` 能把这一章创建的资源清掉
