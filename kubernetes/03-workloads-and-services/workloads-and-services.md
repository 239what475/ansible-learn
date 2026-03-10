# 工作负载与 Service

这一节开始真正创建应用对象。

你会碰到三个最核心的对象：

- `Pod`
  - 最小运行单元
- `Deployment`
  - 管理一组 Pod 的控制器
- `Service`
  - 给一组 Pod 提供稳定访问入口

先记住这一节的主线：

1. 先创建一个单独的 `Pod`
2. 再创建一个 `Deployment`
3. 再给这个 `Deployment` 配一个 `Service`
4. 再练 `scale` 和滚动更新

## 0. 先看当前集群

```bash
kubectl get nodes
kubectl get pods -A -o wide
kubectl get svc -A
```

这一节后面的实验默认都在 `default` namespace 里做。

## 1. 先用一个单独的 `Pod`

先创建一个最简单的 `nginx` Pod：

```bash
kubectl run pod-demo --image=nginx:1.27 --restart=Never
kubectl wait --for=condition=Ready pod/pod-demo --timeout=180s
```

再观察它：

```bash
kubectl get pod pod-demo -o wide
kubectl describe pod pod-demo
```

如果你想看最小 YAML，可以先理解成这样：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-demo
spec:
  containers:
    - name: pod-demo
      image: nginx:1.27
  restartPolicy: Never
```

仓库里对应的实际文件是：

- `./pod-demo.yaml`

你也可以直接：

```bash
kubectl apply -f ./pod-demo.yaml
```

这里先建立两个直觉：

- 你当然可以直接创建一个裸 `Pod`
- 但它更适合学习和临时实验，不适合长期运行业务

原因很简单：

- 这个 `Pod` 挂了，不会自动补一个同类出来
- 你要扩成多个副本，也不是靠它自己完成

所以裸 `Pod` 更像：

- 一个单独运行实例
- 一个观察对象
- 一个临时实验对象

## 2. 再用 `Deployment` 管理 Pod

现在创建一个 `Deployment`：

```bash
kubectl create deployment web-demo --image=nginx:1.27
kubectl rollout status deployment/web-demo --timeout=180s
```

再观察：

```bash
kubectl get deployment web-demo
kubectl get pods -l app=web-demo -o wide
kubectl describe deployment web-demo
```

最小 YAML 可以先看成这样：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-demo
  template:
    metadata:
      labels:
        app: web-demo
    spec:
      containers:
        - name: nginx
          image: nginx:1.27
```

仓库里对应的实际文件是：

- `./web-demo-deployment.yaml`

你也可以直接：

```bash
kubectl apply -f ./web-demo-deployment.yaml
```

这里最重要的是关系要看清楚：

- `Deployment` 自己不是容器
- `Deployment` 负责管理 Pod
- 你真正运行起来的应用实例，仍然是 Pod

可以先这样记：

- Pod 是“干活的实例”
- Deployment 是“管理这批实例的控制器”

你也可以顺手看一下：

```bash
kubectl get rs
```

会发现 `Deployment` 下通常还会有一个 `ReplicaSet`。

入门阶段先记到这一步就够：

- `Deployment`
  - 管理期望状态
- `ReplicaSet`
  - 保证副本数
- `Pod`
  - 真正运行应用

## 3. 再给 `Deployment` 配一个 `Service`

现在给 `web-demo` 暴露一个 `Service`：

```bash
kubectl expose deployment web-demo --port=80 --target-port=80 --type=ClusterIP
```

再观察：

```bash
kubectl get service web-demo
kubectl describe service web-demo
kubectl get pods -l app=web-demo -o wide
```

最小 YAML 可以先看成这样：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-demo
spec:
  selector:
    app: web-demo
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

仓库里对应的实际文件是：

- `./web-demo-service.yaml`

你也可以直接：

```bash
kubectl apply -f ./web-demo-service.yaml
```

这里最重要的是 `selector`：

- `Service` 不会绑死某个 Pod
- 它是通过标签选择一组 Pod

也就是说：

- `app=web-demo` 的 Pod 变了
- `Service` 仍然可以继续指向新的那一组 Pod

这就是为什么我们前面一直说：

- `Service` 关注的是“稳定入口”
- 不是某个固定 Pod

如果你看 `kubectl describe service web-demo`，重点观察：

- `Selector`
  - 它在选哪组 Pod
- `IP`
  - `Service` 的集群内部地址
- `Endpoints`
  - 当前实际后端 Pod 地址

## 4. 练副本扩容

把 `web-demo` 从 `1` 个副本扩到 `3` 个：

```bash
kubectl scale deployment/web-demo --replicas=3
kubectl rollout status deployment/web-demo --timeout=180s
```

再观察：

```bash
kubectl get deployment web-demo
kubectl get pods -l app=web-demo -o wide
kubectl describe service web-demo
```

这一步你最值得确认的是：

- `Deployment` 的 `READY` 变成了 `3/3`
- 现在有 `3` 个 `web-demo` Pod
- `Service` 的后端也跟着变成这一组 Pod

这一步会直接帮助你建立一个很重要的直觉：

- 扩容主要是改 `Deployment`
- `Service` 不用跟着手改每个 Pod
- 只要标签还匹配，`Service` 会继续工作

## 5. 再练一次滚动更新

现在把镜像改成另一个标签，发起一次滚动更新：

```bash
kubectl set image deployment/web-demo nginx=nginx:1.27-alpine
kubectl rollout status deployment/web-demo --timeout=180s
```

再观察：

```bash
kubectl get deployment web-demo
kubectl get pods -l app=web-demo -o wide
kubectl describe deployment web-demo
```

这一步重点看什么：

- 新 Pod 会逐步起来
- 旧 Pod 会逐步退出
- 整个过程里副本不会一下子全消失

这就是 `Deployment` 默认滚动更新策略的价值：

- 不需要你手工删 Pod 再重建
- 系统会尽量平滑地把旧版本替换成新版本

如果你想确认镜像真的变了，可以看：

```bash
kubectl get deployment web-demo -o yaml
```

重点盯：

- `spec.template.spec.containers[].image`

## 6. 这一节最重要的三句话

1. 裸 `Pod` 适合学习和临时实验，但长期运行的应用通常交给 `Deployment` 管理。
2. `Deployment` 管的是副本数和更新过程，真正跑应用的仍然是 Pod。
3. `Service` 通过标签选择一组 Pod，所以 Pod 变化时它仍然能提供稳定入口。

## 7. 练完后清理对象

这一节的临时对象可以这样清理：

```bash
kubectl delete service web-demo
kubectl delete deployment web-demo
kubectl delete pod pod-demo
```

## 这一节结束后的最小自测

你可以不看文档，自己完成下面这组动作：

1. 创建一个裸 `Pod` 并确认它已经 `Ready`。
2. 创建一个 `Deployment` 并确认它已经 rollout 完成。
3. 给这个 `Deployment` 暴露一个 `ClusterIP Service`。
4. 把 `Deployment` 从 `1` 个副本扩到 `3` 个。
5. 改一次镜像并观察滚动更新完成。
6. 清理这一节创建的对象。

如果这组动作你已经能自己做出来，就可以进入下一节。

## 下一节做什么

下一节进入：

- `kubernetes/04-configmap-secret-namespace`

也就是开始学习：

- `ConfigMap`
- `Secret`
- `Namespace`
