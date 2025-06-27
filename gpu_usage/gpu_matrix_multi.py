import torch
import torch_npu      # 需预先安装 torch_npu
import time

def main():
    num = torch.npu.device_count()
    print(f"检测到 {num} 张 NPU 卡")
    N = 8192
    sleep_time = 0.01  # 每轮结束后的休眠时间（秒），可按需调整

    # 预先为每张卡创建两个矩阵
    devices = [torch.device(f"npu:{i}") for i in range(num)]
    a_list = [torch.randn(N, N, device=dev) for dev in devices]
    b_list = [torch.randn(N, N, device=dev) for dev in devices]

    while True:
        for i, dev in enumerate(devices):
            t0 = time.time()
            _ = torch.matmul(a_list[i], b_list[i])
            torch.npu.synchronize()   # 等待计算完成
            dt = time.time() - t0
            print(f"[NPU:{i}] 矩阵乘法耗时 {dt:.4f}s")
        # 全局休眠
        time.sleep(sleep_time)

if __name__ == '__main__':
    main()
