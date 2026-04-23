#!/usr/bin/env bash
set -euo pipefail

PYTHON_BIN="/opt/conda/bin/python"
SCRIPT="/media/cfs/dengjinqiu/jinqiu-config/watchdogs/spark_session_watchdog.py"

exec "$PYTHON_BIN" "$SCRIPT" "$@"
