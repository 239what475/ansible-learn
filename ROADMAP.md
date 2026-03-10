# SRE Tools Learn 路线图

## 当前阶段

- `ansible/` 已完成 `01 ~ 30` 的基础学习与综合小项目
- `terraform/` 已完成 `00 ~ 10` 的基础学习主线
- `kubernetes/` 当前已有 `00 ~ 08` 的基础章节
- 当前仓库里已经有三条可直接开始的主线：
  - `ansible/`
  - `terraform/`
  - `kubernetes/`

## 下一阶段

建议按下面顺序继续推进 `kubernetes/`：

- `00-prestart`
  - 先安装 `kubectl`
  - 再安装并启动 `minikube` 三节点集群

- `01 ~ 08`
  - 先理解架构、核心对象和最常用的 `kubectl` 命令
  - 再把 `Pod`、`Deployment`、`Service`、`Namespace`、`ConfigMap`、`Secret`、`Ingress`、`PVC`、`ServiceAccount`、`RBAC`、`Helm`、发布排错与回滚串起来

- `09+`
  - 再逐步进入应用编排、配置、存储和运维

## 当前推荐入口

- `ansible/README.md`
- `ansible/ROADMAP.md`
- `terraform/README.md`
- `terraform/ROADMAP.md`
- `kubernetes/README.md`
- `kubernetes/ROADMAP.md`
