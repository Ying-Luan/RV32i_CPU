# CSR指令测试程序
# 测试csrrw, csrrs, csrrc指令功能

.text
.globl _start

_start:
    # 初始化寄存器
    addi x1, x0, 0x100      # x1 = 0x100
    addi x2, x0, 0x200      # x2 = 0x200
    addi x3, x0, 0x300      # x3 = 0x300
    addi x4, x0, 0x400      # x4 = 0x400
    
    # 测试1: CSRRW指令 - 写入mstatus并读取旧值
    # csrrw rd, csr, rs1  ->  rd = csr, csr = rs1
    csrrw x5, mstatus, x1     # x5 = mstatus旧值(0), mstatus = 0x100
    
    # 测试2: 再次读取mstatus确认写入成功
    csrrw x6, mstatus, x2     # x6 = mstatus旧值(0x100), mstatus = 0x200
    
    # 测试3: CSRRS指令 - 置位操作
    # csrrs rd, csr, rs1  ->  rd = csr, csr = csr | rs1
    addi x7, x0, 0x0F0      # x7 = 0x0F0 (掩码)
    csrrs x8, mstatus, x7     # x8 = mstatus旧值(0x200), mstatus = 0x200 | 0x0F0 = 0x2F0
    
    # 测试4: CSRRC指令 - 清位操作
    # csrrc rd, csr, rs1  ->  rd = csr, csr = csr & ~rs1
    addi x9, x0, 0x0F0      # x9 = 0x0F0 (掩码)
    csrrc x10, mstatus, x9    # x10 = mstatus旧值(0x2F0), mstatus = 0x2F0 & ~0x0F0 = 0x200
    
    # 测试5: 测试其他CSR寄存器 - MIE
    li x11, 0x888           # x11 = 0x888 (使用li伪指令)
    csrrw x12, mie, x11     # x12 = mie旧值(0), mie = 0x888
    
    # 测试6: 立即数形式的CSR指令 - CSRRWI
    # csrrwi rd, csr, uimm  ->  rd = csr, csr = uimm
    csrrwi x13, mie, 15   # x13 = mie旧值(0x888), mie = 15
    
    # 测试7: CSRRSI指令 - 立即数置位
    # csrrsi rd, csr, uimm  ->  rd = csr, csr = csr | uimm
    csrrsi x14, mie, 16   # x14 = mie旧值(15), mie = 15 | 16 = 31
    
    # 测试8: CSRRCI指令 - 立即数清位
    # csrrci rd, csr, uimm  ->  rd = csr, csr = csr & ~uimm
    csrrci x15, mie, 1    # x15 = mie旧值(31), mie = 31 & ~1 = 30
    
    # 测试9: 测试MTVEC寄存器
    li x16, 0x1000          # x16 = 0x1000 (使用li伪指令)
    csrrw x17, mtvec, x16   # x17 = mtvec旧值(0), mtvec = 0x1000
    
    # 测试10: 测试MEPC寄存器
    li x18, 0x2000          # x18 = 0x2000 (使用li伪指令)
    csrrw x19, mepc, x18    # x19 = mepc旧值(0), mepc = 0x2000
    
    # 测试11: 读取所有CSR寄存器的值进行验证
    csrr x20, mstatus         # x20 = mstatus = 0x200
    csrr x21, mie         # x21 = mie = 30
    csrr x22, mtvec         # x22 = mtvec = 0x1000
    csrr x23, mepc         # x23 = mepc = 0x2000
    
    # 测试12: 零寄存器测试
    csrrw x0, mstatus, x0     # 只读取mstatus，不写入(因为x0恒为0)
    csrrs x24, mstatus, x0    # x24 = mstatus，不修改mstatus
    
    # 程序结束
    nop
    nop
    nop

# 预期结果:
# x5  = 0x000 (mstatus初始值)
# x6  = 0x100 (mstatus第一次写入的值)
# x8  = 0x200 (mstatus第二次写入的值)
# x10 = 0x2F0 (mstatus置位后的值)
# x12 = 0x000 (mie初始值)
# x13 = 0x888 (mie写入的值)
# x14 = 0x00F (mie立即数写入的值)
# x15 = 0x01F (mie置位后的值)
# x17 = 0x000 (mtvec初始值)
# x19 = 0x000 (mepc初始值)
# x20 = 0x200 (最终mstatus值)
# x21 = 0x01E (最终mie值)
# x22 = 0x1000 (最终mtvec值)
# x23 = 0x2000 (最终mepc值)
# x24 = 0x200 (读取mstatus值)
