# RBAC 与 ServiceAccount

这一节解决两个很实际的问题：

- 这个 Pod 以什么身份访问 Kubernetes API
- 这个身份到底被允许做什么

先记住这一节的两条最小路径：

- 身份：`ServiceAccount -> Pod`
- 权限：`Role -> RoleBinding -> ServiceAccount`

## 0. 先准备实验 namespace

这一节默认在 `auth-demo` namespace 里做实验。

仓库里对应的实际文件是：

- `./auth-demo-namespace.yaml`

先创建它：

```bash
kubectl apply -f ./auth-demo-namespace.yaml
```

## 1. 先看默认 `ServiceAccount`

先观察这个 namespace 里默认有哪些 `ServiceAccount`：

```bash
kubectl get sa -n auth-demo
```

通常你会先看到一个：

- `default`

这里先建立一个直觉：

- `ServiceAccount`
  - 是给 Pod 用的身份
- 它不是给人登录集群用的普通用户账号

为什么先看默认的 `default`？

因为很多 Pod 如果你不显式指定 `serviceAccountName`，就会自动用它。

但入门阶段应该尽快养成一个习惯：

- 不要把业务权限都堆到 `default`
- 更合理的做法是按用途创建专用 `ServiceAccount`

## 2. 创建一个专用 `ServiceAccount`

现在创建一个最小 `ServiceAccount`：

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: viewer
  namespace: auth-demo
```

仓库里对应的实际文件是：

- `./viewer-serviceaccount.yaml`

直接应用：

```bash
kubectl apply -f ./viewer-serviceaccount.yaml
kubectl get sa -n auth-demo
```

这里先记住：

- `viewer`
  - 只是一个身份名字
- 它本身还没有权限

也就是说：

- 创建了 `ServiceAccount`
- 不等于它已经能读 Pod、看 Secret 或修改资源

## 3. 再创建一个 `Role`

现在给它准备一组最小权限：

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: auth-demo
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
```

仓库里对应的实际文件是：

- `./pod-reader-role.yaml`

直接应用：

```bash
kubectl apply -f ./pod-reader-role.yaml
kubectl get role -n auth-demo
kubectl describe role pod-reader -n auth-demo
```

这里最重要的是：

- `Role`
  - 只定义“能做什么”
- 它不代表“谁来做”

还要再记一个边界：

- `Role`
  - 是 namespace 级权限
- 所以这里只在 `auth-demo` 里生效

## 4. 用 `RoleBinding` 把身份和权限绑起来

现在把 `viewer` 和 `pod-reader` 绑起来：

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: viewer-pod-reader
  namespace: auth-demo
subjects:
  - kind: ServiceAccount
    name: viewer
    namespace: auth-demo
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-reader
```

仓库里对应的实际文件是：

- `./pod-reader-binding.yaml`

直接应用：

```bash
kubectl apply -f ./pod-reader-binding.yaml
kubectl get rolebinding -n auth-demo
kubectl describe rolebinding viewer-pod-reader -n auth-demo
```

这里最应该看清楚的是：

- `subjects`
  - 谁拿到这份权限
- `roleRef`
  - 引用的是哪一个 `Role`

到这一步，这条链路才完整：

- `viewer`
  - 是身份
- `pod-reader`
  - 是权限集合
- `viewer-pod-reader`
  - 是绑定关系

## 5. 让一个 Pod 用上这个身份

现在创建一个最小 Pod，并显式指定 `serviceAccountName`：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: viewer-check
  namespace: auth-demo
spec:
  serviceAccountName: viewer
  containers:
    - name: viewer-check
      image: busybox:1.36
      command: ["sh", "-c", "sleep 3600"]
```

仓库里对应的实际文件是：

- `./viewer-check-pod.yaml`

直接应用：

```bash
kubectl apply -f ./viewer-check-pod.yaml
kubectl wait -n auth-demo --for=condition=Ready pod/viewer-check --timeout=180s
kubectl get pod viewer-check -n auth-demo -o jsonpath='{.spec.serviceAccountName}'; echo
```

如果一切正常，你应该能看到：

```text
viewer
```

这一步建立的是另一条链路：

- `ServiceAccount`
  - 是身份
- `Pod`
  - 通过 `serviceAccountName` 使用这个身份

## 6. 用 `kubectl auth can-i` 验证权限

现在不要只看 YAML，要验证权限到底有没有生效。

先执行：

```bash
kubectl auth can-i list pods -n auth-demo --as=system:serviceaccount:auth-demo:viewer
kubectl auth can-i get secrets -n auth-demo --as=system:serviceaccount:auth-demo:viewer
kubectl auth can-i list pods -n default --as=system:serviceaccount:auth-demo:viewer
```

这里这个身份字符串：

```text
system:serviceaccount:auth-demo:viewer
```

可以先理解成：

- `system:serviceaccount`
  - 说明这是 Kubernetes 里的 `ServiceAccount` 身份
- `auth-demo`
  - 这个身份属于哪个 namespace
- `viewer`
  - 具体的 `ServiceAccount` 名字

如果前面的对象都已经创建好，你通常会看到：

- 在 `auth-demo` 里 `list pods`
  - `yes`
- 在 `auth-demo` 里 `get secrets`
  - `no`
- 到 `default` 里 `list pods`
  - `no`

这三条结果正好说明三件事：

- 权限已经真的生效
- 这份权限只允许看 `pods`
- 这份权限只在 `auth-demo` 这个 namespace 里有效

这也是入门阶段最重要的 RBAC 直觉：

- 权限要尽量小
- 作用域要尽量清楚

## 7. 再从 Pod 里看一下这个身份

你也可以再进入 Pod 看一眼 ServiceAccount 投影进来的信息：

```bash
kubectl exec -n auth-demo viewer-check -- cat /var/run/secrets/kubernetes.io/serviceaccount/namespace
```

如果一切正常，你应该能看到：

```text
auth-demo
```

这一步先建立一个基础直觉：

- Pod 不是“凭空有权限”
- 它是因为拿到了某个 `ServiceAccount` 身份
- 这个身份再通过 RBAC 规则获得权限

至于 token、投影卷和 API 访问细节，入门阶段先知道这条关系就够了。

## 8. 这一节最应该记住的三句话

1. `ServiceAccount` 解决的是“Pod 以谁的身份做事”。
2. `Role` 只定义权限，`RoleBinding` 才负责把权限给到具体主体。
3. namespaced `Role` 的权限范围不会自动跨到别的 namespace。

## 9. 练完后怎么清理

这一节最省事的清理方式也是直接删整个 namespace：

```bash
kubectl delete namespace auth-demo
```

这样通常会把这组实验对象一起删掉：

- `ServiceAccount`
- `Role`
- `RoleBinding`
- `Pod`

## 10. 这一节结束后的最小自测

你可以不看文档，自己完成下面这组动作：

1. 创建一个专用 `ServiceAccount`，不要直接用 `default`。
2. 创建一个只允许查看 `pods` 的 `Role`。
3. 用 `RoleBinding` 把这份权限交给那个 `ServiceAccount`。
4. 创建一个使用这个 `ServiceAccount` 的 Pod。
5. 用 `kubectl auth can-i --as=system:serviceaccount:...` 验证它能做和不能做的事。
6. 删除整个实验 namespace。

如果这组动作你已经能自己做出来，就可以进入下一节。

## 下一节做什么

下一节进入：

- `kubernetes/07-helm`

也就是开始学习：

- `Helm` 的基本结构
- `Chart`
- `values.yaml`
