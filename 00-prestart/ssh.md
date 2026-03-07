# SSH 初始化

后面的教程默认通过 `SSH` 连接 `Incus` 容器，所以先准备一对本机密钥。

## 步骤

创建 `~/.ssh` 目录并设置权限：

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
```

生成一对 `ed25519` 密钥：

```bash
ssh-keygen -t ed25519 -C "$USER@$(hostname)"
```

查看公钥内容：

```bash
cat ~/.ssh/id_ed25519.pub
```

## 建议验证

确认密钥文件已经生成：

```bash
ls -l ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub
```

确认目录权限合理：

```bash
ls -ld ~/.ssh
```

## 说明

- `~/.ssh/id_ed25519` 是私钥，不要提交到 Git
- `~/.ssh/id_ed25519.pub` 是公钥，后面会放到容器用户的 `authorized_keys` 中
- 学习环境里可以暂时不设置 passphrase；正式环境一般建议设置
