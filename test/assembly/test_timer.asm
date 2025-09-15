.section .text
.globl _start

_start:
    li sp, 0x300

    # 初始化 mtvec
    la t0, trap_handler
    csrw mtvec, t0

    # 初始化 mstatus
    li t0, 0x00000008
    csrw mstatus, t0

    # 设置比较值
    li t0, 0x20000008
    li t1, 12           # SIMULATION: 200ns
    sw t1, 0(t0)

    # 启动定时器并使能中断
    li t0, 0x20000000
    li t1, 0x07
    sw t1, 0(t0)

    # 初始化计数器
    li a1, 0

main_loop:
    # 判断计数是否达到2
    li t0, 2
    beq a1, t0, stop_timer

    j main_loop

stop_timer:
    li t0, 0x20000000
    li t1, 0x00          # 停止定时器
    sw t1, 0(t0)
    li a1, 0
    li a0, 0xDEADBEEF    # 标记测试通过

end_loop:
    j end_loop

.section .text
.globl trap_handler

trap_handler:
    li t0, 0x20000000      # timer_ctrl 地址
    lw t2, 0(t0)           # 读出当前控制寄存器
    ori t2, t2, 0x5        # (1<<2)|(1<<0) = 0x4 | 0x1 = 0x5，清pending并启动
    sw t2, 0(t0)           # 写回控制寄存器

    addi a1, a1, 1         # 计数加一

    mret
