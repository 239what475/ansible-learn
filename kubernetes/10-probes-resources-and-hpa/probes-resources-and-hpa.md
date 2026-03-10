# Probes、Resources 与 HPA

这一节解决一个很实际的问题：

- 应用不是“跑起来”就够了，你还需要让 Kubernetes 知道它什么时候可接流量、什么时候该重启、能吃多少资源，以及什么时候该自动扩容

先记住这一节最小主线：

- `probe -> requests/limits -> metrics -> hpa`

## 0. 先启用 `metrics-server`

如果你要练 `HPA`，先要让集群能提供资源指标。

在 `minikube` 里，最常见的做法是：

```bash
minikube addons enable metrics-server
kubectl rollout status deployment/metrics-server -n kube-system --timeout=180s
kubectl top nodes
```

如果最后一条还提示：

- `Metrics API not available`

通常说明：

- `metrics-server` 还没完全就绪

这时先等几十秒，再执行一次：

```bash
kubectl top nodes
```

如果你遇到的是另一种情况：

- addon 已经启用
- 但 `kubectl rollout status deployment/metrics-server -n kube-system` 超时
- `kubectl get pod -n kube-system -l k8s-app=metrics-server` 里看到 `ImagePullBackOff`

可以先试：

```bash
kubectl set image deployment/metrics-server -n kube-system metrics-server=registry.k8s.io/metrics-server/metrics-server:v0.8.1
kubectl rollout status deployment/metrics-server -n kube-system --timeout=180s
kubectl top nodes
```

这一招的直觉可以先理解成：

- 把 addon 下发的镜像引用明确切到 tag-only
- 让这条 `Deployment` 再滚一遍

你刚才实际练到的这个现象，也说明了一件事：

- addon “启用成功”
  - 不等于 Pod 一定已经真正 Ready
- 真正可用的标准还是：
  - `rollout status` 正常
  - `kubectl top nodes` 有结果

这里先记一个很关键的点：

- `HPA`
  - 不是直接凭空知道 CPU 用量
- 它依赖的就是：
  - `metrics-server`

## 1. 先创建实验 namespace

这一节统一在 `runtime-demo` namespace 里做实验。

先创建：

```bash
kubectl apply -f ./runtime-demo-namespace.yaml
```

## 2. 先部署一个带探针和资源限制的应用

这一节仓库里已经准备好一组对象：

- `./probe-web-deployment.yaml`
- `./probe-web-service.yaml`

先应用：

```bash
kubectl apply -f ./probe-web-deployment.yaml
kubectl apply -f ./probe-web-service.yaml
kubectl rollout status deployment/probe-web -n runtime-demo --timeout=240s
```

再观察：

```bash
kubectl get deployment,service,pod -n runtime-demo -o wide
kubectl describe deployment probe-web -n runtime-demo
```

这里的 `probe-web` 有两个设计点：

- 它会先 `sleep 12`
  - 模拟“应用启动不是瞬间完成的”
- 它配置了三种 probe
  - 让你能看到三者分工

## 3. 三种 probe 分别在干什么

先把这三个名字分清楚：

- `startupProbe`
  - 启动保护
- `readinessProbe`
  - 是否可以接流量
- `livenessProbe`
  - 是否还活着，是否需要重启

在这一节的例子里，你最值得建立的直觉是：

- 应用启动慢的时候
  - `startupProbe` 先顶住
- 应用启动完成但还没准备好时
  - `readinessProbe` 决定它暂时不要进 Service
- 应用运行中卡死时
  - `livenessProbe` 可以帮助触发重启

这也是为什么：

- 不是所有 HTTP 健康检查都该只写成一条 `livenessProbe`

## 4. 再看 `requests` 和 `limits`

现在直接看这组资源配置：

```bash
kubectl get deployment probe-web -n runtime-demo \
  -o jsonpath='{.spec.template.spec.containers[0].resources}'
echo
```

这里先分清：

- `requests`
  - 调度时至少给你留多少
- `limits`
  - 最多允许你用到多少

可以先这样记：

- `requests`
  - 更像“保底”
- `limits`
  - 更像“上限”

再记一个后面做 `HPA` 会非常重要的点：

- CPU 型 `HPA`
  - 常常按“当前 CPU 使用量 / CPU request”来算利用率

所以如果你不写 `cpu request`，很多基于利用率的自动扩容就会很别扭，甚至根本没法正确工作。

## 5. 再部署一个专门用来触发 HPA 的工作负载

为了让扩容现象更稳定，这一节不用外部压测工具，而是直接准备一个会持续烧 CPU 的 Deployment：

- `./cpu-burner-deployment.yaml`
- `./cpu-burner-hpa.yaml`

直接应用：

```bash
kubectl apply -f ./cpu-burner-deployment.yaml
kubectl apply -f ./cpu-burner-hpa.yaml
kubectl rollout status deployment/cpu-burner -n runtime-demo --timeout=120s
```

现在观察：

```bash
kubectl get hpa -n runtime-demo
kubectl get deployment cpu-burner -n runtime-demo
kubectl top pod -n runtime-demo
```

如果你想连续观察，可以直接看：

```bash
kubectl get hpa cpu-burner -n runtime-demo -w
```

这里最值得注意的是：

- `cpu-burner`
  - 会一直占 CPU
- `HPA`
  - 会看到利用率持续偏高
- 然后就会把副本数往上调

通常等一两分钟后，你会看到：

- `TARGETS` 不再是 `<unknown>`
- `REPLICAS` 从 `1` 增加到 `2` 或更多

## 6. 这里到底发生了什么

这一节真正串起来的是这条链路：

1. `Deployment` 先声明 `requests` 和 `limits`
2. `metrics-server` 开始提供 CPU 指标
3. `HPA` 读取这些指标
4. `HPA` 判断当前利用率高于目标值
5. `Deployment` 的副本数被自动调大

也就是说：

- `HPA`
  - 不是“看到 Pod 忙了就盲目加机器”
- 它依赖：
  - 资源 request
  - 实时指标
  - 你给它设定的目标阈值

## 7. 这一节最应该记住的三句话

1. `startupProbe` 解决启动慢，`readinessProbe` 决定能不能接流量，`livenessProbe` 解决运行时卡死。
2. `requests` 是保底，`limits` 是上限，而 CPU 型 `HPA` 又常常依赖 `request` 作为利用率基线。
3. `HPA` 想正常工作，前提通常是集群里已经有可用的指标来源，比如 `metrics-server`。

## 8. 练完后怎么清理

这一节的实验对象都在同一个 namespace：

```bash
kubectl delete namespace runtime-demo
```

如果你确认短期内不练 `HPA` 了，也可以把 addon 关掉：

```bash
minikube addons disable metrics-server
```

## 9. 这一节结束后的最小自测

你可以不看文档，自己完成下面这组动作：

1. 启用 `metrics-server` 并确认 `kubectl top nodes` 正常。
2. 部署一个带三种 probe 的应用。
3. 说明三种 probe 的职责差异。
4. 说明 `requests` 和 `limits` 的区别。
5. 部署一个带 CPU request 的工作负载和对应的 `HPA`。
6. 观察它从 `1` 个副本自动扩到更多副本。

如果这组动作你已经能自己做出来，这条 Kubernetes 基础主线就已经开始进入真正的运行时治理阶段了。
