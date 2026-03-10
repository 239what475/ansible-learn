# 07: Helm

这一节开始把一组 Kubernetes YAML 收束成可复用的 chart。

## 这一节做什么

- 理解 `chart`、`release`、`values` 三个最常见概念
- 用 `helm lint`、`helm template` 先做静态检查
- 用 `helm upgrade --install` 部署应用
- 用 `helm get values`、`helm uninstall` 管理 release

## 文件

- `helm-basics.md`：这一节的主体说明和练习路径
- `web-demo/`：最小 `Helm chart`
- `values-dev.yaml`：一份覆盖默认值的示例
- `verify.sh`：验证 `lint`、`template`、`install`、`upgrade`、`uninstall`

## 前提

继续这一节之前，默认你已经完成：

- `kubernetes/00-prestart`
- `kubernetes/01-architecture-and-core-concepts`
- `kubernetes/02-kubectl-basics`
- `kubernetes/03-workloads-and-services`
- `kubernetes/04-configmap-secret-namespace`
- `kubernetes/05-ingress-and-storage`
- `kubernetes/06-rbac-and-serviceaccount`

至少要满足：

- `kubectl get nodes` 正常
- `helm version` 正常
- 你已经知道 `Deployment`、`Service`、`Ingress` 是不同层次的对象
- 你已经知道 YAML 里哪些字段常常需要按环境改值

## 推荐顺序

```text
helm-basics.md -> kubernetes/08-cluster-operations-and-troubleshooting
```

## 完成标准

当你做完这一节后，应该能回答这些问题：

- `chart` 和 `release` 分别是什么
- 为什么 `helm template` 很适合先看渲染结果
- 为什么 `values.yaml` 和 `values-dev.yaml` 要分开
- `helm upgrade --install` 为什么是最常用的部署入口
- 你怎么确认一条 `Helm release` 当前生效的值是什么
