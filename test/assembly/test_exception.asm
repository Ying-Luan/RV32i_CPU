.section .text
.globl _start

# 程序入口
_start:
    # 初始化栈指针
    li sp, 0x300

    # 初始化 mtvec 寄存器，指向异常处理入口
    la t0, trap_handler
    csrw mtvec, t0

    # 初始化 mstatus 寄存器
    li t0, 0x00000008      # MIE = 1 (bit 3), 其他位为 0
    csrw mstatus, t0       # 使能全局中断
    
    # 测试 ecall 指令
    li x10, 0x00000001     # 标记，表示即将执行 ecall
    ecall                  # 执行系统调用异常
    li x12, 0x87654321      # ecall 返回后会执行这里
    
    # 测试 ebreak 指令  
    li x10, 0x00000002     # 标记，表示即将执行 ebreak
    ebreak                 # 执行断点异常
    li x3, 0xA5A5A5A5      # ebreak 返回后会执行这里
    
    # 程序结束，进入死循环
    li x10, 0xFFFFFFF      # 标记程序正常结束
end_loop:
    j end_loop

# 异常处理程序入口
trap_handler:
    # 保存上下文（简化版，只保存必要寄存器）
    addi sp, sp, -16
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw ra, 12(sp)
    
    # 读取异常原因
    csrr t0, mcause
    
    # 判断异常类型
    li t1, 11              # ecall 异常码
    beq t0, t1, handle_ecall
    
    li t1, 3               # ebreak 异常码
    beq t0, t1, handle_ebreak
    
    j exception_return     # 其他异常直接返回

handle_ecall:
    # 处理 ecall 异常
    li x11, 0xEC00EC00     # 标记进入 ecall 处理
    j exception_return

handle_ebreak:
    # 处理 ebreak 异常
    li x11, 0xEB00EB00     # 标记进入 ebreak 处理
    j exception_return

exception_return:
    # 修改 mepc，指向下一条指令（避免死循环）
    csrr t0, mepc
    addi t0, t0, 4         # PC + 4，跳过异常指令
    csrw mepc, t0
    
    # 恢复上下文
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    
    # 返回（测试 mret 指令）
    mret

# mstatus=0x00000088, mie=00000000, mtvec=0x00000044, mepc=0x00000030, mcause=0x00000003, mtval=0x00000000, mip=0x00000000
# x0 =00000000, x1 =00000000, x2 =00000300, x3 =a5a5a5a5, x4 =00000000, x5 =00000008, x6 =00000000, x7 =00000000
# x8 =00000000, x9 =00000000, x10=0fffffff, x11=eb00eb00, x12=87654321, x13=00000000, x14=00000000, x15=00000000
# x16=00000000, x17=00000000, x18=00000000, x19=00000000, x20=00000000, x21=00000000, x22=00000000, x23=00000000
# x24=00000000, x25=00000000, x26=00000000, x27=00000000, x28=00000000, x29=00000000, x30=00000000, x31=00000000
