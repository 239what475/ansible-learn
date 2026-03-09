# 10: terraform and ansible

这一章把两条主线真正接起来：

- `Terraform` 负责创建资源，并导出交接信息
- `Ansible` 负责读取这些交接信息，并继续做后续处理

## 文件

- `main.tf`：Terraform 入口，负责容器、网络和交接文件
- `terraform.tfvars.example`：这一章的环境输入模板
- `ansible/ansible.cfg`：这一章 Ansible 的本地配置
- `ansible/playbooks/consume_terraform.yml`：读取 Terraform 交接文件的示例 playbook
- `.gitignore`：忽略运行目录、状态文件、生成文件和 Ansible 运行产物

## 这一章想建立的直觉

这一章不再讨论“谁更强”，而是明确分工：

- `Terraform`
  - 更适合描述和创建资源
  - 例如：
    - Docker 网络
    - Docker 容器
    - 本地交接文件

- `Ansible`
  - 更适合消费这些结果，再继续做配置、校验、编排

所以这一章的重点不是复杂资源，而是：

- 资源创建后，信息怎么交给 Ansible

## 这一章的交接方式

Terraform apply 成功后，会生成两份文件：

- `generated/inventory.yml`
  - 给 Ansible 一个最小 inventory
- `generated/terraform_vars.yml`
  - 把容器名、网络名、URL、端口这些值交给 Ansible

Ansible 这一章不再自己猜这些值，而是明确读取 Terraform 生成的交接文件。

## 建议顺序

```text
main.tf -> terraform.tfvars.example -> ansible/playbooks/consume_terraform.yml

terraform init
        -> terraform plan -out=chapter10.tfplan -var-file=terraform.tfvars.example
        -> terraform show chapter10.tfplan
        -> terraform apply -auto-approve chapter10.tfplan
        -> terraform output

cd ansible
        -> ../../../.venv/bin/ansible-playbook playbooks/consume_terraform.yml

cd ..
        -> terraform destroy -auto-approve -var-file=terraform.tfvars.example
```

## apply 后你会得到什么

- 一个可运行的 Nginx 容器
- 一个 Docker 网络
- 两份 Terraform 生成的交接文件
- 一份 Ansible 生成的最终报告

这比前一章更像真实项目：

- Terraform 不是只打印输出
- Ansible 也不是凭空执行
- 两者之间有明确的交接边界

## 完成标准

做到下面这些，就可以结束 Terraform 基础主线：

- 你能解释 Terraform 在这一章里创建了什么
- 你能解释 Terraform 给 Ansible 交了哪两份文件
- 你能解释 Ansible 为什么不需要自己再写一份容器名或端口配置
- 你能看懂最终报告里的值来自 Terraform 还是来自 Ansible
