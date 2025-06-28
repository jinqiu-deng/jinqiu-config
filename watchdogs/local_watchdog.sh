#!/bin/bash
# local_watchdog.sh — 无限循环检测

# 检查间隔（秒）
SLEEP_INTERVAL=3

while true; do
  # 1) 检查并启动 SSH 隧道（以 54477 端口为检测目标）
  if ! lsof -iTCP:54477 -sTCP:LISTEN >/dev/null 2>&1; then
    echo "  → SSH 隧道未检测到，启动到 gpu-ea..."
    ssh -fN \
      -L 54477:127.0.0.1:54477 \
      -L 55261:127.0.0.1:55261 \
      -L 46813:127.0.0.1:46813 \
      -L 59203:127.0.0.1:59203 \
      -L 59029:127.0.0.1:59029 \
      gpu-ea
    echo "  → SSH 隧道已启动 (PID=$(pgrep -f 'ssh -fN.*gpu-ea'))"
  fi

  # 2) 检查并启动 sshfs 挂载
  if ! mount | grep 'dengjinqiu/tmp' >/dev/null 2>&1; then
    echo "  → sshfs 未挂载，开始挂载 gpu-ea:/home/dengjinqiu/tmp 到 ~/tmp"
    mkdir -p ~/tmp
    nohup sshfs -o reconnect,ServerAliveInterval=15 \
      dengjinqiu@gpu-ea:/home/dengjinqiu/tmp \
      ~/tmp \
      >/dev/null 2>&1 &
    echo "  → sshfs 已挂载."
  fi

  # 等待下次检查
  sleep "${SLEEP_INTERVAL}"
done
