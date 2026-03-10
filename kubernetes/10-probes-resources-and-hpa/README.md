# 10: Probes、Resources 与 HPA

这一节开始补 Kubernetes 里非常常见的一组运行时能力：

- 应用什么时候算“活着”
- 什么时候算“准备好接流量”
- 它至少需要多少资源
- 什么时候应该自动扩容

## 这一节做什么

- 理解 `startupProbe`、`readinessProbe`、`livenessProbe`
- 给 `Deployment` 加上 `requests` 和 `limits`
- 启用 `metrics-server`
- 用 `HPA` 按 CPU 自动扩缩容

## 文件

- `probes-resources-and-hpa.md`：这一节的主体说明和练习路径
- `runtime-demo-namespace.yaml`：实验 namespace
- `probe-web-deployment.yaml`：带探针和资源限制的示例应用
- `probe-web-service.yaml`：访问 `probe-web` 的 Service
- `cpu-burner-deployment.yaml`：故意制造 CPU 压力的 Deployment
- `cpu-burner-hpa.yaml`：给 `cpu-burner` 配置的 HPA
- `verify.sh`：验证探针、资源限制、指标和自动扩容

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
- `kubernetes/08-cluster-operations-and-troubleshooting`
- `kubernetes/09-rebuild-and-repeatability`

至少要满足：

- `kubectl get nodes` 正常
- `minikube status` 正常
- 你已经会看 `Deployment`、`Service` 和 `Pod`
- 你已经知道 `rollout status` 和 `describe` 能帮助你观察发布过程

## 推荐顺序

```text
probes-resources-and-hpa.md
```

## 完成标准

当你做完这一节后，应该能回答这些问题：

- `startupProbe`、`readinessProbe`、`livenessProbe` 分别在什么时候起作用
- 为什么 `requests` 和 `limits` 不是一回事
- 为什么 CPU 型 `HPA` 需要 `metrics-server`
- 为什么没有 `cpu request` 时，`HPA` 很难正确按利用率工作
- 你怎么判断一条自动扩缩容链路真的生效了
