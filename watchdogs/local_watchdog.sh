#!/bin/bash
# local_watchdog.sh — 无限循环检测

# 检查间隔（秒）
SLEEP_INTERVAL=3

# 1) 配置：远端主机与要映射的端口列表
SSH_HOST="gpu-ea"

PORTS=(
    54955 # SSH 隧道检测端口1
    34625 # SSH 隧道检测端口2
    57577 # SSH 隧道检测端口3
    37955 # SSH 隧道检测端口4
    55951 # SSH 隧道检测端口5
    6006  # TensorBoard 默认端口
)

# 2) 通用函数：生成 -L 参数数组
build_ssh_args() {
    local args=()
    for p in "${PORTS[@]}"; do
        args+=( "-L" "${p}:127.0.0.1:${p}" )
    done
    echo "${args[@]}"
}

# 3) 通用函数：检查端口、启动隧道
ensure_ssh_tunnel() {
    # 只要有任意一个端口没在 LISTEN，就重启整条隧道
    for p in "${PORTS[@]}"; do
        if ! lsof -iTCP:"$p" -sTCP:LISTEN &>/dev/null; then
            echo "  → 隧道缺失 (端口 $p 未监听)，重启 SSH 隧道..."
            # 关闭旧的（可选）
            pkill -f "ssh -fN.*${SSH_HOST}"
            # 启动新的
            ssh -fN $(build_ssh_args) "${SSH_HOST}"
            echo "  → SSH 隧道已启动 (PID=$(pgrep -f "ssh -fN.*${SSH_HOST}"))"
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
