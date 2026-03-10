# 01: 架构与核心概念

这一节先不急着写业务 YAML，先把 `Kubernetes` 最核心的结构理清楚。

## 这一节做什么

- 结合你当前这套本地三节点 `minikube` 集群，理解：
  - 什么是 `control plane`
  - 什么是 `worker`
- 认识最核心的几个控制面组件：
  - `kube-apiserver`
  - `etcd`
  - `kube-scheduler`
  - `kube-controller-manager`
- 认识工作节点上的关键组件：
  - `kubelet`
  - `kube-proxy`
  - 容器运行时
- 建立最常见对象的直觉：
  - `Pod`
  - `Deployment`
  - `Service`

## 文件

- `architecture.md`：这一节的主体说明
- `verify.sh`：验证控制面组件和核心系统服务是否可见

## 推荐顺序

```text
architecture.md -> kubernetes/02-kubectl-basics
```

## 完成标准

当你读完这一节后，应该能回答这些问题：

- 为什么当前集群里有 `1` 个 control-plane 和 `2` 个 worker
- `kubectl` 为什么主要是和 `kube-apiserver` 交互
- `Pod`、`Deployment`、`Service` 三者分别解决什么问题
- `Deployment` 为什么不是直接替代 `Pod`
- `Service` 为什么不等于“某个具体 Pod”
