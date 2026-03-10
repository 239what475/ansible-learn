# 重建与可重复性

这一节解决一个很实际的问题：

- 你怎么证明这套实验不是“碰巧这次跑通了”，而是真的能重复搭起来

先记住这一节最小主线：

- `manifests -> apply -> clean -> re-apply -> same result`

再加一层环境视角：

- `profile create -> apply -> delete profile -> recreate -> same result`

## 0. 先明确这一节不碰主练习集群

这一节会提到“删掉再重建”，但不建议你直接对主 `minikube` 集群这么做。

更稳的做法是：

- 主集群继续拿来平时练章节
- 另起一个独立 profile
  - 专门拿来做重建实验

所以这一节会同时讲两层重复性：

- 应用级重复性
- 环境级重复性

## 1. 先准备一组固定 manifests

这一节仓库里已经准备好一组最小对象：

- `./repeat-demo-namespace.yaml`
- `./repeat-web-deployment.yaml`
- `./repeat-web-service.yaml`

它们的目的很简单：

- 让你有一组固定输入
- 之后无论删除 namespace，还是重建整个 profile
- 都还是拿同一组文件去恢复

这就是可重复性的一个核心起点：

- 优先保存声明式输入
- 不要只依赖终端里零散敲过哪些命令

## 2. 先在当前主集群里重复一次应用级实验

现在先在当前集群里应用这组文件：

```bash
kubectl apply -f ./repeat-demo-namespace.yaml
kubectl apply -f ./repeat-web-deployment.yaml
kubectl apply -f ./repeat-web-service.yaml
kubectl rollout status deployment/repeat-web -n repeat-demo --timeout=180s
```

再观察：

```bash
kubectl get deployment,service,pod -n repeat-demo -o wide
```

到这一步你先有了一份“正常结果”的基线。

## 3. 删掉 namespace，再用同一组文件恢复

现在先只删应用，不删整个集群：

```bash
kubectl delete namespace repeat-demo
kubectl get ns repeat-demo
```

等 namespace 真正消失后，再用完全相同的文件重建：

```bash
kubectl apply -f ./repeat-demo-namespace.yaml
kubectl apply -f ./repeat-web-deployment.yaml
kubectl apply -f ./repeat-web-service.yaml
kubectl rollout status deployment/repeat-web -n repeat-demo --timeout=180s
```

如果这两次结果一致，你就已经证明了一件事：

- 这组应用级实验是可重复的

也就是说：

- 不是“因为你记得刚才手工改了什么，所以这次才成功”
- 而是“同一组输入本身就能稳定恢复结果”

## 4. 再把视角升到环境级重复性

很多时候，真正会让人失去信心的不是 namespace 级清理，而是：

- 主集群状态已经很脏
- 你不确定哪些对象是旧实验留下的
- 也不确定当前问题是不是环境残留引起的

这时更稳的做法是：

- 用一个独立 profile
- 从空环境重新开始

例如这一节建议用：

```bash
minikube start -p repeat-demo-profile --nodes 1
minikube -p repeat-demo-profile status
```

这里先记住：

- `profile`
  - 可以理解成一套独立的本地集群实例

所以你完全可以：

- 保留主 `minikube`
- 再额外起一个 `repeat-demo-profile`

这样做比直接删主集群安全得多。

## 5. 在独立 profile 里再应用同一组文件

现在把目标切到这个独立 profile：

```bash
minikube -p repeat-demo-profile kubectl -- apply -f ./repeat-demo-namespace.yaml
minikube -p repeat-demo-profile kubectl -- apply -f ./repeat-web-deployment.yaml
minikube -p repeat-demo-profile kubectl -- apply -f ./repeat-web-service.yaml
minikube -p repeat-demo-profile kubectl -- rollout status deployment/repeat-web -n repeat-demo --timeout=180s
```

再观察：

```bash
minikube -p repeat-demo-profile kubectl -- get deployment,service,pod -n repeat-demo -o wide
```

这里你最应该确认的是：

- 新 profile 里同样能把对象建起来
- 结果和主集群里的那组实验是一致的

这一步说明：

- 你的 manifests 不依赖某个“历史偶然状态”
- 换一个新的本地集群，仍然能得到一样结果

## 6. 再把整个 profile 删掉并重建

现在真正做一次环境级重建：

```bash
minikube delete -p repeat-demo-profile
minikube start -p repeat-demo-profile --nodes 1
minikube -p repeat-demo-profile status
```

然后还是用完全相同的那组文件重建：

```bash
minikube -p repeat-demo-profile kubectl -- apply -f ./repeat-demo-namespace.yaml
minikube -p repeat-demo-profile kubectl -- apply -f ./repeat-web-deployment.yaml
minikube -p repeat-demo-profile kubectl -- apply -f ./repeat-web-service.yaml
minikube -p repeat-demo-profile kubectl -- rollout status deployment/repeat-web -n repeat-demo --timeout=180s
```

如果这一步也还正常，你就得到了这一节最重要的结论：

- 同一组输入
- 在新的环境里
- 仍然得到同样结果

这才是“可重复性”最有价值的部分。

## 7. 这一节最应该记住的三句话

1. 可重复性来自固定输入，而不是你记得上次手工敲过什么。
2. 应用级清理通常删 namespace，环境级重建更适合用独立 profile。
3. 真正可靠的实验，应该能在新环境里用同一组文件重新恢复出来。

## 8. 练完后怎么清理

应用级清理：

```bash
kubectl delete namespace repeat-demo
```

环境级清理：

```bash
minikube delete -p repeat-demo-profile
```

## 9. 这一节结束后的最小自测

你可以不看文档，自己完成下面这组动作：

1. 用固定 manifests 建一组最小应用。
2. 删除 namespace，并用同一组 manifests 恢复。
3. 起一个独立 profile。
4. 在独立 profile 里再次应用同一组 manifests。
5. 删除这个 profile，再从零重建一次。
6. 确认结果和前面保持一致。

如果这组动作你已经能自己做出来，就可以进入下一节。

## 下一节做什么

下一节进入：

- `kubernetes/10-terraform-ansible-and-kubernetes`

也就是开始把前面几条主线真正串起来：

- 用 `Terraform` 管实验资源
- 用 `Ansible` 管初始化
- 用 `Kubernetes` 管应用
