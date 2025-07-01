#!/bin/bash
# remote_watchdog.sh — 无限循环检测

# 检查间隔（秒）
SLEEP_INTERVAL=3

while true; do
  # 检查并启动gpu_matrix_multi.py
  if ! pgrep -f "gpu_matrix_multi\.py" >/dev/null 2>&1; then
    echo "[远程 Watchdog] 启动gpu_matrix_multi.py任务..."
    nohup python "$HOME/gpu_matrix_multi.py" >/dev/null 2>&1 &
  fi

  # 等待下次检查
  sleep "${SLEEP_INTERVAL}"
done
