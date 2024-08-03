import random

filename = "ext_data.s"

with open(filename, 'w') as f:
    # 写入固定的开头部分
    f.write(".org 0x0\n")
    f.write(".global _start\n")

    # 生成随机数并写入.int指令
    num_entries = (0x807fffff - 0x80400000) // 4 + 1

    for _ in range(num_entries):
        random_value = random.randint(0, 0xFFFFFFFF)
        f.write(f".int 0x{random_value:08x}\n")

print(f"汇编代码已生成并保存在 {filename} 文件中。")
