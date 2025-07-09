import os
import json
import torch
import torch_npu      # 需预先安装 torch_npu
import time

CONFIG_PATH = os.path.join(os.path.dirname(__file__), "gpu_matrix_multi_config.json")
print(CONFIG_PATH)

def load_sleep_time(path=CONFIG_PATH, default=0.01):
    """
    每次读取 config.json 中的 sleep_time 字段；
    如果文件不存在或解析失败，则返回 default。
    """
    try:
        with open(path, "r", encoding="utf-8") as f:
            cfg = json.load(f)
        val = float(cfg.get("sleep_time", default))
    except Exception as e:
        # 解析错误、文件不存在等都 fallback 到 default
        print(f"⚠️ 读取 {path} 失败 ({e})，使用默认 sleep_time={default}s")
        val = default
    return val

def main():
    num = torch.npu.device_count()
    print(f"检测到 {num} 张 NPU 卡")
    N = 8192

    # 在每张卡上预先分配矩阵
    devices = [torch.device(f"npu:{i}") for i in range(num)]
    a_list = [torch.randn(N, N, device=dev) for dev in devices]
    b_list = [torch.randn(N, N, device=dev) for dev in devices]

    while True:
        sleep_time = load_sleep_time()
        print(f"本轮全局休眠时间 = {sleep_time:.4f}s")

        for i, dev in enumerate(devices):
            t0 = time.time()
            _ = torch.matmul(a_list[i], b_list[i])
            torch.npu.synchronize()
            dt = time.time() - t0
            print(f"[NPU:{i}] 矩阵乘法耗时 {dt:.4f}s")

        time.sleep(sleep_time)

if __name__ == "__main__":
    main()

