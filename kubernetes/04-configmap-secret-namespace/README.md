# 04: ConfigMap Secret Namespace

这一节开始管理应用配置、敏感信息和资源作用域。

## 这一节做什么

- 用 `Namespace` 给实验对象分组和隔离
- 用 `ConfigMap` 存普通配置
- 用 `Secret` 存敏感信息
- 让应用通过环境变量读到这些值

## 文件

- `configmap-secret-namespace.md`：这一节的主体说明和练习路径

## 前提

继续这一节之前，默认你已经完成：

- `kubernetes/00-prestart`
- `kubernetes/01-architecture-and-core-concepts`
- `kubernetes/02-kubectl-basics`
- `kubernetes/03-workloads-and-services`

至少要满足：

- `kubectl get nodes` 正常
- 你已经会创建和观察 `Pod`、`Deployment`、`Service`
- 你已经知道 `Namespace` 是资源隔离边界

## 推荐顺序

```text
configmap-secret-namespace.md -> kubernetes/05-ingress-and-storage
```

## 完成标准

当你做完这一节后，应该能回答这些问题：

- `ConfigMap` 和 `Secret` 的主要区别是什么
- 为什么 `Secret` 适合放敏感信息，但 base64 不等于加密
- 为什么很多资源查询都要带 `-n <namespace>`
- 你怎么让一个 `Deployment` 读取 `ConfigMap` 和 `Secret`
- 为什么删除一个 `Namespace` 往往能顺带清掉这一组实验资源
