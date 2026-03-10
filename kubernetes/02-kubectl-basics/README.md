# 02: kubectl basics

这一节开始正式练最常用的 `kubectl` 基础命令。

目标很明确：

- 学会看资源列表
- 学会看对象详情
- 学会看容器日志
- 学会进入容器执行命令

## 文件

- `kubectl-basics.md`：这一节的主体说明和练习路径

## 前提

继续这一节之前，默认你已经完成：

- `kubernetes/00-prestart`
- `kubernetes/01-architecture-and-core-concepts`

至少要满足：

- `minikube status` 正常
- `kubectl get nodes` 正常
- 你已经知道 `Pod`、`Deployment`、`Service` 分别是什么

## 推荐顺序

```text
kubectl-basics.md -> kubernetes/03-workloads-and-services
```

## 完成标准

当你做完这一节后，应该能回答这些问题：

- `kubectl get` 和 `kubectl describe` 的区别是什么
- 什么时候看 `logs`
- 什么时候用 `exec`
- 你怎么快速确认一个 Pod 跑在哪个节点上
- 你怎么进入一个 Pod 里执行命令
