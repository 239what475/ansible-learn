# Incus 安装与初始化

这一节只负责把 `Incus` 装好并初始化，让后面的 `Ansible` 教程能直接创建练习节点。

## 步骤

更新软件包索引：

```bash
sudo apt update
```

安装 `Incus`：

```bash
sudo apt install incus
```

安装 `QEMU` 组件：

```bash
sudo apt install qemu-system
```

添加清华镜像源：

```bash
incus remote add mirror-images https://mirrors.tuna.tsinghua.edu.cn/lxc-images/ --protocol=simplestreams --public
incus image list mirror-images:
```

把当前用户加入 `incus-admin` 组：

```bash
sudo usermod -aG incus-admin $USER
```

执行完后需要重新登录当前会话，或者临时执行：

```bash
newgrp incus-admin
```

第一次使用时初始化 `Incus`：

```bash
incus admin init
```

查看默认 `profile`：

```bash
incus profile show default
```

## Docker 与 Incus 网络兼容

如果这台机器同时运行 `Docker` 和 `Incus`，有时会遇到网络规则冲突。
常见表现是：

- 容器能启动，但网络异常
- `apt update` 很慢或失败
- SSH 或 `Ansible` 连接超时

仓库里已经提供了兼容脚本：

```bash
./scripts/docker_incus_compat.sh
```

说明：

- 如果你没有安装 `Docker`，一般不需要执行这个脚本
- 脚本会调用 `sudo iptables`
- 它主要处理 `DOCKER-USER` 链对 `incusbr0` 的影响

## 建议验证

```bash
incus version
id
incus list
incus image list mirror-images:
```

如果你想确认组权限，也可以执行：

```bash
groups
```

## 说明

- `incus admin init` 通常只需要做一次
- `qemu-system` 主要是为后面可能的 `Incus VM` 做准备
- 如果 `incus list` 仍然报权限错误，通常是因为当前会话还没有刷新用户组
