# CSR寄存器全面测试程序
# 测试 mstatus, mie, mtvec, mepc, mcause, mtval, mip 寄存器
# 使用 csrrw, csrrs, csrrc, csrrwi, csrrsi, csrrci 指令

.text
.globl _start

_start:
    # 初始化通用寄存器
    addi x1, x0, 0x100      # x1 = 0x100
    addi x2, x0, 0x200      # x2 = 0x200
    addi x3, x0, 0x300      # x3 = 0x300
    addi x4, x0, 0x400      # x4 = 0x400
    
    # ========== 测试 MSTATUS 寄存器 ==========
    # 测试1: 写入和读取 mstatus
    csrrw x5, mstatus, x1     # x5 = mstatus旧值, mstatus = 0x100
    csrr x6, mstatus          # x6 = 0x100, 确认写入成功
    
    # 测试2: mstatus 置位操作
    addi x7, x0, 0x0F0        # x7 = 0x0F0 (掩码)
    csrrs x8, mstatus, x7     # x8 = 0x100, mstatus = 0x100 | 0x0F0 = 0x1F0
    
    # 测试3: mstatus 清位操作
    csrrc x9, mstatus, x7     # x9 = 0x1F0, mstatus = 0x1F0 & ~0x0F0 = 0x100
    
    # ========== 测试 MIE 寄存器 ==========
    # 测试4: 写入和读取 mie
    csrrw x10, mie, x2        # x10 = mie旧值, mie = 0x200
    csrr x11, mie             # x11 = 0x200, 确认写入成功
    
    # 测试5: mie 立即数操作
    csrrwi x12, mie, 15       # x12 = 0x200, mie = 15
    csrrsi x13, mie, 16       # x13 = 15, mie = 15 | 16 = 31
    csrrci x14, mie, 1        # x14 = 31, mie = 31 & ~1 = 30
    
    # ========== 测试 MTVEC 寄存器 ==========
    # 测试6: 写入和读取 mtvec (中断向量表基地址)
    csrrw x15, mtvec, x3      # x15 = mtvec旧值, mtvec = 0x300
    csrr x16, mtvec           # x16 = 0x300, 确认写入成功
    
    # 测试7: mtvec 修改为4字节对齐地址
    li x17, 0x1000            # x17 = 0x1000 (4KB对齐地址)
    csrrw x18, mtvec, x17     # x18 = 0x300, mtvec = 0x1000
    
    # ========== 测试 MEPC 寄存器 ==========
    # 测试8: 写入和读取 mepc (异常程序计数器)
    csrrw x19, mepc, x4       # x19 = mepc旧值, mepc = 0x400
    csrr x20, mepc            # x20 = 0x400, 确认写入成功
    
    # 测试9: mepc 更新为新地址
    li x21, 0x2000            # x21 = 0x2000
    csrrw x22, mepc, x21      # x22 = 0x400, mepc = 0x2000
    
    # ========== 测试 MCAUSE 寄存器 ==========
    # 测试10: 写入和读取 mcause (异常原因)
    li x23, 0x8000000B        # x23 = 0x8000000B (机器模式外部中断)
    csrrw x24, mcause, x23    # x24 = mcause旧值, mcause = 0x8000000B
    csrr x25, mcause          # x25 = 0x8000000B, 确认写入成功
    
    # 测试11: mcause 设置为异常代码
    addi x26, x0, 2           # x26 = 2 (非法指令异常)
    csrrw x27, mcause, x26    # x27 = 0x8000000B, mcause = 2
    
    # ========== 测试 MTVAL 寄存器 ==========
    # 测试12: 写入和读取 mtval (陷阱值寄存器)
    li x28, 0x12345678        # x28 = 0x12345678
    csrrw x29, mtval, x28     # x29 = mtval旧值, mtval = 0x12345678
    csrr x30, mtval           # x30 = 0x12345678, 确认写入成功
    
    # ========== 测试 MIP 寄存器 ==========
    # 测试13: 读取 mip (中断挂起寄存器，通常只读)
    csrr x31, mip             # x31 = mip当前值
    
    # 测试14: 尝试写入 mip (某些位可能是只读的)
    li x1, 0x888              # 重用x1, x1 = 0x888
    csrrw x2, mip, x1         # x2 = mip旧值, 尝试写入0x888到mip
    csrr x3, mip              # x3 = mip当前值, 验证写入结果
    
    # ========== 综合验证读取所有CSR寄存器 ==========
    # 测试15: 最终状态读取
    csrr x4, mstatus          # 读取最终 mstatus 值
    csrr x5, mie              # 读取最终 mie 值
    csrr x6, mtvec            # 读取最终 mtvec 值
    csrr x7, mepc             # 读取最终 mepc 值
    csrr x8, mcause           # 读取最终 mcause 值
    csrr x9, mtval            # 读取最终 mtval 值
    csrr x10, mip             # 读取最终 mip 值
    
    # ========== 边界测试 ==========
    # 测试16: 零寄存器相关操作
    csrrw x0, mstatus, x0     # 将mstatus清零，读取的旧值被丢弃
    csrrs x11, mstatus, x0    # 只读取，不修改
    csrrc x12, mstatus, x0    # 只读取，不修改
    
    # 测试17: 立即数边界值
    csrrwi x13, mie, 0        # 写入0
    csrrwi x14, mie, 31       # 写入最大5位立即数
    
    # 程序结束
    nop
    nop
    nop

# 程序执行完毕后的最终状态:

# 最终通用寄存器值:
# x1=0x888, x2=0x00, x3=0x888或0x00(取决于MIP实现), x4=0x100, x5=0x1E
# x6=0x1000, x7=0x2000, x8=0x02, x9=0x12345678, x10=0x888或0x00(取决于MIP实现)
# x11=0x00, x12=0x00, x13=0x1E, x14=0x00
# x15=0x00, x16=0x300, x17=0x1000, x18=0x300, x19=0x00, x20=0x400
# x21=0x2000, x22=0x400, x23=0x8000000B, x24=0x00, x25=0x8000000B
# x26=0x02, x27=0x8000000B, x28=0x12345678, x29=0x00, x30=0x12345678, x31=0x00

# 最终CSR寄存器值:
# mstatus=0x00000000, mie=0x0000001F, mtvec=0x00001000, mepc=0x00002000
# mcause=0x00000002, mtval=0x12345678, mip=0x00000888或0x00000000(取决于实现)
