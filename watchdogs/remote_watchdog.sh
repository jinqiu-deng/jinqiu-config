#!/bin/bash
# remote_watchdog.sh — 常驻检测 + 每小时 01 分执行 spark session 恢复

# 检查间隔（秒）
SLEEP_INTERVAL=10

LAST_SPARK_CHECK_HOUR=""

while true; do
  # 检查并启动gpu_matrix_multi.py
  if ! pgrep -f "gpu_matrix_multi\.py" >/dev/null 2>&1; then
    echo "[远程 Watchdog] 启动gpu_matrix_multi.py任务..."
    nohup python "$HOME/gpu_matrix_multi.py" >/dev/null 2>&1 &
  fi

  # 每天 09:01 到 23:01，每小时第1分钟执行一次 spark session 检查
  CURRENT_HOUR="$(date +%H)"
  CURRENT_MINUTE="$(date +%M)"
  CURRENT_HOUR_INT=$((10#$CURRENT_HOUR))

  if [[ "$CURRENT_MINUTE" == "01" && "$LAST_SPARK_CHECK_HOUR" != "$CURRENT_HOUR" && "$CURRENT_HOUR_INT" -ge 9 && "$CURRENT_HOUR_INT" -le 23 ]]; then
    LAST_SPARK_CHECK_HOUR="$CURRENT_HOUR"
    if [ -x /media/cfs/dengjinqiu/jinqiu-config/watchdogs/spark_session_watchdog.sh ]; then
      nohup /media/cfs/dengjinqiu/jinqiu-config/watchdogs/spark_session_watchdog.sh >> /tmp/jinqiu_spark_session_watchdog_from_remote_watchdog.log 2>&1 &
    else
      echo "[远程 Watchdog] 未找到或不可执行: /media/cfs/dengjinqiu/jinqiu-config/watchdogs/spark_session_watchdog.sh"
    fi
  fi

  # 等待下次检查
  sleep "${SLEEP_INTERVAL}"

done
