# ConfigMap Secret Namespace

这一节解决三个很实际的问题：

- 这组资源该放在哪个作用域里
- 普通配置放哪里
- 敏感信息放哪里

可以先把这三个对象这样记：

- `Namespace`
  - 给资源分组和隔离
- `ConfigMap`
  - 放普通配置
- `Secret`
  - 放敏感信息

这一节的主线很简单：

1. 先创建一个独立 `Namespace`
2. 再创建一个 `ConfigMap`
3. 再创建一个 `Secret`
4. 最后让一个 `Deployment` 读到这些值

## 1. 先创建一个 `Namespace`

先建一个单独的实验 namespace：

```bash
kubectl create namespace app-demo
kubectl get ns
```

这里先建立一个直觉：

- 很多 Kubernetes 资源都是“按 namespace 隔离”的
- 同名对象可以分别出现在不同 namespace 里
- 你查询资源时，常常要显式带上 `-n`

例如：

```bash
kubectl get configmap app-config -n app-demo
kubectl get configmap app-config
```

如果对象只存在于 `app-demo`，那第二条在默认 namespace 里通常会报 `NotFound`。

这就是 `Namespace` 的最小价值：

- 给一组资源划边界
- 避免不同实验混在一起
- 清理时更方便

## 2. 再创建一个 `ConfigMap`

现在放一组普通配置进去：

```bash
kubectl create configmap app-config -n app-demo \
  --from-literal=APP_MODE=demo \
  --from-literal=APP_COLOR=blue
```

再观察：

```bash
kubectl get configmap app-config -n app-demo
kubectl get configmap app-config -n app-demo -o yaml
```

最小 YAML 可以先看成这样：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: app-demo
data:
  APP_MODE: demo
  APP_COLOR: blue
```

这里最重要的是：

- `ConfigMap` 适合放普通配置
- 这些值在 YAML 里通常就是明文
- 所以它不适合拿来存密码、token 这类敏感信息

## 3. 再创建一个 `Secret`

现在放一组敏感信息进去：

```bash
kubectl create secret generic app-secret -n app-demo \
  --from-literal=DB_USER=demo \
  --from-literal=DB_PASS=s3cr3t
```

这里的 `generic` 可以先理解成：

- 通用型 `Secret`
- 不是 `tls` 专用，也不是镜像仓库登录专用

也就是说：

- `app-secret`
  - 才是这个 `Secret` 的名字
- `generic`
  - 是 `kubectl create secret` 的创建类型

入门阶段先把它理解成“最常见的通用键值对 Secret”就够了。

再观察：

```bash
kubectl get secret app-secret -n app-demo
kubectl get secret app-secret -n app-demo -o yaml
```

最小 YAML 可以先看成这样：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: app-demo
type: Opaque
data:
  DB_USER: ZGVtbw==
  DB_PASS: czNjcjN0
```

这里先记住两个点：

- `Secret` 比 `ConfigMap` 更适合存敏感信息
- 但 YAML 里看到的 base64 只是编码，不等于真正加密

所以不要把 “看起来不是明文” 理解成 “已经足够安全”。

## 4. 让一个 `Deployment` 读取这些值

现在创建一个最小 `Deployment`：

```bash
kubectl create deployment env-demo -n app-demo --image=busybox:1.36 -- sleep 3600
```

再把 `ConfigMap` 和 `Secret` 注进这个 `Deployment`：

```bash
kubectl set env deployment/env-demo -n app-demo --from=configmap/app-config
kubectl set env deployment/env-demo -n app-demo --from=secret/app-secret
kubectl rollout status deployment/env-demo -n app-demo --timeout=180s
```

再观察：

```bash
kubectl get deployment env-demo -n app-demo
kubectl get pods -n app-demo -l app=env-demo -o wide
kubectl describe deployment env-demo -n app-demo
```

这一步先建立最重要的直觉：

- `ConfigMap` 和 `Secret` 本身不会自动“生效”
- 你要让 Pod 或 Deployment 显式引用它们
- 引用之后，容器里才能看到这些值

## 5. 进入容器确认变量已经生效

现在直接验证容器里能不能读到这些变量：

```bash
kubectl exec -n app-demo deployment/env-demo -- sh -c 'echo APP_MODE=$APP_MODE APP_COLOR=$APP_COLOR DB_USER=$DB_USER DB_PASS=$DB_PASS'
```

如果一切正常，你应该能看到类似：

```text
APP_MODE=demo APP_COLOR=blue DB_USER=demo DB_PASS=s3cr3t
```

这一步很重要，因为它把前面的链路真正串起来了：

- `Namespace`
  - 决定对象在哪个作用域里
- `ConfigMap`
  - 提供普通配置
- `Secret`
  - 提供敏感信息
- `Deployment`
  - 把这些值带进 Pod

## 6. 这一节最应该记住的区别

### `ConfigMap` 和 `Secret`

- `ConfigMap`
  - 放普通配置
- `Secret`
  - 放敏感信息

两者都可以被 Pod 使用，但它们的意图不同。

### `Secret` 和真正加密

- `Secret` 的 YAML 里常常是 base64
- base64 是编码，不是加密

所以：

- 不要把真实生产密码随便直接写进仓库
- 学习阶段可以用演示值
- 真正生产环境还要结合更严格的密钥管理方式

### 为什么总要写 `-n app-demo`

因为这组对象都在 `app-demo` namespace 里。

如果你不带 `-n`，`kubectl` 默认查的是当前默认 namespace，很多对象就会看不到。

## 7. 一个最小 YAML 视角

如果你想把这节内容压缩成一个最小心智模型，可以先看成：

- `Namespace`
  - 决定资源属于哪一组
- `ConfigMap`
  - 提供非敏感配置
- `Secret`
  - 提供敏感配置
- `Deployment`
  - 引用前两者，并把值带进 Pod

这一节的重点不是把所有写法背下来，而是先看懂这条依赖关系。

## 8. 练完后怎么清理

这一节最省事的清理方式通常是直接删整个 namespace：

```bash
kubectl delete namespace app-demo
```

这样通常会把里面这组实验资源一起删掉：

- `ConfigMap`
- `Secret`
- `Deployment`
- Pod

这也是 `Namespace` 在实验环境里很实用的原因之一。

## 9. 这一节结束后的最小自测

你可以不看文档，自己完成下面这组动作：

1. 创建一个新的 namespace。
2. 在这个 namespace 里创建一个 `ConfigMap`。
3. 在这个 namespace 里创建一个 `Secret`。
4. 创建一个 `Deployment` 并让它读到这两组值。
5. 用 `kubectl exec` 进入或检查容器，确认变量已经生效。
6. 删除整个 namespace 完成清理。

如果这组动作你已经能自己做出来，就可以进入下一节。

## 下一节做什么

下一节进入：

- `kubernetes/05-ingress-and-storage`

也就是开始学习：

- `Ingress`
- `PVC`
- `StorageClass`
