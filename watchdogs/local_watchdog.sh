#!/bin/bash
# local_watchdog.sh — 无限循环检测

# 检查间隔（秒）
SLEEP_INTERVAL=3

# 1) 配置：远端主机与要映射的端口列表
SSH_HOST="gpu-ea"
SSH_OPTS=(
    -fN
    -o BatchMode=yes
    -o ExitOnForwardFailure=yes
    -o ServerAliveInterval=15
)

PORTS=(
    47981
    51033
    35957
    55371
    52039
    6006  # TensorBoard 默认端口
    5000  # prvi的 Flask 端口
)

# 2) 通用函数：生成 -L 参数数组
build_ssh_args() {
    local args=()
    for p in "${PORTS[@]}"; do
        args+=( "-L" "${p}:127.0.0.1:${p}" )
    done
    echo "${args[@]}"
}

is_port_open() {
    local port="$1"
    nc -G 1 -z 127.0.0.1 "${port}" >/dev/null 2>&1
}

# 3) 通用函数：检查端口、启动隧道
ensure_ssh_tunnel() {
    # 只要有任意一个端口没在 LISTEN，就重启整条隧道
    for p in "${PORTS[@]}"; do
        if ! is_port_open "$p"; then
            echo "  → 隧道缺失 (端口 $p 不可连接)，重启 SSH 隧道..."
            # 关闭旧的（可选）
            pkill -f "ssh -fN.*${SSH_HOST}"
            # 启动新的
            if ssh "${SSH_OPTS[@]}" $(build_ssh_args) "${SSH_HOST}"; then
                sleep 1
                if is_port_open "$p"; then
                    echo "  → SSH 隧道已启动 (PID=$(pgrep -f "ssh -fN.*${SSH_HOST}"))"
                else
                    echo "  → SSH 隧道命令已返回，但端口 $p 仍不可连接。" >&2
                fi
            else
                echo "  → SSH 隧道启动失败，请检查免密登录/网络/端口占用。" >&2
            fi
            return
        fi
    done
    # 如果全都监听中，就什么都不做
}

while true; do
    # 1) 检查并启动 SSH 隧道
    ensure_ssh_tunnel

    # 2) 检查并启动 sshfs 挂载：挂载两个目录
    # 2a) /home/dengjinqiu -> ~/remote_dengjinqiu
    if ! mount | grep "remote_dengjinqiu" >/dev/null 2>&1; then
        echo "  → sshfs 未挂载 /home/dengjinqiu，开始挂载到 ~/remote_dengjinqiu..."
        mkdir -p "${HOME}/remote_dengjinqiu"
        nohup sshfs -o reconnect,ServerAliveInterval=15 \
            dengjinqiu@gpu-ea:/media/cfs/dengjinqiu \
            "${HOME}/remote_dengjinqiu" \
            >/dev/null 2>&1 &
        echo "  → 已挂载 /home/dengjinqiu."
    fi

    # 2b) /media/cfs/ytech-gpu/pricing -> ~/remote_pricing
    if ! mount | grep "remote_pricing" >/dev/null 2>&1; then
        echo "  → sshfs 未挂载 /media/cfs/ytech-gpu/pricing，开始挂载到 ~/remote_pricing..."
        mkdir -p "${HOME}/remote_pricing"
        nohup sshfs -o reconnect,ServerAliveInterval=15 \
            dengjinqiu@gpu-ea:/media/cfs/ytech-gpu/pricing \
            "${HOME}/remote_pricing" \
            >/dev/null 2>&1 &
        echo "  → 已挂载 /media/cfs/ytech-gpu/pricing."
    fi

    # 等待下次检查
    sleep "${SLEEP_INTERVAL}"
done
