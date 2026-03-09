# 08: environments and tfvars

这一章只聚焦两件事：

- 同一份 Terraform 配置，怎么服务多个环境
- `tfvars` 文件怎么把环境差异从 `main.tf` 里拆出去

## 文件

- `main.tf`：这一章的完整示例
- `environments/dev.tfvars.example`：开发环境示例值
- `environments/prod.tfvars.example`：生产环境示例值
- `.gitignore`：忽略运行目录、状态文件和本地实际环境文件

## 前提

- `terraform version` 可以正常运行
- `docker version` 可以正常运行
- 当前用户能连接到 Docker daemon

## 这一章的重点

这一章不再用 `-var='a=b'` 这种临时覆盖做主线，而是改成：

- 在 `main.tf` 里声明变量和资源结构
- 在环境文件里放每个环境自己的实际值
- 用 `-var-file=...` 选择当前要应用哪一个环境

这更接近后面真实项目的工作方式：

- 配置主体尽量稳定
- 环境差异放进单独文件

## 建议顺序

```text
main.tf -> environments/dev.tfvars.example -> environments/prod.tfvars.example 

terraform init 
        -> terraform plan -out=dev.tfplan -var-file=environments/dev.tfvars.example 
        -> terraform show dev.tfplan 
        -> terraform apply -auto-approve dev.tfplan 
        -> terraform output 
        -> terraform destroy -auto-approve
```

然后再重复一遍 `prod`：

```text
terraform plan -out=prod.tfplan -var-file=environments/prod.tfvars.example 
        -> terraform show prod.tfplan 
        -> terraform apply -auto-approve prod.tfplan 
        -> terraform output 
        -> terraform destroy -auto-approve
```

## 这一章你会看到什么

同一份 `main.tf` 不变，但：

- `environment_name`
- `container_name`
- `published_port`
- `container_message`

会随着不同的 `tfvars` 文件变成不同的值。

也就是说：

- `dev` 和 `prod` 的差异，不是靠改资源代码本身
- 而是靠切换环境文件

## `dev.tfvars.example` / `prod.tfvars.example` 是怎么用的

这两个文件只是模板文件，不会自动生效。

你有两种常见用法：

- 直接显式指定：
  - `terraform plan -var-file=environments/dev.tfvars.example`
- 或复制成你自己的本地实际文件：
  - `cp environments/dev.tfvars.example environments/dev.tfvars`
  - 再用：
    - `terraform plan -var-file=environments/dev.tfvars`

这一章特意继续保留 `.example` 结尾，是因为：

- 你后面很可能会按自己的环境改值
- 模板应该进 Git
- 本地实际环境文件不应该直接提交

## 这一章还想建立一个直觉

`tfvars` 文件本质上不是“另一套 Terraform 代码”，而是：

- 同一套变量声明的不同取值

所以：

- `main.tf` 里定义结构
- `tfvars` 文件只负责填值

## 完成标准

做到下面这些，就可以进入下一章：

- 你知道为什么同一份 `main.tf` 能同时服务 `dev` 和 `prod`
- 你能解释 `-var-file` 为什么比大量 `-var` 更适合长期维护
- 你能通过切换环境文件看出输出结果如何变化
