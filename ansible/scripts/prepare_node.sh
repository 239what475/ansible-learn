# 这个文件放仓库级可复用的单节点准备逻辑。
# 任何章节脚本都可以通过 source 引入它，再调用 prepare_node。
#
# 它依赖调用方预先定义好这些变量：
# - IMAGE
# - SSH_USER
# - SSH_PRIVATE_KEY
# - PUBKEY
# - NODE_IP

prepare_node() {
  local node="$1"
  local node_ip=''
  local ssh_ready=''

  echo "==> 开始处理 $node"

  # 1. 创建容器；如果已经存在，就确保它处于运行状态。
  if incus info "$node" >/dev/null 2>&1; then
    echo "==> $node 已存在"
    incus start "$node" >/dev/null 2>&1 || true
  else
    echo "==> 创建 $node"
    incus launch "$IMAGE" "$node"
  fi

  # 2. 等待容器拿到 IPv4 地址。
  #    这里用 `incus list <name> -f csv -c 4` 只取第 4 列，也就是 IPv4 信息。
  #    输出类似：10.122.223.4 (eth0)，所以再用 `sed 's/ .*//'` 只保留 IP 本身。
  for _ in $(seq 1 60); do
    node_ip="$(incus list "$node" -f csv -c 4 | head -n1 | sed 's/ .*//')"
    if [[ -n "$node_ip" ]]; then
      break
    fi
    sleep 1
  done
  [[ -n "$node_ip" ]] || { echo "ERROR: $node 没有获取到 IPv4 地址" >&2; exit 1; }
  echo "==> $node IP: $node_ip"

  # 3. 在容器里安装 SSH、Python 和 sudo，并写入本机公钥。
  #
  #    `incus exec "$node" -- ...` 的意思是：在指定容器里执行后面的命令。
  #    `env SSH_USER=... PUBKEY=...` 是先把变量传进容器内的 shell。
  #    `bash -lc '...'` 表示在容器里启动一个 bash，再执行这段多行命令。
  #
  #    这一步里面做了几件事：
  #    - 安装 openssh-server、python3、sudo
  #    - 确保 ubuntu 用户可以使用 sudo
  #    - 创建 ~/.ssh 目录和 authorized_keys
  #    - 把本机公钥追加进去
  #    - 启动 ssh 服务，让外部可以连进来
  incus exec "$node" -- env SSH_USER="$SSH_USER" PUBKEY="$PUBKEY" bash -lc '
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive

    # 先把容器内的 APT 软件源改成阿里云镜像，减少后续装包时的网络问题。
    cat > /etc/apt/sources.list <<'"'"'EOF_APT'"'"'
# Aliyun Ubuntu mirror for Noble 24.04

deb https://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse

# deb https://mirrors.aliyun.com/ubuntu/ noble-proposed main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ noble-proposed main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse
EOF_APT

    # 更新包索引，并安装后续需要的基础组件。
    apt-get update
    apt-get install -y openssh-server python3 sudo

    # 把 ubuntu 用户加入 sudo 组，后面 Ansible 可以通过 become 提权。
    usermod -aG sudo "$SSH_USER"

    # 创建 ~/.ssh 目录，并把权限设成 SSH 要求的安全值。
    install -d -m 700 -o "$SSH_USER" -g "$SSH_USER" "/home/$SSH_USER/.ssh"

    # 如果 authorized_keys 不存在就创建，再把本机公钥写进去。
    touch "/home/$SSH_USER/.ssh/authorized_keys"
    grep -qxF "$PUBKEY" "/home/$SSH_USER/.ssh/authorized_keys" || printf "%s\n" "$PUBKEY" >> "/home/$SSH_USER/.ssh/authorized_keys"

    # authorized_keys 必须归属于目标用户，且权限不能过宽。
    chown "$SSH_USER:$SSH_USER" "/home/$SSH_USER/.ssh/authorized_keys"
    chmod 600 "/home/$SSH_USER/.ssh/authorized_keys"

    # 这里给 ubuntu 配置免密 sudo，后面跑 Ansible 更顺手。
    printf "%s ALL=(ALL) NOPASSWD:ALL\n" "$SSH_USER" > "/etc/sudoers.d/90-$SSH_USER-nopasswd"
    chmod 440 "/etc/sudoers.d/90-$SSH_USER-nopasswd"

    # sshd 有时要求 /run/sshd 目录存在，所以先建好再启动服务。
    mkdir -p /run/sshd

    # 这里直接用 systemctl 启动并设置 ssh 服务开机自启。
    systemctl enable --now ssh
  '

  # 4. 等待 SSH 真正可连通。
  #    这里不是只看 sshd 进程是否存在，而是直接从宿主机发起一次真实 SSH 连接。
  #    `true` 命令什么都不做，只要能连上并成功执行，就说明 SSH 环境已经就绪。
  for _ in $(seq 1 30); do
    if ssh -o BatchMode=yes -o ConnectTimeout=3 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$SSH_PRIVATE_KEY" "$SSH_USER@$node_ip" true >/dev/null 2>&1; then
      ssh_ready='yes'
      break
    fi
    sleep 2
  done
  [[ "$ssh_ready" == 'yes' ]] || { echo "ERROR: SSH 仍无法连接到 $node ($node_ip)" >&2; exit 1; }

  NODE_IP="$node_ip"
}
