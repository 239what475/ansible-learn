# 用 uv 安装 Ansible

这一节记录如何在本地通过 `uv` 安装并使用 `Ansible`。

这个仓库当前的推荐方式是：

- 使用 `uv` 管理 Python 环境
- 使用本地 `.venv` 作为虚拟环境
- 在这个虚拟环境里安装 `Ansible`

## 目标

完成这一节后，你应该具备下面这些条件：

- 当前目录下已经有一个可用的 `.venv`
- `Ansible` 已安装到这个虚拟环境里
- 可以通过 `uv run` 或激活 `.venv` 的方式执行 `ansible`

## 1. 创建虚拟环境

如果当前目录还没有 `.venv`，可以先创建：

```bash
uv venv
```

默认会在当前目录生成：

- `.venv/`

## 2. 在虚拟环境里安装 Ansible

当前这个仓库更适合直接把 `Ansible` 装进 `.venv`：

```bash
uv pip install ansible
```

这条命令的意思是：

- 仍然使用 `uv`
- 但按 `pip` 风格把包安装到当前虚拟环境中

这种方式的好处是简单直接，适合教程和本地实验环境。

## 3. 验证安装

安装完成后，可以先检查版本：

```bash
uv run ansible --version
```

也可以检查 playbook 命令：

```bash
uv run ansible-playbook --version
```

如果输出了版本信息，说明 `Ansible` 已经可以使用。

## 4. 两种常见使用方式

### 方式一：直接用 `uv run`

这是这个仓库最推荐的方式：

```bash
uv run ansible --version
uv run ansible-playbook ping.yml
```

优点是：

- 不需要手工激活虚拟环境
- 命令更稳定
- 更适合写进教程文档

### 方式二：先激活 `.venv`

你也可以先激活虚拟环境，再直接执行命令：

```bash
source .venv/bin/activate
ansible --version
ansible-playbook ping.yml
```

这种方式也完全可以，只是比 `uv run` 多了一步激活环境。

## 5. 为什么这里用 `uv pip install`

你可能还会看到另一种写法：

```bash
uv add ansible
```

但这条命令更适合已经存在 `pyproject.toml` 的项目，因为它会把依赖写进项目配置文件。

而当前这个仓库目前更偏教程仓库，重点是先把实验环境跑起来，因此这里先推荐：

```bash
uv pip install ansible
```

也就是说：

- 想先简单装好工具：用 `uv pip install ansible`
- 想把依赖正式纳入项目管理：再考虑 `uv add ansible`

## 6. 建议做的验证

### 查看 Python 版本

```bash
uv run python --version
```

### 查看 Ansible 版本

```bash
uv run ansible --version
```

### 查看 Playbook 命令版本

```bash
uv run ansible-playbook --version
```

## 常见提醒

### 1) `.venv/` 不需要提交到 Git

虚拟环境是本地产物，通常只保留在自己机器上即可。

### 2) `uv run` 和激活 `.venv` 是两种不同用法

- `uv run ...`：不手动激活环境，直接执行命令
- `source .venv/bin/activate`：先进入虚拟环境，再执行命令

两种都能用，只是这个仓库更推荐 `uv run`。

### 3) 先确认你是在仓库根目录执行

这样 `uv venv` 创建出来的 `.venv` 才会落在仓库根目录，而不是别的地方。

## 下一步

完成这一节后，就可以继续：

1. 阅读 `00-prestart/ssh.md`
2. 阅读 `00-prestart/incus.md`
3. 进入 `01-quickstart` 开始实际练习
