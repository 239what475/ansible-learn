# 00: Prestart

这一节只做本机前置准备，并直接把后续会用到的 `minikube` 三节点实验集群准备出来。

## 文件

- `kubectl.md`：安装本机 `kubectl`
- `minikube.md`：安装 `minikube`、启动本地 `1 control-plane + 2 worker` 实验集群并验证

## 推荐顺序

```text
kubectl.md -> minikube.md -> 后续 Kubernetes 章节
```

## 完成标准

当下面这些都正常时，就可以进入后续章节：

- `kubectl version --client` 可以正常执行
- `minikube version` 可以正常执行
- `minikube status` 可以正常执行
- `kubectl get nodes` 可以正常执行
- `kubectl get nodes` 里已经能看到 `3` 个节点
- `minikube` 是 `control-plane`
- 另外 `2` 个 worker 也已经是 `Ready`
- 你已经知道后续实验默认基于本机 `minikube` 三节点集群继续

## 运行方式

如果你已经完成：

- `kubectl.md`

那么这一节后面直接继续：

- `minikube.md`
