# 完全无冒险的RISC-V测试程序 - 包含I型和R型指令
# 使用x1-x31共31个寄存器，先用I型指令初始化，再用R型指令

# === 第一阶段：I型指令初始化基础数据 (x1-x15) ===
addi x1, x0, 10     # x1 = 10
addi x2, x0, 20     # x2 = 20  
addi x3, x0, 30     # x3 = 30
addi x4, x0, 5      # x4 = 5
addi x5, x0, 15     # x5 = 15
ori  x6, x0, 0xFF   # x6 = 255
ori  x7, x0, 0x0F   # x7 = 15
xori x8, x0, 0xAA   # x8 = 170
addi x9, x0, 100    # x9 = 100
addi x10, x0, 200   # x10 = 200
addi x11, x0, 1     # x11 = 1
addi x12, x0, 2     # x12 = 2
addi x13, x0, 4     # x13 = 4
addi x14, x0, 8     # x14 = 8
addi x15, x0, -10   # x15 = -10

# === 第二阶段：R型算术指令 (x16-x20) ===
add  x16, x1, x2    # x16 = x1 + x2 = 10 + 20 = 30
sub  x17, x3, x4    # x17 = x3 - x4 = 30 - 5 = 25
add  x18, x5, x9    # x18 = x5 + x9 = 15 + 100 = 115
sub  x19, x10, x1   # x19 = x10 - x1 = 200 - 10 = 190
add  x20, x11, x12  # x20 = x11 + x12 = 1 + 2 = 3

# === 第三阶段：R型逻辑指令 (x21-x25) ===
and  x21, x6, x7    # x21 = x6 & x7 = 255 & 15 = 15
or   x22, x1, x8    # x22 = x1 | x8 = 10 | 170 = 170
xor  x23, x6, x8    # x23 = x6 ^ x8 = 255 ^ 170 = 85
and  x24, x2, x6    # x24 = x2 & x6 = 20 & 255 = 20
or   x25, x3, x7    # x25 = x3 | x7 = 30 | 15 = 31

# === 第四阶段：R型移位指令 (x26-x28) ===
sll  x26, x6, x11   # x26 = x6 << x11 = 255 << 1 = 510
srl  x27, x6, x12   # x27 = x6 >> x12 = 255 >> 2 = 63
sra  x28, x15, x11  # x28 = x15 >>> x11 = -10 >>> 1 = -5

# === 第五阶段：R型比较指令和LUI (x29-x31) ===
slt  x29, x1, x2    # x29 = (x1 < x2) = (10 < 20) = 1
sltu x30, x15, x1   # x30 = (x15 < x1) unsigned = (-10 < 10) unsigned = 0
lui  x31, 0x12345   # x31 = 0x12345000