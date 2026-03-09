# 安装和启动 minikube

这一节用 `minikube` 做本地 `Kubernetes` 实验环境，不再自己搭 `Incus + kubeadm` 集群。

当前默认建议：

- 本机已经安装好 `Docker`
- `minikube` 使用：
  - `--driver=docker`
  - `--nodes 3`

这样后续实验会直接得到一套更接近真实结构的本地集群：

- `1` 个 control-plane
- `2` 个 worker

## 安装

下面这组命令采用 `minikube` 官方 Linux 二进制安装方式：

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### 每行命令的作用

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
```

- 下载最新的 `minikube` Linux 可执行文件。

```bash
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

- 把刚才下载的文件安装到系统命令目录。
- 安装完成后就可以直接执行：
  - `minikube`

## 启动集群

这一节默认使用 `Docker driver`：

```bash
minikube start --driver=docker --nodes 3
```

### 这条命令的意思

- `minikube start`
  - 启动本地 `Kubernetes` 实验集群
- `--driver=docker`
  - 告诉 `minikube` 用本机 `Docker` 来承载这个实验集群
- `--nodes 3`
  - 让 `minikube` 直接创建 `3` 个节点
  - 默认会是：
    - `1` 个 control-plane
    - `2` 个 worker

## 验证

先看 `minikube` 自己的状态：

```bash
minikube status
```

再看 `kubectl` 是否已经连上这个集群：

```bash
kubectl get nodes
```

如果一切正常，通常会看到：

- `kubectl get nodes` 里出现 `3` 个节点
- 其中 `minikube` 是 `control-plane`
- 另外两个节点也已经是 `Ready`

## 常用命令

```bash
minikube stop
minikube start --driver=docker --nodes 3
minikube delete
```

### 含义

- `minikube stop`
  - 停止当前实验集群，但保留它
- `minikube start --driver=docker --nodes 3`
  - 重新启动这套三节点实验集群
- `minikube delete`
  - 删除整个本地实验集群

## 完成标准

当下面这些都正常时，`00-prestart` 这一部分就完成了：

- `kubectl version --client` 正常
- `minikube version` 正常
- `minikube status` 正常
- `kubectl get nodes` 能看到 `3` 个节点
- `minikube` 节点角色是 `control-plane`
- 另外 `2` 个 worker 也都是 `Ready`

## 参考

- `minikube` 官方安装文档：
  - `https://minikube.sigs.k8s.io/docs/start/`
