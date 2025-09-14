# 简化的RV32I跳转指令测试程序
# 避免复杂的地址计算，使用相对简单的跳转测试

main:
    # 初始化测试值
    addi x1, x0, 10         # x1 = 10
    addi x2, x0, 20         # x2 = 20
    addi x3, x0, 10         # x3 = 10 (等于x1)
    addi x4, x0, 0          # x4 = 0 (测试计数器)

# 1. BEQ测试 - 相等分支
test_beq:
    beq x1, x3, beq_ok      # x1 == x3，应该跳转
    addi x4, x4, 100        # 错误：不应该执行
    jal x0, test_end        # 跳转到结束

beq_ok:
    addi x4, x4, 1          # x4 = 1，BEQ测试通过

# 2. BNE测试 - 不等分支  
test_bne:
    bne x1, x2, bne_ok      # x1 != x2，应该跳转
    addi x4, x4, 100        # 错误：不应该执行
    jal x0, test_end        # 跳转到结束

bne_ok:
    addi x4, x4, 1          # x4 = 2，BNE测试通过

# 3. BLT测试 - 小于分支
test_blt:
    addi x5, x0, 5          # x5 = 5
    blt x5, x1, blt_ok      # x5 < x1 (5 < 10)，应该跳转
    addi x4, x4, 100        # 错误：不应该执行
    jal x0, test_end        # 跳转到结束

blt_ok:
    addi x4, x4, 1          # x4 = 3，BLT测试通过

# 4. BGE测试 - 大于等于分支
test_bge:
    bge x1, x5, bge_ok      # x1 >= x5 (10 >= 5)，应该跳转
    addi x4, x4, 100        # 错误：不应该执行
    jal x0, test_end        # 跳转到结束

bge_ok:
    addi x4, x4, 1          # x4 = 4，BGE测试通过

# 5. BLTU测试 - 无符号小于分支
test_bltu:
    addi x6, x0, -1         # x6 = -1 (0xFFFFFFFF)
    bltu x1, x6, bltu_ok    # x1 < x6 (无符号: 10 < 0xFFFFFFFF)
    addi x4, x4, 100        # 错误：不应该执行
    jal x0, test_end        # 跳转到结束

bltu_ok:
    addi x4, x4, 1          # x4 = 5，BLTU测试通过

# 6. BGEU测试 - 无符号大于等于分支
test_bgeu:
    bgeu x6, x1, bgeu_ok    # x6 >= x1 (无符号: 0xFFFFFFFF >= 10)
    addi x4, x4, 100        # 错误：不应该执行
    jal x0, test_end        # 跳转到结束

bgeu_ok:
    addi x4, x4, 1          # x4 = 6，BGEU测试通过

# 7. JAL测试 - 跳转并链接
test_jal:
    jal x7, jal_target      # 跳转到目标，返回地址存在x7
    addi x4, x4, 1          # x4 = 7，JAL返回后执行
    jal x0, test_jalr       # 跳转到JALR测试

jal_target:
    addi x8, x0, 99         # x8 = 99，目标代码
    jalr x0, x7, 0          # 返回到调用处

# 8. JALR测试 - 寄存器跳转
test_jalr:
    addi x9, x0, 0          # x9 = 0，初始化
    # 简单的JALR测试：跳转到固定偏移
    jal x10, jalr_setup     # 获取返回地址
    addi x4, x4, 1          # x4 = 8，JALR测试通过
    jal x0, test_loop       # 跳转到循环测试

jalr_setup:
    addi x9, x0, 88         # x9 = 88，设置测试值
    jalr x0, x10, 0         # 返回

# 9. 循环测试
test_loop:
    addi x11, x0, 0         # x11 = 0，循环计数器
    addi x12, x0, 3         # x12 = 3，循环次数

loop_start:
    addi x11, x11, 1        # x11++
    blt x11, x12, loop_start # 如果x11 < x12，继续循环
    
    addi x4, x4, 1          # x4 = 9，循环测试通过

# 10. 条件测试
test_condition:
    addi x13, x0, 15        # x13 = 15
    addi x14, x0, 25        # x14 = 25
    
    blt x13, x14, condition_ok  # 15 < 25，应该跳转
    addi x4, x4, 100        # 错误：不应该执行
    jal x0, test_end        # 跳转到结束

condition_ok:
    addi x4, x4, 1          # x4 = 10，条件测试通过

# 测试结束
test_end:
    # 如果所有测试都通过，x4应该等于10
    addi x15, x0, 10        # x15 = 10，期望值
    beq x4, x15, all_pass   # 如果x4 == 10，所有测试通过
    li x31, 0xDEAD    # 测试失败标志
    jal x0, end_program     # 跳转到程序结束

all_pass:
    li x31, 0x1234    # 测试通过标志

end_program:
    # 无限循环，程序结束
    beq x0, x0, end_program # 始终跳转，形成无限循环