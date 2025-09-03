# CSR写回rd测试程序
# 验证CSR指令写回rd的是旧值(原子操作)

.text
.globl _start

_start:
    # 初始化：设置mstatus初始值
    addi x1, x0, 0x100
    csrrw x0, mstatus, x1     # mstatus = 0x100, 不关心返回值
    
    # 测试1: 验证csrrw写回旧值
    addi x2, x0, 0x200
    csrrw x3, mstatus, x2     # x3应该 = 0x100(旧值), mstatus = 0x200
    
    # 测试2: 连续操作验证
    addi x4, x0, 0x300
    csrrw x5, mstatus, x4     # x5应该 = 0x200(旧值), mstatus = 0x300
    csrrw x6, mstatus, x0     # x6应该 = 0x300(旧值), mstatus = 0x000
    
    # 测试3: csrrs写回旧值
    addi x7, x0, 0x0F0
    csrrw x0, mstatus, x7     # 设置mstatus = 0x0F0
    addi x8, x0, 0x00F
    csrrs x9, mstatus, x8     # x9应该 = 0x0F0(旧值), mstatus = 0x0FF
    
    # 测试4: csrrc写回旧值  
    addi x10, x0, 0x0F0
    csrrc x11, mstatus, x10   # x11应该 = 0x0FF(旧值), mstatus = 0x00F
    
    # 测试5: 立即数指令写回旧值
    csrrwi x12, mie, 20       # x12应该 = 0(mie旧值), mie = 20
    csrrsi x13, mie, 3        # x13应该 = 20(旧值), mie = 23
    csrrci x14, mie, 7        # x14应该 = 23(旧值), mie = 16
    
    # 验证最终状态
    csrr x15, mstatus         # x15 = mstatus最终值 = 0x00F
    csrr x16, mie             # x16 = mie最终值 = 16
    
    nop

# 关键验证点:
# x3  = 0x100 (csrrw返回的mstatus旧值)
# x5  = 0x200 (csrrw返回的mstatus旧值) 
# x6  = 0x300 (csrrw返回的mstatus旧值)
# x9  = 0x0F0 (csrrs返回的mstatus旧值)
# x11 = 0x0FF (csrrc返回的mstatus旧值)
# x12 = 0x000 (csrrwi返回的mie旧值)
# x13 = 0x014 (csrrsi返回的mie旧值=20)
# x14 = 0x017 (csrrci返回的mie旧值=23)
# x15 = 0x00F (最终mstatus)
# x16 = 0x010 (最终mie=16)
