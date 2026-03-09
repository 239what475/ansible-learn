# 09: mini project

这一章把前面学过的几块内容串起来，做一个完整的小项目。

## 文件

- `main.tf`：根模块，负责声明 provider、共享镜像和模块调用
- `modules/static_site/main.tf`：子模块，负责网络、容器和页面内容
- `modules/static_site/templates/index.html.tftpl`：站点首页模板
- `environments/dev.tfvars.example`：开发环境示例值
- `environments/prod.tfvars.example`：生产环境示例值
- `.gitignore`：忽略运行目录、状态文件和本地实际环境文件

## 前提

- `terraform version` 可以正常运行
- `docker version` 可以正常运行
- 当前用户能连接到 Docker daemon

## 这一章想做什么

这一章不再只盯单个语法点，而是做一个能真正跑起来的小项目：

- 根模块负责公共部分
  - provider
  - 共享镜像
  - 环境输入
- 子模块负责站点本身
  - Docker 网络
  - Nginx 容器
  - 页面模板渲染

你可以把它先理解成一个最小的 Terraform 项目骨架。

## 这一章会用到前面哪些内容

- `provider`
- `resource`
- `variable`
- `locals`
- `output`
- `data source`
- `module`
- `tfvars`

所以这章的重点不是新语法数量，而是把前面零散知识串起来。

## 建议顺序

```text
main.tf -> modules/static_site/main.tf -> modules/static_site/templates/index.html.tftpl -> environments/dev.tfvars.example -> environments/prod.tfvars.example

terraform init
        -> terraform plan -out=dev.tfplan -var-file=environments/dev.tfvars.example
        -> terraform show dev.tfplan
        -> terraform apply -auto-approve dev.tfplan
        -> terraform output
        -> terraform destroy -auto-approve -var-file=environments/dev.tfvars.example
```

然后再重复一遍 `prod`：

```text
terraform plan -out=prod.tfplan -var-file=environments/prod.tfvars.example
        -> terraform show prod.tfplan
        -> terraform apply -auto-approve prod.tfplan
        -> terraform output
        -> terraform destroy -auto-approve -var-file=environments/prod.tfvars.example
```

## 这一章你会看到什么

同一个子模块会根据环境文件生成不同结果：

- `dev`
  - 容器名不同
  - 网络名不同
  - 对外端口不同
  - 页面标题和消息不同

- `prod`
  - 同一份模块逻辑不变
  - 只是输入值换成另一套

这就是 Terraform 项目里“配置结构稳定、环境差异外置”的一个最小例子。

## apply 后怎么访问页面

只要这一章的 `terraform apply` 已经成功，并且你还没有执行 `terraform destroy`，就可以直接访问页面：

- `dev`
  - `http://localhost:18101`
- `prod`
  - `http://localhost:18102`

也可以先用命令确认：

```bash
curl http://localhost:18101
curl http://localhost:18102
```

这里的前提是：

- Terraform 和 Docker 都运行在你当前这台机器上
- 你访问的是宿主机映射端口，不是容器内部端口

如果 Terraform 不是在本机跑，而是在另一台宿主机上跑，那就不要用 `localhost`，而是改成那台宿主机的 IP。

## 这一章还想建立一个直觉

根模块和子模块的分工可以先这样看：

- 根模块
  - 决定项目入口长什么样
  - 统一 provider
  - 统一共享资源
  - 选择当前环境值

- 子模块
  - 做一件具体的事情
  - 接受输入
  - 创建资源
  - 导出结果

这里的 `static_site` 子模块就是：

- 给定镜像 ID、容器名、端口、页面文案
- 生成一个可运行的静态站点容器

## 完成标准

做到下面这些，就可以进入下一章：

- 你知道这章为什么要拆成根模块和子模块
- 你能解释为什么 `dev` / `prod` 只换 `tfvars` 文件就能得到不同结果
- 你能看懂模块输出里的站点 URL、容器名和网络名来自哪里
