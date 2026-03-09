# 安装 kubectl

这一节只做两件事：

- 在当前机器上安装 `kubectl`
- 确认本机已经具备后续操作 `Kubernetes` 集群的命令行工具

## Linux 安装

下面这组命令采用 `Kubernetes` 官方文档里的二进制安装方式：

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

### 每行命令的作用

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

- 内层 `curl -L -s https://dl.k8s.io/release/stable.txt`
  - 先读取当前稳定版 `kubectl` 版本号
- 外层 `curl -LO ...`
  - 再按这个版本号下载对应的 Linux `amd64` 二进制文件
- 下载完成后，当前目录里会出现一个名为 `kubectl` 的可执行文件

```bash
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

- 把刚才下载的 `kubectl` 安装到系统命令目录：
  - `/usr/local/bin/kubectl`
- `-o root -g root`
  - 设置文件属主和属组为 `root`
- `-m 0755`
  - 设置文件权限，让系统里的普通用户也可以执行这个命令

## 验证

确认客户端版本可用：

```bash
kubectl version --client
```

如果你想进一步确认命令帮助也正常：

```bash
kubectl get --help
kubectl explain pod
```

## 说明

- 当前阶段只安装 `kubectl` 客户端，不会自动安装集群
- 后续章节默认会让 `kubectl` 去连接本机 `minikube` 实验集群
- 这一节的安装步骤参考 `Kubernetes` 官方文档：
  - `https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/`
