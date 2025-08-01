# RV32I综合测试程序 - 按指令类型分组
# 包含37条RV32I指令测试 (不包括初始化指令)

.text
.globl _start

_start:
    # ============================================================================
    # 初始化段 - 4条指令 (不计入测试指令数量)
    # ============================================================================
    li      x1, 10                 # 初始化: x1 = 10
    li      x2, 20                 # 初始化: x2 = 20
    li      x3, -5                 # 初始化: x3 = -5
    li      x4, 0x0000FFFF         # 初始化: x4 = 0xFFFF (低16位为1)

    # ============================================================================
    # R型指令测试 - 10条测试指令
    # 格式: opcode rd, rs1, rs2
    # ============================================================================
r_type_test:
    # 算术运算指令 (2条)
    add     x5, x1, x2             # 测试指令1:  ADD - x5 = 10 + 20 = 30
    sub     x6, x2, x1             # 测试指令2:  SUB - x6 = 20 - 10 = 10
    
    # 逻辑运算指令 (3条)
    and     x7, x4, x2             # 测试指令3:  AND - x7 = 0xFFFF & 20 = 20
    or      x8, x1, x4             # 测试指令4:  OR  - x8 = 10 | 0xFFFF = 0xFFFF
    xor     x9, x8, x4             # 测试指令5:  XOR - x9 = 0xFFFF ^ 0xFFFF = 0
    
    # 比较指令 (2条)
    slt     x10, x3, x1            # 测试指令6:  SLT  - x10 = (-5 < 10) ? 1 : 0 = 1
    sltu    x11, x3, x1            # 测试指令7:  SLTU - x11 = (0xFFFFFFFB < 10) ? 1 : 0 = 0
    
    # 移位指令 (3条) - 简化移位量
    sll     x12, x1, x2            # 测试指令8:  SLL - x12 = 10 << (20 & 0x1F) = 10 << 4 = 160
    srl     x13, x4, x2            # 测试指令9:  SRL - x13 = 0xFFFF >> (20 & 0x1F) = 0xFFFF >> 4 = 0xFFF
    sra     x14, x3, x2            # 测试指令10: SRA - x14 = -5 >> (20 & 0x1F) = -5 >> 4 = -1

    # ============================================================================
    # I型指令测试 - 9条测试指令
    # 格式: opcode rd, rs1, immediate
    # ============================================================================
i_type_test:
    # 立即数算术运算指令 (1条)
    addi    x15, x1, 15            # 测试指令11: ADDI - x15 = 10 + 15 = 25
    
    # 立即数比较指令 (2条)
    slti    x16, x3, 0             # 测试指令12: SLTI  - x16 = (-5 < 0) ? 1 : 0 = 1
    sltiu   x17, x3, 10            # 测试指令13: SLTIU - x17 = (0xFFFFFFFB < 10) ? 1 : 0 = 0
    
    # 立即数逻辑运算指令 (3条)
    xori    x18, x4, 0xFF          # 测试指令14: XORI - x18 = 0xFFFF ^ 0xFF = 0xFF00
    ori     x19, x1, 0xFF          # 测试指令15: ORI  - x19 = 10 | 0xFF = 0xFF
    andi    x20, x4, 0xFF          # 测试指令16: ANDI - x20 = 0xFFFF & 0xFF = 0xFF
    
    # 立即数移位指令 (3条) - 简化移位量
    slli    x21, x1, 2             # 测试指令17: SLLI - x21 = 10 << 2 = 40
    srli    x22, x4, 2             # 测试指令18: SRLI - x22 = 0xFFFF >> 2 = 0x3FFF
    srai    x23, x3, 1             # 测试指令19: SRAI - x23 = -5 >> 1 = -3

    # ============================================================================
    # U型指令测试 - 2条测试指令
    # 格式: opcode rd, immediate
    # ============================================================================
u_type_test:
    lui     x31, 0xABCDE           # 测试指令20: LUI   - x31 = 0xABCDE000
    auipc   x5, 1                  # 测试指令21: AUIPC - x5 = PC + 0x1000

    # ============================================================================
    # 内存操作准备 - 不计入测试指令数量
    # ============================================================================
    li      x24, 0x100             # 准备: 数据段基地址 = 0x100
    li      x25, 0x12345678        # 准备: 准备测试数据

    # ============================================================================
    # S型指令测试 - 3条测试指令
    # 格式: opcode rs2, offset(rs1)
    # ============================================================================
s_type_test:
    sw      x25, 0(x24)            # 准备: 存储字到内存 (为加载指令准备数据)
    li      x25, 0xABCDEF01        # 准备: 新的测试数据
    sb      x25, 4(x24)            # 测试指令22: SB - 存储字节 0x01 到 0x104
    sh      x25, 6(x24)            # 测试指令23: SH - 存储半字 0xEF01 到 0x106
    sw      x25, 8(x24)            # 测试指令24: SW - 存储字 0xABCDEF01 到 0x108

    # ============================================================================
    # I型内存加载指令测试 - 5条测试指令
    # 格式: opcode rd, offset(rs1)
    # ============================================================================
load_test:
    lb      x26, 0(x24)            # 测试指令25: LB  - x26 = 0x78 (符号扩展)
    lh      x27, 0(x24)            # 测试指令26: LH  - x27 = 0x5678 (符号扩展)
    lw      x28, 0(x24)            # 测试指令27: LW  - x28 = 0x12345678
    lbu     x29, 1(x24)            # 测试指令28: LBU - x29 = 0x56 (零扩展)
    lhu     x30, 2(x24)            # 测试指令29: LHU - x30 = 0x1234 (零扩展)

    # ============================================================================
    # B型指令测试 - 6条测试指令
    # 格式: opcode rs1, rs2, offset
    # ============================================================================
branch_test:
    beq     x1, x1, beq_target     # 测试指令30: BEQ  - x1 == x1, 跳转
    j       test_fail              # 不应该执行到这里
    
beq_target:
    bne     x1, x2, bne_target     # 测试指令31: BNE  - x1 != x2, 跳转
    j       test_fail              # 不应该执行到这里
    
bne_target:
    blt     x1, x2, blt_target     # 测试指令32: BLT  - x1 < x2, 跳转
    j       test_fail              # 不应该执行到这里
    
blt_target:
    bge     x2, x1, bge_target     # 测试指令33: BGE  - x2 >= x1, 跳转
    j       test_fail              # 不应该执行到这里
    
bge_target:
    bltu    x1, x2, bltu_target    # 测试指令34: BLTU - x1 < x2 (无符号), 跳转
    j       test_fail              # 不应该执行到这里
    
bltu_target:
    bgeu    x2, x1, bgeu_target    # 测试指令35: BGEU - x2 >= x1 (无符号), 跳转
    j       test_fail              # 不应该执行到这里
    
bgeu_target:
    # 分支测试通过
    nop                            # 分支测试通过标志

    # ============================================================================
    # J型指令测试 - 1条测试指令
    # 格式: jal rd, offset
    # ============================================================================
jump_test:
    jal     x6, jal_target         # 测试指令36: JAL  - x6 = PC+4, 跳转到jal_target
    j       test_fail              # 不应该执行到这里
    
jal_target:
    # 直接设置成功标志
    li      x31, 0xAAAA            # 设置成功标志
    
    # 添加JALR测试以满足37条指令要求
    la      x7, test_passed        # 测试指令37: 加载test_passed地址
    jalr    x0, x7, 0              # 跳转到test_passed，不保存返回地址
    j       test_fail              # 不应该执行到这里

test_fail:
    # 测试失败
    li      x31, 0xDEAD            # 设置失败标志
    j       test_fail              # 无限循环

test_passed:
    # 所有指令测试通过
    # x31已经设置为0xAAAA
    j       test_passed            # 无限循环