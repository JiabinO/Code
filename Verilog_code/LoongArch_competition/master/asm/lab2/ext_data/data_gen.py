# 生成的汇编文件名
filename = "ext_data.s"

with open(filename, 'w') as f:
    # 写入固定的开头部分
    f.write(".org 0x0\n")
    f.write(".global _start\n")

    # 生成从0x80400000到0x807fffff，每次加4的.int指令
    start = 0x80400000
    end = 0x807fffff
    step = 4

    for i in range(start, end + 1, step):
        f.write(f".int 0x{i:08x}\n")

print(f"汇编代码已生成并保存在 {filename} 文件中。")
