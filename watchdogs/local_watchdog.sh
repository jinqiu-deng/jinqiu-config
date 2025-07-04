#!/bin/bash
# local_watchdog.sh — 无限循环检测

# 检查间隔（秒）
SLEEP_INTERVAL=3

while true; do
  # 1) 检查并启动 SSH 隧道（以 54477 端口为检测目标）
  if ! lsof -iTCP:46761 -sTCP:LISTEN >/dev/null 2>&1; then
    echo "  → SSH 隧道未检测到，启动到 gpu-ea..."
    ssh -fN \
      -L 46761:127.0.0.1:46761 \
      -L 52449:127.0.0.1:52449 \
      -L 60345:127.0.0.1:60345 \
      -L 38367:127.0.0.1:38367 \
      -L 39939:127.0.0.1:39939 \
      gpu-ea
    echo "  → SSH 隧道已启动 (PID=$(pgrep -f 'ssh -fN.*gpu-ea'))"
  fi

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
