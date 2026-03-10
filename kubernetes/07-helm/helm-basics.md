# Helm

这一节解决一个很实际的问题：

- 当一组 Kubernetes YAML 变多以后，怎么把它们组织成一份可复用、可覆盖默认值、可重复安装的包

先记住这一节的最小主线：

- `Chart -> values -> rendered YAML -> release`

## 0. 先确认 `helm` 可用

这一节开始之前，先确认本机已经有 `helm`：

```bash
helm version
```

如果这里还报 `command not found`，先安装 `helm`，再继续这一节。

## 1. 先看一个最小 chart 长什么样

这一节仓库里已经准备好一个最小 chart：

- `./web-demo/`

你可以先看目录：

```bash
find ./web-demo -maxdepth 3 -type f | sort
```

最重要的文件有这几类：

- `Chart.yaml`
  - 这份 chart 的元信息
- `values.yaml`
  - 默认值
- `templates/`
  - 真正会被渲染成 Kubernetes YAML 的模板

你先把 Helm chart 理解成：

- 一份带模板能力的 Kubernetes 应用包

这里再补一个很容易误解的点：

- `templates/`
  - 不是 Helm 在运行时自动“现场生成”的目录
- 这里面的模板文件
  - 通常就是 chart 作者手工维护的内容

Helm 真正自动做的是：

- 读取这些模板
- 结合 `values.yaml`
- 渲染出最终 YAML

你当然也可以先用：

```bash
helm create mychart
```

让 Helm 帮你起一个初始骨架。

但那个“自动生成”发生在你创建 chart 骨架的时候，不是在每次执行 `helm template` 或 `helm install` 的时候。

## 2. 先看 `Chart.yaml`

先看这份 chart 的元信息：

```bash
sed -n '1,120p' ./web-demo/Chart.yaml
```

这里先重点记住：

- `name`
  - chart 名字
- `version`
  - chart 版本
- `appVersion`
  - 这份 chart 默认要部署的应用版本

入门阶段最重要的直觉是：

- `chart version`
  - 是这份打包模板本身的版本
- `appVersion`
  - 是应用版本

两者不一定同步变化。

## 3. 再看 `values.yaml`

现在看默认值：

```bash
sed -n '1,200p' ./web-demo/values.yaml
```

这里会看到几类很常见的值：

- `replicaCount`
- `image.repository`
- `image.tag`
- `service.port`

你可以先把 `values.yaml` 理解成：

- 这份 chart 的默认配置入口

也就是说：

- 模板里不要把每个值都写死
- 更常见的是从 `Values` 里取

这里很容易产生一个误解：

- `values.yaml`
  - 不是 Kubernetes 资源定义
- 它也不是 Kubernetes YAML 的某种“简化写法”

更准确地说：

- `values.yaml`
  - 是这份 chart 的输入参数
- `templates/*.yaml`
  - 才是带模板语法的 Kubernetes YAML
- 最后渲染出来的结果
  - 才是真正提交给集群的 Kubernetes 资源

所以 Helm 更像是在 Kubernetes 上面再加了一层模板系统，而不是发明了一种新的 Kubernetes 方言。

## 4. 先看模板渲染结果

还不要急着装到集群，先做两步静态检查：

```bash
helm lint ./web-demo
helm template web-demo ./web-demo
```

这里的两个命令解决的是两个不同问题：

- `helm lint`
  - 看 chart 结构和模板有没有明显问题
- `helm template`
  - 不连集群，直接把模板渲染成最终 YAML

这里顺手记一个很实用的判断：

- `helm template`
  - 不是安装时必须单独执行的一步
- 因为 `helm upgrade --install`
  - 自己也会先渲染模板
  - 然后再把结果提交到集群

所以：

- `helm template`
  - 更像“先把最终 YAML 摊开看一遍”
- 它特别适合学习、调模板和排错
- 但不是部署成功的必要前置动作

这是 Helm 入门里一个很重要的习惯：

- 先 `lint`
- 再 `template`
- 最后再真正 `install`

## 5. 再用一份覆盖值

这一节仓库里还准备了一份覆盖默认值的文件：

- `./values-dev.yaml`

你可以直接这样看渲染差异：

```bash
helm template web-demo ./web-demo -f ./values-dev.yaml
```

这里这份覆盖值主要改了两件事：

- 副本数从 `1` 改到 `2`
- 镜像标签从 `1.27` 改到 `1.27-alpine`

这一步最值得建立的直觉是：

- `values.yaml`
  - 放默认值
- `values-dev.yaml`
  - 放某个环境的覆盖值

这样你就不用为每个环境复制整份模板。

## 6. 再真正安装一条 release

现在把这份 chart 装到集群里：

```bash
helm upgrade --install web-demo ./web-demo -n helm-demo --create-namespace
kubectl rollout status deployment/web-demo -n helm-demo --timeout=180s
```

这里的 `helm upgrade --install` 可以先理解成：

- 如果这条 release 还不存在
  - 就安装
- 如果已经存在
  - 就升级

这也是 Helm 里最常见的一条入口命令。

再观察：

```bash
helm list -n helm-demo
kubectl get deployment,service,pod -n helm-demo -l app.kubernetes.io/instance=web-demo -o wide
```

这里先把两个词分清楚：

- `chart`
  - 模板和默认值本身
- `release`
  - 某次安装后的实例

也就是说：

- `./web-demo`
  - 是 chart
- `web-demo`
  - 这里既是 release 名，也是你这次安装出来的一条 release 实例

## 7. 再做一次升级

现在用覆盖值来升级这条 release：

```bash
helm upgrade web-demo ./web-demo -n helm-demo -f ./values-dev.yaml
kubectl rollout status deployment/web-demo -n helm-demo --timeout=180s
```

再观察：

```bash
kubectl get deployment web-demo -n helm-demo
kubectl get pod -n helm-demo -l app.kubernetes.io/instance=web-demo -o wide
helm get values web-demo -n helm-demo
```

这一步你最值得确认的是：

- 副本数已经变成 `2`
- 生效的镜像标签已经变成 `1.27-alpine`
- `helm get values` 能看到当前 release 覆盖过的值

所以 Helm 的核心价值之一是：

- 不只是帮你“安装一组 YAML”
- 还帮你记住“这条 release 当前是按什么值装出来的”

## 8. 这一节最应该记住的三句话

1. `chart` 是模板包，`release` 是某次安装出来的实例。
2. `values.yaml` 放默认值，环境差异更适合写进额外的 values 文件。
3. `helm upgrade --install` 是最常见的 Helm 部署入口。

## 9. 练完后怎么清理

这一节最常见的清理方式是：

```bash
helm uninstall web-demo -n helm-demo
kubectl delete namespace helm-demo
```

这样通常会把这组实验对象一起清掉。

## 10. 这一节结束后的最小自测

你可以不看文档，自己完成下面这组动作：

1. 对一份 chart 先执行 `helm lint`。
2. 用 `helm template` 看渲染结果。
3. 用 `helm upgrade --install` 安装一条 release。
4. 用额外的 values 文件做一次升级。
5. 用 `helm get values` 确认当前 release 的覆盖值。
6. 卸载 release 并删除实验 namespace。

如果这组动作你已经能自己做出来，就可以进入下一节。

## 下一节做什么

下一节进入：

- `kubernetes/08-cluster-operations-and-troubleshooting`

也就是开始学习：

- 常见排错入口
- 事件和日志观察
- 更新、回滚和故障定位
