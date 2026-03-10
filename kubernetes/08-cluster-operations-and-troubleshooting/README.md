# 08: 集群操作与排错

这一节开始练最常见的观察、定位和回滚动作。

## 这一节做什么

- 先从 `Node`、`Deployment`、`ReplicaSet`、`Pod` 这条链路观察对象状态
- 练 `kubectl describe`、`logs`、`get events` 这几个最常用排错入口
- 故意制造一次坏发布
- 用 `kubectl rollout undo` 把发布回滚回来

## 文件

- `cluster-operations-and-troubleshooting.md`：这一节的主体说明和练习路径
- `ops-demo-namespace.yaml`：实验 namespace
- `web-demo-deployment.yaml`：排错用 `Deployment` 示例
- `web-demo-service.yaml`：排错用 `Service` 示例
- `verify.sh`：验证观察、故障发布、事件排查和回滚路径

## 前提

继续这一节之前，默认你已经完成：

- `kubernetes/00-prestart`
- `kubernetes/01-architecture-and-core-concepts`
- `kubernetes/02-kubectl-basics`
- `kubernetes/03-workloads-and-services`
- `kubernetes/04-configmap-secret-namespace`
- `kubernetes/05-ingress-and-storage`
- `kubernetes/06-rbac-and-serviceaccount`
- `kubernetes/07-helm`

至少要满足：

- `kubectl get nodes` 正常
- 你已经会创建和观察 `Deployment`、`Service`
- 你已经知道 `rollout status` 在看发布过程
- 你已经知道 `Namespace` 能帮你隔离实验资源

## 推荐顺序

```text
cluster-operations-and-troubleshooting.md -> kubernetes/09-rebuild-and-repeatability
```

## 完成标准

当你做完这一节后，应该能回答这些问题：

- 为什么排错时通常先看 `get`，再看 `describe`、`logs`、`events`
- `Deployment -> ReplicaSet -> Pod` 这条链路该怎么一路追下去
- 为什么坏发布时经常先从 `rollout status` 看异常，再落到具体 Pod 和事件
- `ImagePullBackOff` 往往意味着什么
- `kubectl rollout undo` 在什么场景下最省事
