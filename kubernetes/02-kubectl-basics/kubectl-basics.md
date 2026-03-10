# kubectl 基础命令

这一节只练四个最常用的命令：

- `kubectl get`
- `kubectl describe`
- `kubectl logs`
- `kubectl exec`

先记住它们各自的定位：

- `get`
  - 看“有什么”
- `describe`
  - 看“某个对象的详细状态”
- `logs`
  - 看“容器输出了什么”
- `exec`
  - 到容器里执行命令

## 先确认当前集群可用

```bash
kubectl get nodes
kubectl get pods -A -o wide
kubectl get svc -A
```

这一轮先重点看：

- 节点是不是都 `Ready`
- `kube-system` 里有哪些系统 Pod
- 这些 Pod 分别跑在哪个节点上
- 集群里默认有哪些 `Service`

## 1. 先学 `kubectl get`

`get` 用来列出资源，是你最常用的入口命令。

先从最常见的几条开始：

```bash
kubectl get nodes
kubectl get pods -A
kubectl get pods -A -o wide
kubectl get svc -A
```

这几条命令分别解决：

- 集群里有哪些节点
- 当前有哪些 Pod
- 这些 Pod 跑在哪个节点上、IP 是什么
- 当前有哪些 Service

### 常见写法

```bash
kubectl get pod demo-shell
kubectl get pod demo-shell -o wide
kubectl get pod demo-shell -o yaml
```

这里可以先这样理解：

- 默认输出
  - 适合快速扫一眼
- `-o wide`
  - 多看节点、IP 等补充信息
- `-o yaml`
  - 看对象完整定义和状态字段

学习阶段先不要试图把整份 YAML 全背下来，先知道：

- `metadata`
  - 这个对象是谁
- `spec`
  - 你希望它怎么运行
- `status`
  - 它现在实际怎么样

## 2. 准备一个最小 demo Pod

为了练 `describe`、`logs`、`exec`，先准备一个临时 Pod：

```bash
kubectl run demo-shell --image=busybox:1.36 --restart=Never -- sh -c 'while true; do echo demo-log; sleep 5; done'
kubectl wait --for=condition=Ready pod/demo-shell --timeout=120s
```

这两条命令做的事情很简单：

- 创建一个叫 `demo-shell` 的 Pod
- 容器里每隔几秒打印一次 `demo-log`
- 等这个 Pod 进入 `Ready`

补充一点：

- 第一次拉镜像时可能会多等一会
- 如果你已经有这个 Pod，重复创建会报同名冲突

## 3. 再学 `kubectl describe`

`describe` 用来查看单个对象的详细信息，适合排查问题或确认状态。

先看这个 Pod：

```bash
kubectl describe pod demo-shell
```

你第一次看输出时，先盯这几块：

- `Name` / `Namespace`
  - 这个对象是谁
- `Node`
  - 它被调度到哪个节点
- `Status`
  - 当前是不是在运行
- `Containers`
  - 镜像、命令、端口、就绪状态
- `Conditions`
  - Ready / ContainersReady 等条件
- `Events`
  - 最近发生了什么

`describe` 和 `get` 的区别可以先这样记：

- `get`
  - 适合看列表、看概况
- `describe`
  - 适合盯住一个对象深入看

如果以后碰到 Pod 起不来，`describe` 往往比 `get` 更先给你线索。

## 4. 再学 `kubectl logs`

`logs` 用来查看容器标准输出。

先看这个 demo Pod 的日志：

```bash
kubectl logs demo-shell
```

如果只想看最近几行：

```bash
kubectl logs demo-shell --tail=5
```

如果想持续追日志：

```bash
kubectl logs -f demo-shell
```

补充几点：

- `logs` 看的是容器输出，不是 Kubernetes 事件
- `-f` 类似 `tail -f`
- 想退出持续跟随，按 `Ctrl+C`

以后如果你怀疑“应用起来了但行为不对”，通常先看 `logs`。

## 5. 再学 `kubectl exec`

`exec` 用来在容器里执行命令。

先执行一个简单命令：

```bash
kubectl exec demo-shell -- hostname
kubectl exec demo-shell -- sh -c 'echo inside-pod && pwd'
```

如果你想进入一个交互式 shell：

```bash
kubectl exec -it demo-shell -- sh
```

进入后可以先试几条最简单的：

```sh
hostname
pwd
ps
exit
```

这里最重要的直觉是：

- `logs`
  - 站在外面看容器输出
- `exec`
  - 直接进容器里观察

如果容器镜像太精简，里面可能没有 `bash`，这时优先试：

```bash
kubectl exec -it demo-shell -- sh
```

## 6. 四个命令放在一起怎么用

学习阶段可以把排查顺序先固定成这样：

1. `kubectl get`
   看对象是不是存在、是不是 Running。
2. `kubectl describe`
   看它调度到哪、事件里有没有报错。
3. `kubectl logs`
   看容器进程输出了什么。
4. `kubectl exec`
   进入容器做进一步确认。

先把这个顺序练熟，后面学 `Deployment`、`Service`、排障时都会重复用到。

## 7. 练完后清理 demo Pod

```bash
kubectl delete pod demo-shell
```

这一节用完就删掉，避免占着默认 namespace。

## 这一节结束后的最小自测

你可以不看文档，自己完成下面这组动作：

1. 用 `kubectl get pods -A -o wide` 找出某个 Pod 跑在哪个节点上。
2. 创建 `demo-shell`。
3. 用 `kubectl describe pod demo-shell` 找到它的 `Node` 和 `Events`。
4. 用 `kubectl logs demo-shell --tail=5` 看最近日志。
5. 用 `kubectl exec -it demo-shell -- sh` 进入容器。
6. 删除 `demo-shell`。

如果这组动作你已经能自己做出来，就可以进入下一节。

## 下一节做什么

下一节进入：

- `kubernetes/03-workloads-and-services`

也就是开始真正写和管理：

- `Pod`
- `Deployment`
- `Service`
