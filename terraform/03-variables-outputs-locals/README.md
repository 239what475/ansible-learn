# 03: variables outputs locals

这一章只聚焦三件事：

- `variable`：输入从哪里来
- `locals`：中间值怎么整理
- `output`：最终结果怎么导出

## 文件

- `main.tf`：这一章的完整示例
- `terraform.tfvars.example`：一份示例变量文件
- `.gitignore`：忽略运行目录、状态文件和本地 `terraform.tfvars`

## 前提

- `terraform version` 可以正常运行
- `docker version` 可以正常运行
- 当前用户能连接到 Docker daemon

## 这一章想建立的直觉

先只记下面三句话：

- `variable`
  - 是这份配置对外暴露的输入参数
- `locals`
  - 是配置内部整理出来的中间值
- `output`
  - 是把最终结果导出来，方便观察或继续复用

## 建议顺序

```text
main.tf -> terraform.tfvars.example -> terraform init -> terraform plan -var-file=terraform.tfvars.example -> terraform apply -auto-approve -var-file=terraform.tfvars.example -> terraform output -> terraform destroy -auto-approve -var-file=terraform.tfvars.example
```

## 这一章你会看到什么

这一章里故意把值分成三层：

- 输入变量
  - `var.project_name`
  - `var.environment_name`
  - `var.container_port`
  - `var.base_message`

- locals 中间值
  - `local.container_name`
  - `local.full_message`
  - `local.container_url`

- 资源运行结果
  - `docker_container.demo.name`
  - `docker_image.nginx.image_id`

这样你看 `output` 时，就能直接区分：

- 哪些值是你输入的
- 哪些值是配置里拼出来的
- 哪些值是资源真正创建后拿到的

## `terraform.tfvars.example` 是做什么的

`terraform.tfvars.example` 只是模板文件，不会自动生效。

你有两种常见用法：

- 直接显式指定：
  - `terraform plan -var-file=terraform.tfvars.example`
- 复制成本地实际文件：
  - `cp terraform.tfvars.example terraform.tfvars`
  - 然后直接运行 `terraform plan`

如果目录里存在 `terraform.tfvars`，Terraform 通常会自动加载它。

这一章的示例模板里，值故意写得和 `main.tf` 里的默认值不一样：

- `project_name = "terraform-demo-from-tfvars"`
- `environment_name = "test"`
- `container_port = 18082`
- `base_message = "managed by tfvars"`

这样你在执行：

- `terraform plan -var-file=terraform.tfvars.example`

时，就能更直观地看出：

- `var.xxx` 已经不再使用 `default`
- 而是改用 `tfvars` 文件里提供的值

## 这一章再多看一个点：为什么要有 locals

如果没有 `locals`，你当然也可以直接把表达式写在资源里。

例如：

- 直接在容器名里写字符串拼接
- 直接在输出里重复写完整 URL

但这样会有两个问题：

- 表达式重复出现，后面不好改
- 读配置时，不容易一眼看出“这个最终值想表达什么”

所以 `locals` 的主要价值是：

- 把重复表达式收拢起来
- 给中间值起更清楚的名字

这里再补一个很重要的边界：

- `variable`
  - 可以被 `default`、`terraform.tfvars`、`-var` 这些外部输入赋值
- `locals`
  - 不是外部输入
  - 不能像 `variable` 那样被 `tfvars` 直接覆盖
  - 它的值来自你在配置里写的表达式

也就是说：

- 你不会直接给 `local.container_name` 传值
- 你只能通过改变它依赖的输入，例如：
  - `var.project_name`
  - `var.environment_name`
- 间接让 `local.container_name` 变掉

## 完成标准

做到下面这些，就可以进入下一章：

- 你能解释 `var.xxx`、`local.xxx`、`output` 分别表示什么
- 你知道 `terraform.tfvars` 和 `-var-file` 的作用
- 你能看懂为什么 `local.container_name` 不是用户直接输入，而是中间整理值
- 你能通过 `terraform output` 看懂输出结果来自哪一层
