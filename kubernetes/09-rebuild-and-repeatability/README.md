# 09: 重建与可重复性

这一节开始把“会做一次”提升成“可以重复做很多次”。

## 这一节做什么

- 先用一组固定 manifests 重复创建应用
- 再用一个独立 `minikube` profile 练一次删掉再重建
- 确认同一组输入能得到稳定的结果
- 养成“清理干净再重来”的实验习惯

## 文件

- `rebuild-and-repeatability.md`：这一节的主体说明和练习路径
- `repeat-demo-namespace.yaml`：实验 namespace
- `repeat-web-deployment.yaml`：重复部署用 `Deployment` 示例
- `repeat-web-service.yaml`：重复部署用 `Service` 示例
- `verify.sh`：验证重复应用和独立 profile 的重建路径

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

至少要满足：

- `kubectl get nodes` 正常
- `minikube status` 正常
- 你已经会用 YAML 重建一组最小对象
- 你已经知道 `Namespace` 能帮助你快速清理一组实验资源

## 推荐顺序

```text
rebuild-and-repeatability.md -> kubernetes/10-probes-resources-and-hpa
```

## 完成标准

当你做完这一节后，应该能回答这些问题：

- 为什么“可重复性”比“偶尔跑通一次”更重要
- 为什么实验时应该优先保存 manifests，而不是只依赖手工命令历史
- 为什么重建环境时更适合用独立 profile，而不是直接删主集群
- 你怎么证明同一组 YAML 在新环境里还能得到同样结果
- 为什么清理步骤本身也是实验设计的一部分
