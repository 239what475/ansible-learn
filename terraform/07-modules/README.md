# 07: modules

这一章只聚焦一件事：

- 怎么把一段 Terraform 配置抽成可复用模块

## 文件

- `main.tf`：这一章的根模块入口
- `modules/web_container/main.tf`：本地子模块示例
- `.gitignore`：忽略运行目录、状态文件和本地实验产物

## 前提

- `terraform version` 可以正常运行
- `docker version` 可以正常运行
- 当前用户能连接到 Docker daemon

## 这一章想建立的直觉

先只记下面四句话：

- 根目录里的配置，本身也是一个模块
  - 只是通常叫“root module”
- `module "xxx" {}` 表示调用一个子模块
- 子模块通过输入变量接收参数
- 子模块通过 `output` 把结果暴露给外层

## 建议顺序

```text
main.tf -> modules/web_container/main.tf -> terraform init -> terraform fmt -> terraform validate -> terraform plan -out=chapter07.tfplan -> terraform show chapter07.tfplan -> terraform apply -auto-approve chapter07.tfplan -> terraform state list -> terraform output -> terraform destroy -auto-approve
```

## 这一章会看到什么

- 根模块里先创建一个共享镜像资源：
  - `docker_image.nginx`
- 然后用同一个模块调用两次：
  - `module.blue`
  - `module.green`
- 每次传不同的输入值：
  - 不同容器名
  - 不同网络名
  - 不同端口

## 这一章建议重点观察什么

建议重点观察三件事：

- `module "blue"` 和 `module "green"` 的输入值怎么不同
- `terraform state list`
  - 看资源地址前面会带：
    - `module.blue`
    - `module.green`
- `terraform output`
  - 看根模块如何读取：
    - `module.blue.summary`
    - `module.green.summary`

## 关于模块

这一章里的：

- `main.tf`

是 root module。

而这里：

- `modules/web_container/main.tf`

是本地子模块。

根模块通过：

```hcl
module "blue" {
  source = "./modules/web_container"
  ...
}
```

来调用它。

这里的 `source` 先只理解成：

- 模块代码放在哪

当前这一章用的是本地路径模块，所以写的是：

- `./modules/web_container`

## 关于为什么这一章复用两次

如果只调用一次模块，你只能看到：

- 模块可以“被调用”

但看不太出“复用”这件事。

这一章故意调用两次：

- `module.blue`
- `module.green`

是为了让你更直观地看到：

- 同一份模块代码
- 可以通过不同输入值
- 创建出两套不同资源

## 完成标准

做到下面这些，就可以进入下一章：

- 你能解释 root module 和 child module 的区别
- 你知道 `source` 是干什么的
- 你知道模块输入和模块输出分别落在哪里
- 你能看懂 `module.blue.xxx` 这种引用是什么意思
