# 06: RBAC 与 ServiceAccount

这一节开始管理工作负载身份和最小权限。

## 这一节做什么

- 用 `ServiceAccount` 表示 Pod 的身份
- 用 `Role` 定义 namespace 内权限
- 用 `RoleBinding` 把身份和权限绑起来
- 用 `kubectl auth can-i` 验证权限是否真的生效

## 文件

- `rbac-and-serviceaccount.md`：这一节的主体说明和练习路径
- `auth-demo-namespace.yaml`：实验 namespace
- `viewer-serviceaccount.yaml`：`ServiceAccount` 示例
- `pod-reader-role.yaml`：只读 `Pod` 的 `Role` 示例
- `pod-reader-binding.yaml`：把 `ServiceAccount` 绑定到 `Role` 的示例
- `viewer-check-pod.yaml`：使用 `ServiceAccount` 的 `Pod` 示例
- `verify.sh`：验证 `ServiceAccount`、`Role`、`RoleBinding` 和权限检查路径

## 前提

继续这一节之前，默认你已经完成：

- `kubernetes/00-prestart`
- `kubernetes/01-architecture-and-core-concepts`
- `kubernetes/02-kubectl-basics`
- `kubernetes/03-workloads-and-services`
- `kubernetes/04-configmap-secret-namespace`
- `kubernetes/05-ingress-and-storage`

至少要满足：

- `kubectl get nodes` 正常
- 你已经知道 `Namespace` 是资源隔离边界
- 你已经会创建和观察 `Pod`
- 你已经知道 `Deployment`、`Service`、`Ingress` 是不同层次的对象

## 推荐顺序

```text
rbac-and-serviceaccount.md -> kubernetes/07-helm
```

## 完成标准

当你做完这一节后，应该能回答这些问题：

- `ServiceAccount` 为什么更像工作负载身份，而不是“用户账号”
- `Role` 和 `RoleBinding` 各自解决什么问题
- 为什么 `Role` 只定义权限，还必须再绑定给某个主体
- `kubectl auth can-i --as=system:serviceaccount:...` 在验证什么
- 为什么同一个 `ServiceAccount` 在 `auth-demo` 能做的事，不一定能在别的 namespace 做
