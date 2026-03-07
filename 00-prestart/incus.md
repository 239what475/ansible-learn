# Incus 安装与初始化

这一节先记录在开始学习 `Ansible` 之前，需要准备好的 `Incus` 环境。

这个仓库后面的教程默认使用：

- `Incus` 容器作为被管理节点
- `Ansible` 作为控制端工具
- `uv + .venv` 作为本地 Python/Ansible 运行环境

## 目标

完成这一节后，你应该具备下面这些能力：

- 本机已经安装 `Incus`
- 本机具备创建虚拟机所需的 `QEMU` 组件
- `Incus` 已配置国内镜像源
- 当前用户具备访问 `Incus` 守护进程的权限
- `Incus` 已完成初始化
- 能查看默认 `profile` 配置

## 1. 安装 Incus

先更新软件包索引：

```bash
sudo apt update
```

安装 `Incus`：

```bash
sudo apt install incus
```

## 2. 安装 QEMU 组件

如果后续只使用容器，这一步不是绝对必须；
但考虑到后面的教程可能会扩展到 `Incus VM`，建议一开始就装上：

```bash
sudo apt install qemu-system
```

## 3. 配置镜像源

为了更方便地拉取镜像，可以添加清华镜像站提供的 `simplestreams` 远程源：

```bash
incus remote add mirror-images https://mirrors.tuna.tsinghua.edu.cn/lxc-images/ --protocol=simplestreams --public
```

添加完成后，可以查看这个远程源中的镜像：

```bash
incus image list mirror-images:
```

### 说明

- `mirror-images` 是你给这个远程源起的名字，可以自定义。
- `--protocol=simplestreams` 表示这个远程镜像源使用 `simplestreams` 协议。
- `--public` 表示这是一个公开镜像源，不需要认证。

## 4. 给当前用户添加 Incus 管理权限

默认情况下，普通用户可能没有权限直接访问 `Incus` 守护进程。
所以需要把当前用户加入 `incus-admin` 组：

```bash
sudo usermod -aG incus-admin $USER
```

执行完成后，**需要重新登录当前会话**，否则组权限通常不会立即生效。

你可以使用下面几种方式之一：

- 退出桌面/终端后重新登录
- 重启系统
- 或者临时执行：`newgrp incus-admin`

## 5. 初始化 Incus

如果这是第一次使用 `Incus`，需要做初始化：

```bash
incus admin init
```

这个命令会引导你完成基础配置，例如：

- 存储池
- 网络桥接
- 是否启用集群
- 远程访问设置

对于本地学习环境，一般按默认或偏简单的选项配置即可。

## 6. 查看默认 profile

初始化完成后，可以查看默认 `profile`：

```bash
incus profile show default
```

默认 `profile` 很重要，因为后续创建容器时，如果不特别指定，实例通常会继承它的配置。

你可以在这里看到类似内容：

- 默认网络设备
- 根磁盘设备
- 一些基础限制或设备映射

## 7. Docker 与 Incus 网络兼容

如果这台机器上同时安装并使用了 `Docker` 和 `Incus`，有时会遇到网络规则冲突。

比较常见的表现是：

- `Incus` 容器能启动，但网络异常
- 容器里 `apt update` 很慢或者直接失败
- 宿主机和容器之间联通异常
- `Ansible` 连接容器时出现奇怪的超时问题

这类问题通常和 `Docker` 写入的 `iptables` 规则有关，尤其是 `DOCKER-USER` 链。

这个仓库里已经提供了一个兼容脚本：

- `scripts/docker_incus_compat.sh`

你可以在仓库根目录执行：

```bash
./scripts/docker_incus_compat.sh
```

这个脚本会做两件事：

- 允许从 `incusbr0` 进入 `DOCKER-USER` 链的流量通过
- 允许从 `DOCKER-USER` 链发往 `incusbr0` 的流量通过

### 什么时候需要执行

- 这台机器同时运行 `Docker` 和 `Incus`
- 你怀疑容器网络被 `Docker` 的防火墙规则影响
- 容器创建正常，但联网、SSH 或包管理异常

### 说明

- 如果你没有安装 `Docker`，一般不需要执行这个脚本。
- 这个脚本会调用 `sudo iptables`，所以执行时需要管理员权限。
- 这不是所有网络问题的通用修复，但在 `Docker + Incus` 同机使用时很常见。

## 8. 建议做的验证

装完并初始化后，建议至少检查以下几项：

### 查看版本

```bash
incus version
```

### 查看当前用户组

```bash
id
```

或者：

```bash
groups
```

确认输出里包含 `incus-admin`。

### 查看实例列表

```bash
incus list
```

如果当前还没有任何实例，返回空列表是正常的。

### 查看可用镜像

```bash
incus image list mirror-images:
```

如果能正常列出镜像，说明镜像源配置成功。

## 9. 本节完成后的状态

当下面这些都满足时，就可以进入下一阶段了：

- `incus version` 可以正常返回客户端和服务端版本
- `incus list` 可以正常执行，不再提示权限错误
- `incus image list mirror-images:` 可以正常列出镜像
- `incus profile show default` 可以正常显示默认配置

## 常见提醒

### 1) 加了用户组但还是没权限

大多数情况下是因为你还没有重新登录当前会话。

### 2) `incus admin init` 只需要做一次

通常本机初始化完成后，不需要每次都重新执行。

### 3) `qemu-system` 主要是为 VM 做准备

如果你当前只打算学容器，它暂时可能不会马上用到；
但提前装好，后面扩展到虚拟机时会更顺手。

## 下一步

完成这一节后，就可以继续：

1. 生成本机 SSH 密钥
2. 准备练习用 `Incus` 容器
3. 配置容器内用户和公钥
4. 进入 `01-quickstart`
