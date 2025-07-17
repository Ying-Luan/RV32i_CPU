# RAW 冲突测试程序 (包含Load指令)
# 包含 EX-EX, MEM-EX, WB-EX, 隔三条指令, 以及Load指令冲突测试

# 初始化
addi x1, x0, 10      # x1 = 10
addi x2, x0, 20      # x2 = 20  
addi x3, x0, 30      # x3 = 30
addi x4, x0, 40      # x4 = 40

# 设置内存地址
addi x30, x0, 100    # x30 = 100 (基地址)
addi x31, x0, 200    # x31 = 200 (另一个基地址)

# 向内存写入测试数据
sw x1, 0(x30)        # mem[100] = 10
sw x2, 4(x30)        # mem[104] = 20
sw x3, 8(x30)        # mem[108] = 30
sw x4, 12(x30)       # mem[112] = 40

# 1. EX-EX 冲突 (连续两条指令)
add x5, x1, x2       # x5 = x1 + x2 = 30 (EX 阶段写回)
add x6, x5, x3       # x6 = x5 + x3，这里 x5 还在 EX 阶段，产生 EX-EX 冲突

# 2. MEM-EX 冲突 (隔一条指令)
add x7, x1, x2       # x7 = x1 + x2 = 30 (将在 MEM 阶段)
nop                  # 空指令
add x8, x7, x3       # x8 = x7 + x3，这里 x7 在 MEM 阶段，产生 MEM-EX 冲突

# 3. WB-EX 冲突 (隔两条指令)
add x9, x1, x2       # x9 = x1 + x2 = 30 (将在 WB 阶段)
nop                  # 空指令
nop                  # 空指令  
add x10, x9, x3      # x10 = x9 + x3，这里 x9 在 WB 阶段，产生 WB-EX 冲突

# 4. 隔三条指令 (无冲突，数据已写回寄存器)
add x11, x1, x2      # x11 = x1 + x2 = 30 (数据将完全写回)
nop                  # 空指令
nop                  # 空指令
nop                  # 空指令
add x12, x11, x3     # x12 = x11 + x3，这里 x11 已经写回寄存器，无冲突

# 5. Load-Use 冲突测试
# 5.1 Load-Use EX-EX 冲突（最严重，需要2个周期暂停）
lw x13, 0(x30)       # x13 = mem[100] = 10 (Load指令)
add x14, x13, x2     # x14 = x13 + x2，这里 x13 在Load的MEM阶段，产生Load-Use冲突

# 5.2 Load-Use MEM-EX 冲突（需要1个周期暂停）
lw x15, 4(x30)       # x15 = mem[104] = 20 (Load指令)
nop                  # 空指令
add x16, x15, x3     # x16 = x15 + x3，这里 x15 在Load的WB阶段，产生Load-Use冲突

# 5.3 Load-Use WB-EX 冲突（可以通过旁路解决）
lw x17, 8(x30)       # x17 = mem[108] = 30 (Load指令)
nop                  # 空指令
nop                  # 空指令
add x18, x17, x4     # x18 = x17 + x4，这里 x17 已经写回，无冲突

# 6. 连续Load指令测试
lw x19, 0(x30)       # x19 = mem[100] = 10
lw x20, 4(x30)       # x20 = mem[104] = 20
add x21, x19, x20    # x21 = x19 + x20，测试连续Load的冲突

# 7. Load指令地址计算冲突测试
add x22, x30, x0     # x22 = x30 = 100
lw x23, 0(x22)       # x23 = mem[100] = 10，地址寄存器x22刚刚计算出来

# 8. Store指令测试
lw x24, 12(x30)      # x24 = mem[112] = 40
sw x24, 0(x31)       # mem[200] = 40，Store指令
lw x25, 0(x31)       # x25 = mem[200] = 40，验证Store结果

# 验证结果
add x26, x6, x8      # x26 = x6 + x8 = 60 + 60 = 120
add x27, x10, x12    # x27 = x10 + x12 = 60 + 60 = 120
add x28, x14, x16    # x28 = x14 + x16 = 30 + 50 = 80
add x29, x18, x21    # x29 = x18 + x21 = 70 + 30 = 100