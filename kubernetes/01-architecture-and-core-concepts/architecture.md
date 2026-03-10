# Kubernetes 架构与核心概念

## 先绑定到你当前的实验环境

你现在用的是本地三节点 `minikube` 集群：

- `minikube`
  - `control-plane`
- `minikube-m02`
  - `worker`
- `minikube-m03`
  - `worker`

先看一眼节点：

```bash
kubectl get nodes
```

这一节后面的所有概念，都先代入这套真实环境理解。

补充一点：

- `ROLES` 列不是完整身份说明
- `control-plane` 节点通常会显示 `control-plane`
- worker 节点常常显示 `<none>`
- 在当前这套环境里，`minikube-m02` 和 `minikube-m03` 仍然是 worker

## 先建立整体直觉

可以先把 Kubernetes 理解成一套“声明目标状态并持续收敛”的系统：

1. 你通过 `kubectl` 提交对象定义
2. `kube-apiserver` 接收请求
3. 状态写入 `etcd`
4. 控制器发现需要创建或调整 Pod
5. `kube-scheduler` 为 Pod 选择节点
6. 目标节点上的 `kubelet` 调用容器运行时把 Pod 拉起来

这一节最重要的直觉只有一句话：

- 你不是直接去某台机器上“手动启动容器”
- 你是在声明期望状态，控制面负责让系统收敛过去

## 什么是 control plane

`control plane` 是集群的控制中心，负责：

- 接收请求
- 保存状态
- 调度工作负载
- 持续把实际状态拉回期望状态

在当前实验环境里，`minikube` 就是 control-plane 节点。

### control plane 的四个核心组件

- `kube-apiserver`
  - 集群统一入口
  - `kubectl` 主要就是和它交互
- `etcd`
  - 集群状态数据库
  - 保存节点、Pod、Deployment、Service 等对象信息
- `kube-scheduler`
  - 给新 Pod 选择合适节点
- `kube-controller-manager`
  - 一组控制器的集合
  - 持续比较“期望状态”和“实际状态”，并推动系统收敛

你可以先这样记：

- `apiserver` 负责接收请求
- `etcd` 负责记账
- `scheduler` 负责选节点
- `controller-manager` 负责持续纠偏

## 什么是 worker

`worker` 是真正运行业务 Pod 的节点。

在当前环境里：

- `minikube-m02`
- `minikube-m03`

就是两个 worker。

### worker 上最关键的组件

- `kubelet`
  - 每台节点上的 Kubernetes 代理
  - 负责把控制面的安排落实到本机
- `kube-proxy`
  - 让 `Service` 的网络访问模型生效
- 容器运行时
  - 例如 `containerd`
  - 负责真正启动、停止、删除容器

这里有一个容易混淆的点：

- `kube-apiserver`、`etcd`、`kube-scheduler`、`kube-controller-manager`
  常常能在 `kubectl get pods -A` 里看到
- `kubelet`
  不是以普通 Pod 的形式出现在这里

## 把当前集群里的系统组件对上

先观察：

```bash
kubectl get pods -A -o wide
```

在当前这套三节点环境里，你最值得先对上的系统 Pod 是这些：

- `kube-apiserver-minikube`
  - control plane 的 API 入口
- `etcd-minikube`
  - control plane 的状态存储
- `kube-controller-manager-minikube`
  - control plane 的控制器集合
- `kube-scheduler-minikube`
  - control plane 的调度器
- `kube-proxy-*`
  - 每个节点通常各有一个
- `kindnet-*`
  - 集群网络插件相关 Pod
  - 三个节点通常会看到三个
- `coredns-*`
  - 集群内部 DNS 后端
- `storage-provisioner`
  - 当前本地实验环境的存储辅助组件之一

这一节不用把所有名字都背下来，只要先能把它们分成三类：

- control plane 组件
- 每节点都会有的系统组件
- 集群公共能力组件，例如 DNS 和存储

## 三个最核心的对象

### `Pod`

`Pod` 是 Kubernetes 里最小的可调度单元。

入门阶段可以先把它理解成：

- 一个运行中的应用实例

但要记住，更准确地说：

- Kubernetes 调度的是 `Pod`
- 不是单个容器

### `Deployment`

`Deployment` 是管理一组相同 Pod 的声明式控制器，主要解决：

- 我要几个副本
- 我要滚动更新
- Pod 挂了之后要自动补回来

所以：

- `Pod` 是运行实例
- `Deployment` 是管理这组实例的控制器

### `Service`

`Service` 给一组 Pod 提供稳定访问入口，主要解决：

- Pod 会重建
- Pod IP 会变化
- 客户端不能直接绑定某个 Pod IP

所以 `Service` 提供的是：

- 稳定名字
- 稳定虚拟地址
- 指向一组后端 Pod 的转发规则

要特别区分这一点：

- `Service` 不等于某个固定 Pod
- 它面对的是“后端 Pod 集合”

## 用当前集群理解 `Service`

先看当前 Service：

```bash
kubectl get svc -A
```

你现在最值得先认识的是这两个：

- `default / kubernetes`
  - 集群默认就有的系统级 `Service`
- `kube-system / kube-dns`
  - 集群内部 DNS 的稳定入口

你在 `kubectl get pods -A` 里看到的 `coredns-*` 是后端 Pod；
你在 `kubectl get svc -A` 里看到的 `kube-dns` 是这些 Pod 前面的稳定访问入口。

这就是 `Service` 的典型思路：

- 后端 Pod 可以变化
- 入口尽量保持稳定

## 当前阶段最应该记住的三句话

1. `kubectl` 主要是和 `kube-apiserver` 交互。
2. `Pod` 是运行单元，`Deployment` 是管理 Pod 的控制器。
3. `Service` 提供稳定入口，它面向的是一组 Pod，而不是某个固定 Pod。

## 现在就可以做的最小观察

这一节先不创建对象，只观察当前集群：

```bash
kubectl get nodes
kubectl get pods -A -o wide
kubectl get svc -A
```

观察时重点看这三件事：

- 当前集群有几个节点，谁是 control-plane，谁是 worker
- 哪些系统 Pod 跑在 `minikube`，哪些跑在 `minikube-m02`、`minikube-m03`
- 当前已经有哪些系统级 `Service`

## 这一节结束后的检查点

读完这一节后，你应该能自己回答：

- 为什么当前集群里有 `1` 个 control-plane 和 `2` 个 worker
- 为什么 `kubectl` 主要是和 `kube-apiserver` 交互
- `Pod`、`Deployment`、`Service` 各自解决什么问题
- 为什么 `Deployment` 不是直接替代 `Pod`
- 为什么 `Service` 不等于某个具体 Pod

## 下一节做什么

下一节进入：

- `kubernetes/02-kubectl-basics`

也就是开始系统认识：

- `kubectl get`
- `kubectl describe`
- `kubectl logs`
- `kubectl exec`
