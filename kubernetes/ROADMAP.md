# Kubernetes 学习路线图

## 目标

- 先理解 `Kubernetes` 的基本架构和对象模型
- 再学会用 `kubectl`、`Helm` 和标准 `Kubernetes` 组件做实验
- 最后把 `Terraform + Ansible + Kubernetes` 串起来

## 当前进度

- 当前已经有十章基础内容：
  - `00-prestart`
  - `01-architecture-and-core-concepts`
  - `02-kubectl-basics`
  - `03-workloads-and-services`
  - `04-configmap-secret-namespace`
  - `05-ingress-and-storage`
  - `06-rbac-and-serviceaccount`
  - `07-helm`
  - `08-cluster-operations-and-troubleshooting`
  - `09-rebuild-and-repeatability`
- 实验环境默认优先考虑：
  - 本机安装 `kubectl`
  - 本机安装 `minikube`
  - 先用 `minikube` 拿到一个可用的本地三节点实验集群
  - 结构是：`1 control-plane + 2 worker`

## 建议顺序

- `00-prestart`
  - 安装 `kubectl`
  - 安装 `minikube`
  - 启动本地三节点实验集群
  - 确认 `kubectl get nodes` 正常

- `01-architecture-and-core-concepts`
  - 结合这套三节点实验环境认识 control plane / worker
  - 认识 `kube-apiserver`、`etcd`、`scheduler`、`controller-manager`
  - 认识 `Pod`、`Deployment`、`Service`
  - 先把对象模型和基本架构理清楚

- `02-kubectl-basics`
  - 学 `kubectl get`
  - 学 `kubectl describe`
  - 学 `kubectl logs`
  - 学 `kubectl exec`

- `03-workloads-and-services`
  - 学 `Pod`
  - 学 `Deployment`
  - 学 `Service`
  - 学滚动更新和副本数

- `04-configmap-secret-namespace`
  - 学 `ConfigMap`
  - 学 `Secret`
  - 学 `Namespace`

- `05-ingress-and-storage`
  - 学 `Ingress`
  - 学 `PVC`
  - 学 `StorageClass`

- `06-rbac-and-serviceaccount`
  - 学 `ServiceAccount`
  - 学 `Role` / `RoleBinding`
  - 学最小权限思路

- `07-helm`
  - 学 Chart
  - 学 values
  - 学如何通过 `Helm` 管理应用

- `08-cluster-operations-and-troubleshooting`
  - 学节点、Pod、事件排错
  - 学滚动更新、回滚和常见故障观察

- `09-rebuild-and-repeatability`
  - 重置并重建 `minikube`
  - 观察环境回收和重复实验

- `10-terraform-ansible-and-kubernetes`
  - 把前面两条主线串起来
  - 用 `Terraform` 建实验资源
  - 用 `Ansible` 做节点初始化
  - 再把应用交给 `Kubernetes`

## 当前阶段建议

- 如果你还没准备好集群，就从 `00-prestart` 开始
- 如果集群已经可用，就按 `01 -> 02 -> 03 -> 04 -> 05 -> 06 -> 07 -> 08 -> 09 -> 10` 继续
- 当前阶段先把基础命令和核心对象练熟
- 当前阶段先不要急着上 `Argo CD`
- 更合理的顺序是：先学 `Kubernetes`，再学 `Helm`，最后再进入 `Argo CD`
