# Kubernetes 学习入口

这是 `sre-tools-learn` 仓库里的 `Kubernetes` 学习主线。

当前这条主线已经有 `00 ~ 04` 五个基础章节，默认实验环境是本地三节点 `minikube` 集群：

- `1 control-plane`
- `2 worker`

## 当前入口

- `kubernetes/ROADMAP.md`
- `kubernetes/00-prestart/README.md`
- `kubernetes/01-architecture-and-core-concepts/README.md`
- `kubernetes/02-kubectl-basics/README.md`
- `kubernetes/03-workloads-and-services/README.md`
- `kubernetes/04-configmap-secret-namespace/README.md`

## 建议顺序

- `00-prestart`
  - 先把 `kubectl`、`minikube` 和本地三节点集群准备好
- `01-architecture-and-core-concepts`
  - 再把架构、控制面、工作节点和核心对象理清楚
- `02-kubectl-basics`
  - 再练最常用的 `kubectl` 基础命令
- `03-workloads-and-services`
  - 再把 `Pod`、`Deployment`、`Service`、扩容和滚动更新串起来
- `04-configmap-secret-namespace`
  - 再把 `Namespace`、`ConfigMap`、`Secret` 和应用配置串起来

## 当前阶段建议

- 先把 `00 ~ 04` 走顺
- 当前阶段先不要急着跳到 `Helm` 或 `Argo CD`
- 下一步更合理的目标是 `05-ingress-and-storage`
