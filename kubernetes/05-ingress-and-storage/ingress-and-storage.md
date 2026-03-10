# Ingress 与存储

这一节解决两个很实际的问题：

- 应用怎么有一个更像“统一入口”的访问方式
- 应用怎么拿到可以持久保存数据的卷

可以先把这一节拆成两条主线：

- 存储主线
  - `StorageClass -> PVC -> Pod`
- 入口主线
  - `Ingress -> Service -> Pod`

## 0. 先准备实验 namespace

这一节默认在 `edge-demo` namespace 里做实验。

仓库里对应的实际文件是：

- `./edge-demo-namespace.yaml`

先创建它：

```bash
kubectl apply -f ./edge-demo-namespace.yaml
```

## 1. 先看当前集群能力

先确认当前集群里已有的基础能力：

```bash
kubectl get storageclass
kubectl get ingressclass
```

在当前这套 `minikube` 环境里，你通常会看到：

- 一个默认 `StorageClass`
  - 例如 `standard`
- 一个 `IngressClass`
  - 例如 `nginx`

如果 `kubectl get ingressclass` 还没有结果，通常说明 ingress controller 还没准备好。

## 2. 先看 `StorageClass`

可以先把 `StorageClass` 理解成：

- 一类存储的供应方式
- 它定义“系统该怎么给你准备卷”

先看默认的 `StorageClass`：

```bash
kubectl get storageclass
kubectl get storageclass standard -o yaml
```

你先重点看这几个字段：

- `provisioner`
  - 谁来创建卷
- `reclaimPolicy`
  - 资源删除后卷怎么处理
- `volumeBindingMode`
  - 卷在什么时机绑定

入门阶段先记住最重要的直觉：

- `StorageClass` 不是卷本身
- 它更像“创建卷的规则”

## 3. 再创建一个 `PVC`

现在创建一个最小 `PVC`：

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-demo
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

仓库里对应的实际文件是：

- `./data-demo-pvc.yaml`

把这个 YAML 应用到集群：

```bash
kubectl apply -f ./data-demo-pvc.yaml
```

再观察：

```bash
kubectl get pvc -n edge-demo
kubectl get pv
```

这里最重要的关系是：

- `PVC`
  - 你向系统提出“我要一个卷”的请求
- `PV`
  - 系统最终实际给你的卷对象
- `StorageClass`
  - 系统按什么规则去准备这个卷

所以：

- `PVC` 叫 claim
- 因为它是“申请”
- 不是卷本身

## 4. 让一个 Pod 挂上这个卷

现在用一个最小 Pod 来验证这个卷真的能用：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: storage-demo
spec:
  containers:
    - name: storage-demo
      image: busybox:1.36
      command: ["sh", "-c", "echo storage-ok > /data/hello.txt && sleep 3600"]
      volumeMounts:
        - name: app-data
          mountPath: /data
  volumes:
    - name: app-data
      persistentVolumeClaim:
        claimName: data-demo
```

仓库里对应的实际文件是：

- `./storage-demo-pod.yaml`

应用后观察：

```bash
kubectl wait -n edge-demo --for=jsonpath='{.status.phase}'=Bound pvc/data-demo --timeout=180s
kubectl wait -n edge-demo --for=condition=Ready pod/storage-demo --timeout=180s
kubectl get pvc,pv,pod -n edge-demo -o wide
```

再进入容器确认卷已经挂上：

```bash
kubectl exec -n edge-demo storage-demo -- sh -c 'ls -l /data && cat /data/hello.txt'
```

如果一切正常，你应该能看到：

- `/data/hello.txt`
- 内容是 `storage-ok`

这一步把存储链路真正串起来了：

- `StorageClass` 提供规则
- `PVC` 提出申请
- `PV` 被动态创建并绑定
- Pod 最终把这个卷挂到容器里

## 5. 再说 `Ingress` 之前先分清 controller

这里有一个非常容易混淆的点：

- `Ingress`
  - 是一个 Kubernetes 对象
- ingress controller
  - 才是真正负责处理流量的组件

所以：

- 单独创建一个 `Ingress` YAML
  - 不等于流量一定会通
- 必须有可工作的 controller
  - 这个 `Ingress` 才会真正生效

在 `minikube` 里，最常见的入门方式是先启用 addon：

```bash
minikube addons enable ingress
kubectl get ingressclass
kubectl get pods -n ingress-nginx
```

第一次启用时常见情况是：

- 需要拉 `ingress-nginx` 相关镜像
- 所以可能会比普通对象创建更慢

## 6. 创建一个最小 `Deployment` 和 `Service`

现在先准备一个后端应用：

```bash
kubectl apply -f ./web-demo-deployment.yaml
kubectl rollout status deployment/web-demo -n edge-demo --timeout=180s
kubectl apply -f ./web-demo-service.yaml
```

再观察：

```bash
kubectl get deployment,service,pod -n edge-demo -l app=web-demo -o wide
```

这里先记住：

- `Ingress` 通常不是直接指向 Pod
- 它更常见的是指向 `Service`
- 然后再由 `Service` 去找后端 Pod

也就是：

- `Ingress -> Service -> Pod`

## 7. 再创建一个最小 `Ingress`

现在创建一个最小 `Ingress`：

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-demo
spec:
  ingressClassName: nginx
  rules:
    - host: web-demo.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-demo
                port:
                  number: 80
```

仓库里对应的实际文件是：

- `./web-demo-ingress.yaml`

应用后观察：

```bash
kubectl get ingress -n edge-demo
kubectl describe ingress web-demo -n edge-demo
```

重点看：

- `Ingress Class`
  - 当前是不是 `nginx`
- `Rules`
  - host 和 path 是什么
- `Backends`
  - 最终转发到哪个 `Service`
- `Events`
  - controller 有没有同步它

## 8. 验证请求真的走到了后端

在当前这套 `minikube` 环境里，可以直接看 `minikube` 的 IP：

```bash
minikube ip
```

例如当前实验里是：

```text
192.168.49.2
```

然后带上 `Host` 头去访问：

```bash
curl -I -H 'Host: web-demo.local' http://192.168.49.2
```

如果一切正常，你应该能看到类似：

```text
HTTP/1.1 200 OK
```

这一步说明：

- `Ingress` 规则已经被 controller 接管
- controller 已经把请求按 `Host` 转发到了 `Service`
- `Service` 再把流量送到后端 Pod

## 9. 这一节最应该记住的三句话

1. `StorageClass` 是供应规则，`PVC` 是申请，`PV` 是实际卷。
2. `Ingress` 只是对象本身，真正处理流量的是 ingress controller。
3. `Ingress` 通常指向 `Service`，而不是直接指向 Pod。

## 10. 练完后怎么清理

这一节最省事的清理方式也是直接删整个 namespace：

```bash
kubectl delete namespace edge-demo
```

这样通常会把这组实验对象一起删掉：

- `PVC`
- `Pod`
- `Deployment`
- `Service`
- `Ingress`

## 11. 这一节结束后的最小自测

你可以不看文档，自己完成下面这组动作：

1. 查看当前默认 `StorageClass`。
2. 创建一个 `PVC` 并确认它已经 `Bound`。
3. 创建一个挂载这个 `PVC` 的 Pod，并确认容器里能看到文件。
4. 启用并确认 `IngressClass` 可用。
5. 创建一个 `Deployment`、一个 `Service`、一个 `Ingress`。
6. 用 `curl -H 'Host: ...' http://$(minikube ip)` 验证请求已经通到后端。
7. 删除整个实验 namespace。

如果这组动作你已经能自己做出来，就可以进入下一节。

## 下一节做什么

下一节进入：

- `kubernetes/06-rbac-and-serviceaccount`

也就是开始学习：

- `ServiceAccount`
- `Role`
- `RoleBinding`
