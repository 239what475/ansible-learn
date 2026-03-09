# 用 uv 安装 Ansible

这一节只做三件事：创建 `.venv`、安装 `Ansible`、确认命令能运行。

## 步骤

如果当前目录还没有 `.venv`，先创建：

```bash
uv venv
```

把 `Ansible` 安装到当前虚拟环境：

```bash
uv pip install ansible
```

验证安装结果：

```bash
uv run python --version
uv run ansible --version
uv run ansible-playbook --version
```

## 推荐用法

这个仓库更推荐直接使用：

```bash
uv run ansible --version
uv run ansible-playbook ping.yml
```

如果你更习惯手动激活环境，也可以：

```bash
source .venv/bin/activate
ansible --version
ansible-playbook ping.yml
```

## 说明

- 当前仓库更适合用 `uv pip install ansible`，不急着用 `uv add ansible`
- `.venv/` 是本地产物，不需要提交到 Git
- 建议在 `ansible/` 根目录执行这些命令，这样 `.venv` 会落在 `ansible/.venv`
