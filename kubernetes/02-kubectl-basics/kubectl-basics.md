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
  - 看“某个对象现在怎么样”
- `logs`
  - 看“容器输出了什么”
- `exec`
  - 在容器里执行命令或进入容器排查

## 先确认当前集群可用

```bash
kubectl get nodes
kubectl get pods -A -o wide
kubectl get svc -A
```

先重点看这几件事：

- 节点是不是都 `Ready`
- 当前有哪些系统 Pod
- 这些 Pod 分别跑在哪个节点上
- 当前有哪些系统级 `Service`

## 先准备一个最小 demo Pod

为了练 `describe`、`logs`、`exec`，先准备一个临时 Pod：

```bash
kubectl run demo-shell --image=busybox:1.36 --restart=Never -- sh -c 'while true; do echo demo-log; sleep 5; done'
kubectl wait --for=condition=Ready pod/demo-shell --timeout=120s
```

这个 Pod 很简单：

- 名字是 `demo-shell`
- 镜像是 `busybox:1.36`
- 容器会持续打印 `demo-log`

第一次拉镜像时可能会多等一会。

## 1. `kubectl get`

`get` 用来列出资源，是最常用的入口命令。

先从这几条开始：

```bash
kubectl get nodes
kubectl get pods -A
kubectl get pods -A -o wide
kubectl get svc -A
```

这几条命令分别回答：

- 集群里有哪些节点
- 当前有哪些 Pod
- 这些 Pod 跑在哪个节点上、IP 是什么
- 当前有哪些 `Service`

### 常见写法

```bash
kubectl get pod demo-shell
kubectl get pod demo-shell -o wide
kubectl get pod demo-shell -o yaml
```

可以先这样理解：

- 默认输出
  - 适合快速扫一眼
- `-o wide`
  - 适合补充看节点、IP 等信息
- `-o yaml`
  - 适合看对象完整定义和状态字段

第一次看 YAML，不用全背，只要先能分清：

- `metadata`
  - 对象是谁
- `spec`
  - 你希望它怎么运行
- `status`
  - 它当前实际怎么样

## 2. `kubectl describe`

`describe` 用来查看单个对象的详细信息，适合确认状态和排查问题。

先看这个 Pod：

```bash
kubectl describe pod demo-shell
```

第一次看输出时，先盯这几块：

- `Name` / `Namespace`
  - 对象是谁
- `Node`
  - Pod 被调度到了哪个节点
- `Status`
  - 当前是不是在运行
- `Containers`
  - 镜像、命令、端口、就绪状态
- `Conditions`
  - `Ready`、`ContainersReady` 等条件
- `Events`
  - 最近发生了什么

这里可以先这样区分：

- `get`
  - 看列表、看概况
- `describe`
  - 盯住一个对象深入看

如果以后某个 Pod 起不来，`describe` 往往比 `get` 更先给你线索。

## 3. `kubectl logs`

`logs` 用来查看容器标准输出。

常见用法：

```bash
kubectl logs demo-shell
kubectl logs demo-shell --tail=5
kubectl logs -f demo-shell
```

可以先这样记：

- 默认写法
  - 看全部日志
- `--tail=5`
  - 只看最近几行
- `-f`
  - 持续追日志，类似 `tail -f`

补充几点：

- `logs` 看的是容器输出，不是 Kubernetes 事件
- 想退出持续跟随，按 `Ctrl+C`
- 如果应用已经跑起来但行为不对，通常先看 `logs`

## 4. `kubectl exec`

`exec` 用来在容器里执行命令。

先记住三种最常见的写法：

```bash
kubectl exec demo-shell -- pwd
kubectl exec demo-shell -- sh -c 'echo inside-pod && pwd'
kubectl exec -it demo-shell -- sh
```

它们分别适合：

- `kubectl exec demo-shell -- pwd`
  - 在容器里直接执行一条简单命令
- `kubectl exec demo-shell -- sh -c '...'`
  - 借 shell 执行一串命令
- `kubectl exec -it demo-shell -- sh`
  - 进入容器做交互式排查

### `--` 是干什么的

可以先这样理解：

- `--` 前面是 `kubectl exec` 自己的参数
- `--` 后面是“容器里要执行的程序和参数”

`kubectl exec` 只负责把后面的内容传进容器：

- 它不会自动帮你套一层 shell
- 它不会自动解释 `&&`、`|`、`>`、`$HOME` 这些 shell 语法

### 为什么有时要写 `sh -c`

下面这条命令：

```bash
kubectl exec demo-shell -- sh -c 'echo inside-pod && pwd'
```

需要 `sh`，不是因为“进入容器必须先开 shell”，而是因为：

- 你用了 `&&`
- 这属于 shell 语法
- 必须由容器里的 `sh` 来解释

所以：

- 单条简单命令
  - 直接执行就行
- 多条命令、管道、重定向、变量展开
  - 显式加 `sh -c`

例如：

```bash
kubectl exec demo-shell -- hostname
kubectl exec demo-shell -- ls /
kubectl exec demo-shell -- sh -c 'echo hello && pwd'
```

### `kubectl exec -- sh` 和 `kubectl exec -it -- sh` 的区别

先看这两条：

```bash
kubectl exec demo-shell -- sh
kubectl exec -it demo-shell -- sh
```

这两条都会在容器里启动 `sh`，区别在于有没有交互式终端：

- `kubectl exec demo-shell -- sh`
  - 只是启动 `sh`
  - 没有交互式终端
  - 更适合非交互场景
- `kubectl exec -it demo-shell -- sh`
  - 启动 `sh` 并分配交互式终端
  - 适合你真的进去手动敲命令

这里的：

- `-i`
  - 保持标准输入打开
- `-t`
  - 分配一个终端

如果你要“进去看看”，默认优先用：

```bash
kubectl exec -it demo-shell -- sh
```

进入后可以先试这几条：

```sh
hostname
pwd
ps
exit
```

### 一个常见误区

下面这种写法通常不是你想要的：

```bash
kubectl exec demo-shell -- echo inside-pod && pwd
```

它更接近：

- 先在容器里执行 `echo inside-pod`
- 再在你本机 shell 里执行 `pwd`

所以，多条命令尽量写成：

```bash
kubectl exec demo-shell -- sh -c 'echo inside-pod && pwd'
```

### 一个实用补充

如果一个 Pod 里有多个容器，要加 `-c` 指定容器：

```bash
kubectl exec POD -c app -- pwd
kubectl logs POD -c app
```

如果镜像里没有 `bash`，优先试 `sh`。

## 5. 把四个命令串起来用

学习阶段可以先把最常见的排查顺序固定成这样：

1. `kubectl get`
   看对象是不是存在、是不是 `Running`。
2. `kubectl describe`
   看它调度到哪、事件里有没有报错。
3. `kubectl logs`
   看容器进程输出了什么。
4. `kubectl exec`
   进入容器做进一步确认。

先把这个顺序练熟，后面学 `Deployment`、`Service`、排障时都会重复用到。

## 6. 练完后清理 demo Pod

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
