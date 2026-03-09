# Terraform 安装

当前这份文档默认以 `Ubuntu / Debian` 为例，优先使用官方 `apt` 源安装。
下面三条命令和 HashiCorp 官方安装页保持一致。

## 安装

```bash
# 如果之前已经添加过 HashiCorp keyring，先删掉旧文件，避免 gpg 在覆盖时卡住。
sudo rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg

# 下载 HashiCorp 的 GPG 公钥，并转成 apt 能使用的 keyring 文件。
wget -O - https://apt.releases.hashicorp.com/gpg | \
  sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# 写入 HashiCorp 官方 apt 源。
# `dpkg --print-architecture` 会自动带上当前 CPU 架构；
# `grep ... /etc/os-release || lsb_release -cs` 会自动取当前 Ubuntu / Debian 发行版代号。
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

# 刷新软件源索引，并安装 Terraform。
sudo apt update && sudo apt install terraform
```

如果你已经安装过，可以直接跳到下面的“验证”部分。

如果系统提示找不到 `wget` 或 `gpg`，再补装：

```bash
sudo apt update && sudo apt install -y wget gpg
```

## 如果安装时卡住

如果你在这一步卡住：

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

最常见的原因是：

- `/usr/share/keyrings/hashicorp-archive-keyring.gpg` 已经存在
- `gpg` 正在等待是否覆盖旧文件

上面的安装命令里已经通过这两个动作避免了这个问题：

- 先执行 `sudo rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg`
- 再给 `gpg` 加上 `--yes`

## 验证

先确认 `terraform` 已经在当前终端可用：

```bash
# 查看 Terraform 版本，确认命令已经安装并进入 PATH。
terraform version
```

这条命令能正常输出版本，就说明命令已经安装并且已经进入 `PATH`。

## 先认识的基础命令

这几条命令现在先只要认识，不需要一次全理解：

```bash
terraform -help
terraform fmt -help
terraform validate -help
terraform init -help
terraform plan -help
terraform apply -help
terraform destroy -help
```

可以先把它们理解成：

- `fmt`
  - 格式化配置文件
- `validate`
  - 检查配置语法和基本有效性
- `init`
  - 初始化当前工作目录
- `plan`
  - 预览接下来要做的变更
- `apply`
  - 真正执行这些变更
- `destroy`
  - 销毁当前配置创建出来的资源
