# 04: functions and expressions

这一章只聚焦三件事：

- 常见函数怎么用
- 条件表达式怎么写
- `for` 表达式怎么把一个集合转成另一个集合

## 文件

- `main.tf`：这一章的完整示例
- `.gitignore`：忽略运行目录、状态文件和本地实验产物

## 前提

- `terraform version` 可以正常运行
- `docker version` 可以正常运行
- 当前用户能连接到 Docker daemon

## 这一章想建立的直觉

先只记这几句话：

- 函数
  - 用来整理输入值
- 条件表达式
  - 用来在两个值之间做选择
- `for` 表达式
  - 用来把一个列表或 map 转成另一种结构

## 建议顺序

```text
main.tf -> terraform init -> terraform plan -out=chapter04.tfplan -> terraform show chapter04.tfplan -> terraform apply -auto-approve chapter04.tfplan -> terraform output -> terraform destroy -auto-approve
```

## 这一章会碰到哪些函数

这份示例里故意只选了几类最常见的函数：

- 字符串处理
  - `lower(...)`
  - `replace(...)`
  - `format(...)`
  - `upper(...)`

- 列表处理
  - `distinct(...)`
  - `sort(...)`
  - `join(...)`
  - `concat(...)`

## 这一章会碰到哪些表达式

- 条件表达式
  - `条件 ? 真值 : 假值`
- `for` 表达式
  - `[for x in list : ...]`

## 这一章为什么不再放 `tfvars` 模板

这一章的重点是：

- 函数
- 条件表达式
- `for` 表达式

不是输入文件管理。

所以这一章直接把“更适合观察变化”的值写进了 `default`，例如：

- 项目名里带大写和下划线
- 环境名是大写
- 标签里有重复项
- `name_suffix` 非空

这样你在执行完 `plan` / `apply` 后，仍然能直观看到：

- `lower(...)` 把值整理成小写
- `replace(...)` 把 `_` 变成 `-`
- `distinct(...)` 去掉重复标签
- `sort(...)` 让输出顺序更稳定
- 条件表达式把 `name_suffix` 拼进最终容器名

## 学习时建议重点观察什么

建议重点看两组输出：

- `expression_summary`
  - 看“输入值经过函数和表达式后变成了什么”
- `resource_summary`
  - 看“最终真正喂给资源的值是什么”

## 完成标准

做到下面这些，就可以进入下一章：

- 你能解释 `lower`、`replace`、`distinct`、`sort`、`join` 大概在干什么
- 你能读懂 `条件 ? 真值 : 假值`
- 你能读懂 `[for tag in local.normalized_tags : ...]`
- 你知道为什么 Terraform 里很适合先用 `locals` 整理值，再交给资源使用
