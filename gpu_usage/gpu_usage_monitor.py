import subprocess
import time
import os

def monitor_npu(interval: float = 1.0):
    """
    每隔 interval 秒，清屏并打印一次所有 NPU 的利用率和内存状态。
    """
    while True:
        subprocess.call(['npu-smi', 'info'])
        time.sleep(interval)

if __name__ == '__main__':
    monitor_npu(1.0)  # 每秒刷新一次
