.data
    array:      .word 121,-124,138,-199,255,2566,-1034,1019,2032,2033   # 数组
    array_len:  .word 10                          # 数组长度
    msg_addr:   .asciiz "Array address:"          # 显示数组地址的提示语
    msg_len:    .asciiz "\nArray length (N): "    # 显示数组长度的提示语
    msg_sp:     .asciiz "\nSum of positive odd numbers (SP): "  # 显示正奇数和
    msg_sn:     .asciiz "\nSum of negative even numbers (SN): " # 显示负偶数和
    newline:    .asciiz "\n"

.text
.globl main

main:
    # 打印数组地址提示语
    li $v0, 4
    la $a0, msg_addr
    syscall

    # 打印数组的实际地址
    li $v0, 34        
    la $a0, array
    syscall

    # 打印数组长度提示语
    li $v0, 4
    la $a0, msg_len
    syscall

    # 打印数组长度 N
    li $v0, 1
    lw $a0, array_len
    syscall

    # 调用子程序 PENO(&array, N, SP, SN)
    la $a0, array       # 数组地址
    lw $a1, array_len   # 数组长度
    jal PENO            # 跳转调用子程序

    # 将返回值保存到 $s0（SP）和 $s1（SN）
    move $s0, $v0       # SP（正奇数和）
    move $s1, $v1       # SN（负偶数和）

    # 打印 SP 提示语
    li $v0, 4
    la $a0, msg_sp
    syscall

    # 打印 SP 值
    li $v0, 1
    move $a0, $s0
    syscall

    # 打印 SN 提示语
    li $v0, 4
    la $a0, msg_sn
    syscall

    # 打印 SN 值
    li $v0, 1
    move $a0, $s1
    syscall

    # 退出程序
    li $v0, 10
    syscall

# ===== PENO 子程序 =====
# 输入：$a0 = 数组地址，$a1 = 数组长度 N
# 输出：$v0 = SP（正奇数的和），$v1 = SN（负偶数的和）
PENO:
    li $v0, 0           # 初始化 SP = 0
    li $v1, 0           # 初始化 SN = 0
    li $t0, 0           # 初始化 i = 0（循环计数器）

peno_loop:
    bge $t0, $a1, peno_end  # 如果 i >= N，跳出循环

    lw $t1, 0($a0)          # 加载数组元素 X[i]

    # 先判断是否为正奇数
    ble $t1, $0, check_negative_even  # 如果 X[i] <= 0，跳过，进入检测负偶数
    andi $t2, $t1, 1        # 与1按位与，检查是否为奇数（最低位为 1）
    beq $t2, $0, check_negative_even  # 是偶数，跳过，进入检测负偶数
    add $v0, $v0, $t1       # SP += X[i]
    j next_element          # 跳到下一个元素

check_negative_even:
    bge $t1, $0, next_element  # 如果 X[i] >= 0，则此元素为0，跳过，进入下一个元素的检测
    andi $t2, $t1, 1        # 检查是否为奇数（最低位为 1）
    bne $t2, $0, next_element  # 如果是奇数，跳过
    add $v1, $v1, $t1       # SN += X[i]

next_element:
    addi $a0, $a0, 4        # 指针移动到下一个数组元素（每个元素占4字节）
    addi $t0, $t0, 1        # i++
    j peno_loop             # 回到循环开始

peno_end:
    jr $ra                  # 返回主程序
