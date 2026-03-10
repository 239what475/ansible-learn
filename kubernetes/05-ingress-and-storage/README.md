# 05: Ingress 与存储

这一节开始处理应用入口和持久化存储。

## 这一节做什么

- 认识 `StorageClass`、`PVC` 的关系
- 让 Pod 挂载一个动态创建出来的卷
- 启用并使用 `Ingress`
- 把 `Ingress -> Service -> Pod` 这条访问路径串起来

## 文件

- `ingress-and-storage.md`：这一节的主体说明和练习路径
- `edge-demo-namespace.yaml`：实验 namespace
- `data-demo-pvc.yaml`：`PVC` 示例
- `storage-demo-pod.yaml`：挂载卷的 `Pod` 示例
- `web-demo-deployment.yaml`：后端 `Deployment` 示例
- `web-demo-service.yaml`：后端 `Service` 示例
- `web-demo-ingress.yaml`：`Ingress` 示例
- `verify.sh`：验证 `StorageClass`、`PVC`、`Ingress` 的最小完整路径

## 前提

继续这一节之前，默认你已经完成：

- `kubernetes/00-prestart`
- `kubernetes/01-architecture-and-core-concepts`
- `kubernetes/02-kubectl-basics`
- `kubernetes/03-workloads-and-services`
- `kubernetes/04-configmap-secret-namespace`

至少要满足：

- `kubectl get nodes` 正常
- 你已经会创建和观察 `Deployment`、`Service`
- 你已经知道 `Namespace`、`Pod`、`Service` 的基本关系

## 推荐顺序

```text
ingress-and-storage.md -> kubernetes/06-rbac-and-serviceaccount
```

## 完成标准

当你做完这一节后，应该能回答这些问题：

- `StorageClass`、`PVC`、`PV` 三者分别是什么关系
- 为什么 `PVC` 叫 claim，而不是卷本身
- 为什么单独创建 `Ingress` 对象还不够，必须有 controller
- `Ingress` 为什么通常是指向 `Service`，而不是直接指向 Pod
- 你怎么验证一个 `Ingress` 已经把请求转发到了后端应用
