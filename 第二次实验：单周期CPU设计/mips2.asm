main:

addi $4, $4, 1 #$4 = 16+1=17
ori  $4, $4, 0x0000ffff # $4 = 21 | 0xffff = 0xffff
jal jump

addi $4, $4, 1 #$4 = 16+1=17
ori  $4, $4, 0x0000ffff # $4 = 21 | 0xffff = 0xffff

jump:
addi $4, $4, 1 #$4 = 16+1=17
ori  $4, $4, 0x0000ffff # $4 = 21 | 0xffff = 0xffff
j jump2

addi $4, $4, 1 #$4 = 16+1=17
ori  $4, $4, 0x0000ffff # $4 = 21 | 0xffff = 0xffff

jump2:
addi $4, $4, 1 #$4 = 16+1=17
ori  $4, $4, 0x0000ffff # $4 = 21 | 0xffff = 0xffff
jr $ra