main:
bltz $1 main
jal sk

beq $1 $1 sk
bne $1 $1 sk

# lb: 加载一个字节并进行符号扩展
lb   $3, 0($2)         # 从 array[0] 读取字节并符号扩展到 $3
# lbu: 加载一个字节并进行无符号扩展
lbu  $4, 1($2)         # 从 array[1] 读取字节并无符号扩展到 $4
# lh: 加载两个字节并进行符号扩展
lh   $5, 2($2)         # 从 array[2] 和 array[3] 读取两个字节并符号扩展到 $5
# lhu: 加载两个字节并进行无符号扩展
lhu  $6, 4($2)         # 从 array[4] 和 array[5] 读取两个字节并无符号扩展到 $6
    
sk:
 jr $ra