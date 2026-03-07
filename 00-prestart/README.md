# 00: Prestart

这一节只负责指路，帮助你完成正式实操前的本机环境准备。
具体操作写在下面三个文档里。

## 文件

- `ansible.md`：用 `uv` 和本地 `.venv` 安装 `Ansible`
- `ssh.md`：初始化本机 `SSH` 密钥
- `incus.md`：安装并初始化 `Incus`，以及处理 `Docker + Incus` 的网络兼容问题

## 推荐顺序

```text
ansible.md -> ssh.md -> incus.md -> ../01-quickstart/README.md
```

## 完成标准

当下面这些都正常时，就可以进入下一章：

- `uv run ansible --version` 可以正常执行
- `cat ~/.ssh/id_ed25519.pub` 可以正常输出公钥
- `incus version` 可以正常返回客户端和服务端版本
- `incus list` 可以正常执行
