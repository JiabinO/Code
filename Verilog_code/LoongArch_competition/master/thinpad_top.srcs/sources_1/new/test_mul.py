# # 定义内存范围和大小
# MEMORY_START = 0x80400000
# MEMORY_SIZE = 0x400000  # 4MB
# MEMORY = {}

# # 初始化内存数据为其地址值
# for addr in range(MEMORY_START, MEMORY_START + MEMORY_SIZE * 4, 4):
#     MEMORY[addr] = addr

# # 打印初始化的内存数据的一部分
# print("初始化的内存数据的一部分:")
# for addr in range(MEMORY_START, MEMORY_START + 80, 4):
#     print(f"MEMORY[{hex(addr)}] = {hex(MEMORY[addr])}")

# # 定义矩阵大小
# N = 96

# # 初始化矩阵地址
# a_addr = MEMORY_START
# b_addr = MEMORY_START + 0x10000
# c_addr = MEMORY_START + 0x20000

# # 创建矩阵
# a = [[0 for _ in range(N)] for _ in range(N)]
# b = [[0 for _ in range(N)] for _ in range(N)]
# c = [[0 for _ in range(N)] for _ in range(N)]

# # 填充矩阵a和b的数据
# for i in range(N):
#     for j in range(N):
#         a[i][j] = MEMORY[a_addr + (i * N + j) * 4]
#         b[i][j] = MEMORY[b_addr + (i * N + j) * 4]

# # 矩阵乘法计算
# for k in range(N):
#     for i in range(N):
#         r = a[i][k]
#         for j in range(N):
#             # 模拟 mul.w 指令，结果取低32位
#             result = (r * b[k][j]) & 0xFFFFFFFF
#             # 模拟加法并存储结果
#             c[i][j] = (c[i][j] + result) & 0xFFFFFFFF

# # 将结果写回内存
# for i in range(N):
#     for j in range(N):
#         MEMORY[c_addr + (i * N + j) * 4] = c[i][j]

# # 打印结果矩阵的一部分及其内存位置
# print("结果矩阵C的一部分及其内存位置:")
# for i in range(5):
#     for j in range(5):
#         addr = c_addr + (i * N + j) * 4
#         print(f"C[{i}][{j}] = {c[i][j]} at MEMORY[{hex(addr)}]")
# 定义内存范围和大小
MEMORY_START = 0x80400000
MEMORY_SIZE = 0x400000  # 4MB
MEMORY = {}

# 初始化内存数据为其地址值
for addr in range(MEMORY_START, MEMORY_START + MEMORY_SIZE * 4, 4):
    MEMORY[addr] = addr

# 设置参数
n = 10

# 模拟计算过程
for i in range(n):
    for j in range(n):
        c_addr = 0x80420000 + i * 512 + j * 4
        # c[i][j] 本来值保持不变
        MEMORY[c_addr] = c_addr

# 输出结果
for i in range(n):
    for j in range(n):
        c_addr = 0x80420000 + i * 512 + j * 4
        print(f'c[{i}][{j}] @ {hex(c_addr)} = {hex(MEMORY[c_addr])}')
