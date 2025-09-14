# �򻯵�RV32I��תָ����Գ���
# ���⸴�ӵĵ�ַ���㣬ʹ����Լ򵥵���ת����

main:
    # ��ʼ������ֵ
    addi x1, x0, 10         # x1 = 10
    addi x2, x0, 20         # x2 = 20
    addi x3, x0, 10         # x3 = 10 (����x1)
    addi x4, x0, 0          # x4 = 0 (���Լ�����)

# 1. BEQ���� - ��ȷ�֧
test_beq:
    beq x1, x3, beq_ok      # x1 == x3��Ӧ����ת
    addi x4, x4, 100        # ���󣺲�Ӧ��ִ��
    jal x0, test_end        # ��ת������

beq_ok:
    addi x4, x4, 1          # x4 = 1��BEQ����ͨ��

# 2. BNE���� - ���ȷ�֧  
test_bne:
    bne x1, x2, bne_ok      # x1 != x2��Ӧ����ת
    addi x4, x4, 100        # ���󣺲�Ӧ��ִ��
    jal x0, test_end        # ��ת������

bne_ok:
    addi x4, x4, 1          # x4 = 2��BNE����ͨ��

# 3. BLT���� - С�ڷ�֧
test_blt:
    addi x5, x0, 5          # x5 = 5
    blt x5, x1, blt_ok      # x5 < x1 (5 < 10)��Ӧ����ת
    addi x4, x4, 100        # ���󣺲�Ӧ��ִ��
    jal x0, test_end        # ��ת������

blt_ok:
    addi x4, x4, 1          # x4 = 3��BLT����ͨ��

# 4. BGE���� - ���ڵ��ڷ�֧
test_bge:
    bge x1, x5, bge_ok      # x1 >= x5 (10 >= 5)��Ӧ����ת
    addi x4, x4, 100        # ���󣺲�Ӧ��ִ��
    jal x0, test_end        # ��ת������

bge_ok:
    addi x4, x4, 1          # x4 = 4��BGE����ͨ��

# 5. BLTU���� - �޷���С�ڷ�֧
test_bltu:
    addi x6, x0, -1         # x6 = -1 (0xFFFFFFFF)
    bltu x1, x6, bltu_ok    # x1 < x6 (�޷���: 10 < 0xFFFFFFFF)
    addi x4, x4, 100        # ���󣺲�Ӧ��ִ��
    jal x0, test_end        # ��ת������

bltu_ok:
    addi x4, x4, 1          # x4 = 5��BLTU����ͨ��

# 6. BGEU���� - �޷��Ŵ��ڵ��ڷ�֧
test_bgeu:
    bgeu x6, x1, bgeu_ok    # x6 >= x1 (�޷���: 0xFFFFFFFF >= 10)
    addi x4, x4, 100        # ���󣺲�Ӧ��ִ��
    jal x0, test_end        # ��ת������

bgeu_ok:
    addi x4, x4, 1          # x4 = 6��BGEU����ͨ��

# 7. JAL���� - ��ת������
test_jal:
    jal x7, jal_target      # ��ת��Ŀ�꣬���ص�ַ����x7
    addi x4, x4, 1          # x4 = 7��JAL���غ�ִ��
    jal x0, test_jalr       # ��ת��JALR����

jal_target:
    addi x8, x0, 99         # x8 = 99��Ŀ�����
    jalr x0, x7, 0          # ���ص����ô�

# 8. JALR���� - �Ĵ�����ת
test_jalr:
    addi x9, x0, 0          # x9 = 0����ʼ��
    # �򵥵�JALR���ԣ���ת���̶�ƫ��
    jal x10, jalr_setup     # ��ȡ���ص�ַ
    addi x4, x4, 1          # x4 = 8��JALR����ͨ��
    jal x0, test_loop       # ��ת��ѭ������

jalr_setup:
    addi x9, x0, 88         # x9 = 88�����ò���ֵ
    jalr x0, x10, 0         # ����

# 9. ѭ������
test_loop:
    addi x11, x0, 0         # x11 = 0��ѭ��������
    addi x12, x0, 3         # x12 = 3��ѭ������

loop_start:
    addi x11, x11, 1        # x11++
    blt x11, x12, loop_start # ���x11 < x12������ѭ��
    
    addi x4, x4, 1          # x4 = 9��ѭ������ͨ��

# 10. ��������
test_condition:
    addi x13, x0, 15        # x13 = 15
    addi x14, x0, 25        # x14 = 25
    
    blt x13, x14, condition_ok  # 15 < 25��Ӧ����ת
    addi x4, x4, 100        # ���󣺲�Ӧ��ִ��
    jal x0, test_end        # ��ת������

condition_ok:
    addi x4, x4, 1          # x4 = 10����������ͨ��

# ���Խ���
test_end:
    # ������в��Զ�ͨ����x4Ӧ�õ���10
    addi x15, x0, 10        # x15 = 10������ֵ
    beq x4, x15, all_pass   # ���x4 == 10�����в���ͨ��
    li x31, 0xDEAD    # ����ʧ�ܱ�־
    jal x0, end_program     # ��ת���������

all_pass:
    li x31, 0x1234    # ����ͨ����־

end_program:
    # ����ѭ�����������
    beq x0, x0, end_program # ʼ����ת���γ�����ѭ��