# Ansible + Incus 01: Quickstart

这一节的目标很简单：

- 准备两台 `Incus` 练习节点
- 通过 `SSH` 让 `Ansible` 能连上它们
- 跑通最小的 `ping` 和安装软件包示例

## 文件

- `prepare.sh`：主流程脚本，负责准备这一节的实验环境
- `inventory.yml.example`：主机清单模板
- `inventory.yml`：实际使用的主机清单，本地文件，不提交到 Git
- `ping.yml`：最小连通性验证 playbook
- `install_common.yml`：安装常用软件包的示例 playbook

## Ansible 脚本结构

这一节里你会同时接触两类文件：

- `inventory`：描述 Ansible 要连接哪些主机
- `playbook`：描述 Ansible 连接后要做什么

一个最常见的 playbook 结构大致如下：

```yaml
- name: Example play
  hosts: incus_nodes
  gather_facts: false
  become: true

  vars:
    packages:
      - curl
      - git

  tasks:
    - name: Install packages
      ansible.builtin.apt:
        name: "{{ item }}"
        state: present
      loop: "{{ packages }}"
      notify: Report result

  handlers:
    - name: Report result
      ansible.builtin.debug:
        msg: "done"
```

### 常见字段

- `name`：这一段 play 或任务的说明文字，执行时会显示出来
- `hosts`：这次操作的目标主机或目标主机组
- `gather_facts`：是否先收集目标机器的系统信息
- `become`：是否通过 `sudo` 提权执行任务
- `vars`：给当前 play 定义变量
- `tasks`：真正执行的任务列表
- `handlers`：只有在被 `notify` 触发时才执行的任务

### 常见连接参数

这些参数通常会写在 `inventory.yml` 里：

- `ansible_host`：目标机器的实际 IP 或域名
- `ansible_user`：Ansible 连接目标机器时使用的用户
- `ansible_port`：SSH 端口，默认通常是 `22`
- `ansible_ssh_private_key_file`：登录目标机器时使用的私钥路径

### 对应到本章文件

- `ping.yml`：最适合先看 `hosts`、`gather_facts`、`tasks`
- `install_common.yml`：最适合先看 `become`、`vars`、`loop`、`handlers`
- `inventory.yml.example`：最适合先看 `ansible_host`、`ansible_user` 等连接参数

## 使用前提

下面的命令默认都在 `01-quickstart` 目录中执行。
如果你当前还在仓库根目录，先执行：

```bash
cd 01-quickstart
```

## 快速开始

```bash
./prepare.sh
uv run ansible-playbook ping.yml
uv run ansible-playbook install_common.yml
```

如果你已经激活了 `.venv`，也可以直接使用：

```bash
ansible-playbook ping.yml
ansible-playbook install_common.yml
```

## `prepare.sh` 会做什么

- 创建或启动 `node1` 和 `node2`
- 等待容器拿到 IPv4 地址
- 在容器里配置 APT 源并安装 `openssh-server`、`python3`、`sudo`
- 把你的本机公钥写入 `ubuntu` 用户的 `authorized_keys`
- 给 `ubuntu` 配置免密 `sudo`
- 启动 `ssh` 服务
- 根据实际 IP 生成 `inventory.yml`

## `inventory.yml.example` 说明

- `inventory.yml.example` 是模板文件
- 真正给 `Ansible` 使用的是 `inventory.yml`
- 如果你不想用 `prepare.sh` 自动生成，也可以手动复制：

```bash
cp inventory.yml.example inventory.yml
```

然后按你的实际环境修改：

- `ansible_host`
- `ansible_user`
- `ansible_ssh_private_key_file`

## 完成标准

当下面这些都正常时，这一节就算完成：

- `./prepare.sh` 成功执行
- `uv run ansible-playbook ping.yml` 成功返回 `ok`
- `uv run ansible-playbook install_common.yml` 成功执行
