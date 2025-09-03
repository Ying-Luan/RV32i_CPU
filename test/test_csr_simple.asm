# 简化CSR指令测试程序
# 专门测试基本的csrrw, csrrs, csrrc指令

.text
.globl _start

_start:
    # 测试1: 基本CSRRW测试
    addi x1, x0, 0x123      # x1 = 0x123
    csrrw x2, mstatus, x1   # x2 = mstatus旧值, mstatus = 0x123
    csrrw x3, mstatus, x0   # x3 = mstatus当前值(0x123), mstatus = 0
    
    # 测试2: CSRRS置位测试
    addi x4, x0, 0x0F0      # x4 = 0x0F0
    csrrw x5, mstatus, x4   # 先设置mstatus = 0x0F0
    addi x6, x0, 0x00F      # x6 = 0x00F
    csrrs x7, mstatus, x6   # x7 = 0x0F0, mstatus = 0x0F0 | 0x00F = 0x0FF
    
    # 测试3: CSRRC清位测试
    addi x8, x0, 0x0F0      # x8 = 0x0F0
    csrrc x9, mstatus, x8   # x9 = 0x0FF, mstatus = 0x0FF & ~0x0F0 = 0x00F
    
    # 测试4: 立即数指令测试
    csrrwi x10, mie, 10     # x10 = mie旧值, mie = 10
    csrrsi x11, mie, 5      # x11 = 10, mie = 10 | 5 = 15
    csrrci x12, mie, 3      # x12 = 15, mie = 15 & ~3 = 12
    
    # 测试5: 读取验证
    csrr x13, mstatus       # x13 = mstatus = 0x00F
    csrr x14, mie           # x14 = mie = 12
    
    nop

# 预期结果验证:
# x2  = 0x000 (mstatus初始值0)
# x3  = 0x123 (mstatus被设置为0x123)
# x7  = 0x0F0 (置位前的mstatus值)
# x9  = 0x0FF (清位前的mstatus值)
# x10 = 0x000 (mie初始值0)
# x11 = 0x00A (mie=10)
# x12 = 0x00F (mie=15)
# x13 = 0x00F (最终mstatus值)
# x14 = 0x00C (最终mie值=12)
