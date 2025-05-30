.data
    array:      .word 121,-124,138,-199,255,2566,-1034,1019,2032,2033   # ����
    array_len:  .word 10                          # ���鳤��
    msg_addr:   .asciiz "Array address:"          # ��ʾ�����ַ����ʾ��
    msg_len:    .asciiz "\nArray length (N): "    # ��ʾ���鳤�ȵ���ʾ��
    msg_sp:     .asciiz "\nSum of positive odd numbers (SP): "  # ��ʾ��������
    msg_sn:     .asciiz "\nSum of negative even numbers (SN): " # ��ʾ��ż����
    newline:    .asciiz "\n"

.text
.globl main

main:
    # ��ӡ�����ַ��ʾ��
    li $v0, 4
    la $a0, msg_addr
    syscall

    # ��ӡ�����ʵ�ʵ�ַ
    li $v0, 34        
    la $a0, array
    syscall

    # ��ӡ���鳤����ʾ��
    li $v0, 4
    la $a0, msg_len
    syscall

    # ��ӡ���鳤�� N
    li $v0, 1
    lw $a0, array_len
    syscall

    # �����ӳ��� PENO(&array, N, SP, SN)
    la $a0, array       # �����ַ
    lw $a1, array_len   # ���鳤��
    jal PENO            # ��ת�����ӳ���

    # ������ֵ���浽 $s0��SP���� $s1��SN��
    move $s0, $v0       # SP���������ͣ�
    move $s1, $v1       # SN����ż���ͣ�

    # ��ӡ SP ��ʾ��
    li $v0, 4
    la $a0, msg_sp
    syscall

    # ��ӡ SP ֵ
    li $v0, 1
    move $a0, $s0
    syscall

    # ��ӡ SN ��ʾ��
    li $v0, 4
    la $a0, msg_sn
    syscall

    # ��ӡ SN ֵ
    li $v0, 1
    move $a0, $s1
    syscall

    # �˳�����
    li $v0, 10
    syscall

# ===== PENO �ӳ��� =====
# ���룺$a0 = �����ַ��$a1 = ���鳤�� N
# �����$v0 = SP���������ĺͣ���$v1 = SN����ż���ĺͣ�
PENO:
    li $v0, 0           # ��ʼ�� SP = 0
    li $v1, 0           # ��ʼ�� SN = 0
    li $t0, 0           # ��ʼ�� i = 0��ѭ����������

peno_loop:
    bge $t0, $a1, peno_end  # ��� i >= N������ѭ��

    lw $t1, 0($a0)          # ��������Ԫ�� X[i]

    # ���ж��Ƿ�Ϊ������
    ble $t1, $0, check_negative_even  # ��� X[i] <= 0�������������⸺ż��
    andi $t2, $t1, 1        # ��1��λ�룬����Ƿ�Ϊ���������λΪ 1��
    beq $t2, $0, check_negative_even  # ��ż���������������⸺ż��
    add $v0, $v0, $t1       # SP += X[i]
    j next_element          # ������һ��Ԫ��

check_negative_even:
    bge $t1, $0, next_element  # ��� X[i] >= 0�����Ԫ��Ϊ0��������������һ��Ԫ�صļ��
    andi $t2, $t1, 1        # ����Ƿ�Ϊ���������λΪ 1��
    bne $t2, $0, next_element  # ���������������
    add $v1, $v1, $t1       # SN += X[i]

next_element:
    addi $a0, $a0, 4        # ָ���ƶ�����һ������Ԫ�أ�ÿ��Ԫ��ռ4�ֽڣ�
    addi $t0, $t0, 1        # i++
    j peno_loop             # �ص�ѭ����ʼ

peno_end:
    jr $ra                  # ����������
