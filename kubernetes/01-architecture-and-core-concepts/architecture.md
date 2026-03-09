# Kubernetes 架构与核心概念

## 先看你当前的实验环境

你现在本机已经有一套三节点集群：

- `minikube`
  - `control-plane`
- `minikube-m02`
  - `worker`
- `minikube-m03`
  - `worker`

你可以先看一眼：

```bash
kubectl get nodes
```

这一节里，后面所有架构概念都可以先代入这套实际环境去理解。

补充一点：

- `kubectl get nodes` 里的 `ROLES` 列不是“系统自动推理出来的完整身份说明”
- `control-plane` 节点通常会显示 `control-plane`
- worker 节点在很多环境里不会额外打 `worker` 标签，所以常常显示 `<none>`
- 在你当前这套 `minikube` 三节点环境里：
  - `minikube-m02`
  - `minikube-m03`
  仍然承担 worker 角色

## 什么是 control plane

`control plane` 可以先理解成：

- 整个集群的控制中心
- 它负责：
  - 接收你的声明
  - 保存集群状态
  - 决定工作负载该调度到哪里
  - 持续把真实状态拉回你声明的期望状态

在你当前环境里：

- `minikube`
  - 就是 control-plane 节点

### control plane 里最关键的组件

#### `kube-apiserver`

可以先理解成：

- 集群的统一入口
- `kubectl` 默认就是和它交互

你写：

```bash
kubectl get pods -A
```

本质上不是 `kubectl` 自己知道所有 Pod，
而是：

- `kubectl` 调 `kube-apiserver`
- 再由 API Server 返回当前集群状态

一句话：

- `kubectl` 主要是在和 `kube-apiserver` 说话

#### `etcd`

可以先理解成：

- 集群状态数据库
- 它保存：
  - 节点信息
  - Pod/Deployment/Service 等对象定义
  - 当前期望状态与部分运行状态

一句话：

- `etcd` 是 Kubernetes 的“状态账本”

#### `kube-scheduler`

可以先理解成：

- 给新 Pod 选节点的组件

例如：

- 你创建一个 Deployment，想要 `3` 个副本
- scheduler 会决定：
  - 这些 Pod 放到哪个 worker 上更合适

一句话：

- `scheduler` 决定 Pod 落到哪台机器

#### `kube-controller-manager`

可以先理解成：

- 一组控制器的集合
- 它们持续检查：
  - 当前状态
  - 期望状态
  是否一致

例如：

- 你声明一个 Deployment 要 `3` 个副本
- 现在实际只剩 `2` 个
- controller manager 里的相关控制器就会推动系统再补一个出来

一句话：

- controller manager 负责“持续收敛”

## 把你当前看到的 `kube-system` Pod 对上

你刚才执行：

```bash
kubectl get pods -A
```

看到的不只是我们前面单独提到的几个组件，这很正常。  
当前这套 `minikube` 三节点集群里，最值得先对应起来的是这些：

下面这份就是当前这套实验环境里一次实际输出的参考样例：

```text
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-7d764666f9-htt89           1/1     Running   0          27m
kube-system   etcd-minikube                      1/1     Running   0          27m
kube-system   kindnet-qv54z                      1/1     Running   0          27m
kube-system   kindnet-rj4vv                      1/1     Running   0          27m
kube-system   kindnet-tknhc                      1/1     Running   0          27m
kube-system   kube-apiserver-minikube            1/1     Running   0          27m
kube-system   kube-controller-manager-minikube   1/1     Running   0          27m
kube-system   kube-proxy-clh7q                   1/1     Running   0          27m
kube-system   kube-proxy-mfg9t                   1/1     Running   0          27m
kube-system   kube-proxy-ndp9f                   1/1     Running   0          27m
kube-system   kube-scheduler-minikube            1/1     Running   0          27m
kube-system   storage-provisioner                1/1     Running   0          27m
```

你后面读这一节时，可以直接把上面这些名字和下面的解释一一对上。

### control-plane 相关

- `kube-apiserver-minikube`
  - 就是当前 control-plane 上的 `kube-apiserver`
- `etcd-minikube`
  - 就是当前 control-plane 上的 `etcd`
- `kube-controller-manager-minikube`
  - 就是当前 control-plane 上的 `kube-controller-manager`
- `kube-scheduler-minikube`
  - 就是当前 control-plane 上的 `kube-scheduler`

也就是说，你前面学到的几个核心控制面组件，在当前实验集群里都能直接在 `kube-system` 里看到对应 Pod。

### 集群网络相关

- `kindnet-qv54z`
- `kindnet-rj4vv`
- `kindnet-tknhc`

这几个是当前集群网络插件相关的 Pod。  
你可以先把它们理解成：

- 负责让 Pod 网络在各节点上正常工作的组件

因为你现在有 `3` 个节点，所以这里也出现了 `3` 个 `kindnet` 相关 Pod。

### Service 网络转发相关

- `kube-proxy-clh7q`
- `kube-proxy-mfg9t`
- `kube-proxy-ndp9f`

这几个就是 `kube-proxy`。  
同样因为你现在有 `3` 个节点，所以通常会看到每个节点各有一个 `kube-proxy` Pod。

### DNS 相关

- `coredns-7d764666f9-htt89`

这个是集群内部 DNS 组件。  
你可以先理解成：

- 让集群里的服务名解析生效

后面你学 `Service` 时会经常和它间接打交道。

### 存储相关

- `storage-provisioner`

这个是当前 `minikube` 默认启用的存储供应组件之一。  
你现在可以先把它理解成：

- 给后面本地实验里的存储能力做基础准备

等学到 `PVC`、`StorageClass` 时再深入。

## 为什么你没在这里看到 `kubelet`

这点很重要。

前面我们说过：

- `kubelet` 是每台节点上的关键组件

但你在：

```bash
kubectl get pods -A
```

里没有看到它。原因是：

- `kubelet` 不是以普通 Pod 的形式出现在这里
- 它更接近“节点上的系统组件 / 节点代理”

所以：

- `kube-apiserver`、`etcd`、`kube-scheduler`、`kube-controller-manager`
  你会在 `kube-system` Pod 列表里看到
- `kubelet`
  不会以这种方式直接出现在这里

这一点很容易混，但一定要分清楚。

## 什么是 worker

`worker` 可以先理解成：

- 真正运行业务 Pod 的节点

在你当前环境里：

- `minikube-m02`
- `minikube-m03`

就是两个 worker。

### worker 上最关键的组件

#### `kubelet`

可以先理解成：

- 每台节点上的 Kubernetes 代理
- 它负责：
  - 接收 control-plane 的安排
  - 确保对应 Pod 在本节点上运行起来

一句话：

- `kubelet` 是节点和 Kubernetes 控制面的桥

#### `kube-proxy`

可以先理解成：

- 负责 Service 相关网络转发的一层组件

一句话：

- `kube-proxy` 主要让 Service 的网络访问模型生效

#### 容器运行时

例如：

- `containerd`
- `CRI-O`
- 有些环境下是别的实现

它负责：

- 真正把容器拉起、停止、删除

一句话：

- Kubernetes 不直接自己启动容器，它通过容器运行时去做这件事

## 从“你发命令”到“Pod 跑起来”的最小流程

你可以先把整个过程压缩成下面这几步：

1. 你通过 `kubectl` 提交一个对象定义
2. `kube-apiserver` 接收这个请求
3. 对象状态写入 `etcd`
4. controller 发现系统需要新的 Pod
5. scheduler 选定某个 worker
6. 目标 worker 上的 `kubelet` 调容器运行时把 Pod 拉起来

一句话：

- `Kubernetes` 不是“你直接在某台机器上执行容器命令”
- 它是“你声明目标状态，控制面负责让系统收敛到这个状态”

## 什么是 Pod

`Pod` 是 Kubernetes 里最小的可调度单元。

可以先理解成：

- 一组需要一起运行的容器
- 它们共享：
  - 网络命名空间
  - 存储卷（如果声明了）

但在大多数入门场景里，你可以先把一个 Pod 简化理解成：

- “一个运行中的应用实例”

### 为什么不是直接说“一个容器”

因为 Kubernetes 管理的最小单位不是单个容器，而是 Pod。

所以后面你看到很多对象，最终都会落到：

- 让某些 Pod 运行起来

## 什么是 Deployment

`Deployment` 可以先理解成：

- 管理一组相同 Pod 的声明式控制器

它主要解决这些问题：

- 我要几个副本
- 我要滚动更新
- 如果 Pod 挂了，要自动补回来

### 为什么 Deployment 不等于 Pod

因为：

- `Pod` 是运行实例
- `Deployment` 是管理这组实例的控制器对象

可以先这样记：

- Pod = 工人
- Deployment = 管理这批工人的班组长

## 什么是 Service

`Service` 可以先理解成：

- 给一组 Pod 提供稳定访问入口

它解决的问题是：

- Pod 会重建
- Pod IP 会变化
- 客户端不能直接绑死某个 Pod IP

所以 Service 提供的是：

- 一个稳定名字
- 一组后端 Pod 的转发规则

你现在可以先看一眼当前集群里的 Service：

```bash
kubectl get service
```

当前这套实验环境里，一次实际输出参考如下：

```text
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   32m
```

这里最值得先记住的是：

- `kubernetes`
  - 这是集群里默认就会有的一个 `Service`
- `TYPE = ClusterIP`
  - 表示它提供的是集群内部访问入口
- `CLUSTER-IP = 10.96.0.1`
  - 表示这是这个 Service 在集群内部的虚拟访问地址
- `443/TCP`
  - 表示它对外暴露的端口

你现在不用急着追它具体转发到哪里，先建立这个直觉就够：

- 集群里即使还没部署你自己的业务，也已经会有系统级 Service
- `Service` 关注的是“稳定入口”，不是某个固定 Pod 本身

如果你想看得更完整一点，可以执行：

```bash
kubectl get svc -A
```

在你当前这套实验环境里，一次实际输出参考如下：

```text
NAMESPACE     NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
default       kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP                  36m
kube-system   kube-dns     ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   36m
```

这比只看默认 namespace 更完整，因为它把系统 namespace 里的 Service 也列出来了。

### `kube-dns` 是什么

这里看到的：

- `kube-system / kube-dns`

可以先理解成：

- 集群内部 DNS 的访问入口 Service

前面你在 `kubectl get pods -A` 里看到的是：

- `coredns-...`

那是 DNS 相关的 Pod。  
而这里的：

- `kube-dns`

是把 DNS 能力以 Service 的方式暴露出来的稳定入口。

所以你可以先这样配对理解：

- `coredns-*`
  - 后端 DNS Pod
- `kube-dns`
  - 这些 DNS Pod 前面的稳定 Service 入口

### 为什么 Service 不等于某个 Pod

因为 Service 关注的是：

- “这组符合标签的 Pod”
- 不是某个单独 Pod

所以 Service 更像：

- 稳定入口
- 后面挂着一组可变化的 Pod

## 当前阶段最重要的三句话

### 1. `kubectl` 主要是和 `kube-apiserver` 交互

不是和某个 Pod 直接说话。

### 2. `Pod` 是运行单元，`Deployment` 是管理 Pod 的控制器

不要把两者混成同一个概念。

### 3. `Service` 提供稳定访问入口，不代表某个固定 Pod

它面向的是“后端 Pod 集合”。

## 现在你可以做的最小观察

这一节先不创建新对象，只观察当前集群：

```bash
kubectl get nodes
kubectl get pods -A -o wide
kubectl get svc -A
```

你当前最值得先观察的是：

- 节点有几个
- 哪些 Pod 跑在 control-plane / worker 上
- 集群里已经有哪些 Service

## 下一节做什么

下一节进入：

- `kubernetes/02-kubectl-basics`

也就是开始系统认识：

- `kubectl get`
- `kubectl describe`
- `kubectl logs`
- `kubectl exec`
