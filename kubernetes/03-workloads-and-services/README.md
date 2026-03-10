# 03: 工作负载与 Service

这一节开始真正创建和管理应用对象。

## 这一节做什么

- 用单个 `Pod` 感受最小运行单元
- 用 `Deployment` 管理副本和更新
- 用 `Service` 给一组 Pod 提供稳定入口
- 练习副本扩容和滚动更新

## 文件

- `workloads-and-services.md`：这一节的主体说明和练习路径
- `pod-demo.yaml`：裸 `Pod` 示例
- `web-demo-deployment.yaml`：`Deployment` 示例
- `web-demo-service.yaml`：`Service` 示例
- `verify.sh`：验证 `Pod`、`Deployment`、`Service`、扩容和滚动更新

## 前提

继续这一节之前，默认你已经完成：

- `kubernetes/00-prestart`
- `kubernetes/01-architecture-and-core-concepts`
- `kubernetes/02-kubectl-basics`

至少要满足：

- `kubectl get nodes` 正常
- 你已经会用 `kubectl get`、`describe`、`logs`、`exec`
- 你已经知道 `Pod`、`Deployment`、`Service` 分别解决什么问题

## 推荐顺序

```text
workloads-and-services.md -> kubernetes/04-configmap-secret-namespace
```

## 完成标准

当你做完这一节后，应该能回答这些问题：

- 为什么长期运行的应用通常不直接只建一个裸 `Pod`
- `Deployment` 和它管理的 Pod 之间是什么关系
- `Service` 为什么能在 Pod 变化时继续提供稳定入口
- 你怎么把一个 Deployment 从 `1` 个副本扩到 `3` 个
- 你怎么发起一次滚动更新并观察它完成
