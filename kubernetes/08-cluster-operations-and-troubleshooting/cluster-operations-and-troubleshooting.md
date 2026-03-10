# 集群操作与排错

这一节解决一个很实际的问题：

- 当发布不符合预期时，你应该按什么顺序观察、定位和恢复

先记住这一节最常用的一条排错路径：

- `get -> describe -> logs -> events -> rollout undo`

## 0. 先准备实验 namespace

这一节默认在 `ops-demo` namespace 里做实验。

仓库里对应的实际文件是：

- `./ops-demo-namespace.yaml`

先创建它：

```bash
kubectl apply -f ./ops-demo-namespace.yaml
```

## 1. 先看集群和系统面是不是正常

很多排错一开始不要急着钻到应用 YAML 里，先看最外层状态：

```bash
kubectl get nodes
kubectl get pods -A -o wide
kubectl get svc -A
```

这一步的目的很简单：

- 先确认是不是整个集群就已经不健康
- 还是只有你自己的应用有问题

入门阶段可以先建立一个很朴素的习惯：

- 先看范围大的状态
- 再缩到 namespace
- 最后再盯具体 Pod

## 2. 先创建一组正常对象

这一节先用一组正常资源建立观察基线。

仓库里对应的实际文件是：

- `./web-demo-deployment.yaml`
- `./web-demo-service.yaml`

直接应用：

```bash
kubectl apply -f ./web-demo-deployment.yaml
kubectl apply -f ./web-demo-service.yaml
kubectl rollout status deployment/web-demo -n ops-demo --timeout=180s
```

再观察：

```bash
kubectl get deployment,replicaset,pod,service -n ops-demo -o wide
```

这里先把链路看清楚：

- `Deployment`
  - 管理发布目标
- `ReplicaSet`
  - 管理副本数
- `Pod`
  - 真正运行应用

所以很多问题都可以沿着：

- `Deployment -> ReplicaSet -> Pod`

一路追下去。

## 3. 先练最常用的三个观察入口

现在针对这组正常对象，先练最常用的三个入口：

```bash
kubectl describe deployment web-demo -n ops-demo
kubectl describe pod -n ops-demo $(kubectl get pod -n ops-demo -l app=web-demo -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n ops-demo deployment/web-demo --tail=20
```

这里先建立一个最小直觉：

- `get`
  - 看概况
- `describe`
  - 看对象细节、条件和事件
- `logs`
  - 看容器里实际输出了什么

很多排错不需要一上来就进节点或容器内部。

先把这三步走顺，通常已经能定位掉一大半问题。

## 4. 再看发布历史

现在再看这次发布记录：

```bash
kubectl rollout history deployment/web-demo -n ops-demo
```

这里可以先理解成：

- `rollout history`
  - 看这个 `Deployment` 之前有哪些版本记录

它不是看日志，而是在看：

- 发布历史
- revision 变化

这一步后面做回滚时会更有感觉。

## 5. 故意制造一次坏发布

现在故意把镜像改成一个不存在的 tag：

```bash
kubectl set image deployment/web-demo -n ops-demo nginx=nginx:does-not-exist
kubectl rollout status deployment/web-demo -n ops-demo --timeout=30s
```

这里第二条命令大概率会超时。

原因不是命令本身坏了，而是：

- 新 Pod 起不来
- 所以这次 rollout 一直完不成

这正是排错时最常见的一类现象：

- 发布开始了
- 但新版本没准备好

## 6. 这时该怎么看

现在先从概况看：

```bash
kubectl get deployment,replicaset,pod -n ops-demo -o wide
```

你通常会看到：

- 老 Pod 可能还在
- 新 Pod 可能处于 `ErrImagePull` 或 `ImagePullBackOff`

接着看具体 Pod：

```bash
kubectl get pod -n ops-demo -l app=web-demo \
  -o custom-columns=NAME:.metadata.name,PHASE:.status.phase,WAITING_REASON:.status.containerStatuses[0].state.waiting.reason
kubectl get events -n ops-demo --sort-by=.metadata.creationTimestamp
```

这时更合理的做法是：

- 先从上面那条输出里找到处于 `ErrImagePull` 或 `ImagePullBackOff` 的 Pod
- 再对那个 Pod 执行：

```bash
kubectl describe pod <failing-pod-name> -n ops-demo
```

这里最值得关注的是：

- `Events`
  - 有没有拉镜像失败
- `Reason`
  - 是不是 `ErrImagePull`、`ImagePullBackOff`
- `Message`
  - 具体是哪个镜像拉不到

这里先记一个很实用的判断：

- `ImagePullBackOff`
  - 往往说明镜像名、tag、仓库权限或网络有问题

也就是说，这一步你不是在“猜”，而是在通过：

- `describe`
- `events`

把问题从“发布失败”缩小到“镜像拉取失败”。

## 7. 用回滚恢复服务

既然已经确定是坏发布，最省事的恢复动作通常就是直接回滚：

```bash
kubectl rollout undo deployment/web-demo -n ops-demo
kubectl rollout status deployment/web-demo -n ops-demo --timeout=180s
```

再确认：

```bash
kubectl get deployment,pod -n ops-demo -l app=web-demo -o wide
kubectl rollout history deployment/web-demo -n ops-demo
```

这里的 `rollout undo` 可以先理解成：

- 把这个 `Deployment`
- 回退到上一个可用 revision

这里还有一个很容易误解的点：

- 回滚恢复的是“配置内容”
- 不是把 revision 编号直接改回旧数字

例如你这条实验链路通常会像这样：

1. `revision 1`
   - 初始正常发布
2. `revision 2`
   - 你把镜像改坏了
3. `revision 3`
   - 你执行 `rollout undo`
   - 系统把旧的正常模板重新发布了一次

所以回滚之后你常常会看到：

- 当前内容已经回到旧版本
- 但当前 revision 反而是一个更新的数字

也就是说：

- revision 更像“发布历史序号”
- 不是“功能版本号”

所以它特别适合这种场景：

- 你已经确认这次新发布有问题
- 而且你更关心先恢复服务
- 不是立刻在线改模板细节

## 8. 这一节最应该记住的三句话

1. 排错通常先从 `get` 看范围，再落到 `describe`、`logs`、`events`。
2. 观察 `Deployment` 出问题时，最好顺着 `Deployment -> ReplicaSet -> Pod` 往下追。
3. 坏发布已经确认时，`kubectl rollout undo` 往往是最快的恢复动作。

## 9. 练完后怎么清理

这一节最省事的清理方式也是直接删整个 namespace：

```bash
kubectl delete namespace ops-demo
```

这样通常会把这组实验对象一起删掉：

- `Deployment`
- `ReplicaSet`
- `Pod`
- `Service`

## 10. 这一节结束后的最小自测

你可以不看文档，自己完成下面这组动作：

1. 创建一组正常的 `Deployment` 和 `Service`。
2. 用 `get`、`describe`、`logs` 看清它们的正常状态。
3. 故意发起一次坏发布。
4. 用 `describe` 和 `events` 定位失败原因。
5. 用 `rollout undo` 把应用恢复回来。
6. 删除整个实验 namespace。

如果这组动作你已经能自己做出来，就可以进入下一节。

## 下一节做什么

下一节进入：

- `kubernetes/09-rebuild-and-repeatability`

也就是开始学习：

- 如何清理并重建本地实验环境
- 如何让实验更容易重复执行
