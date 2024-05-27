.text
    li a7, 5
    ecall
    xori a1, a0, -1
    addi a1, a1, 1
    and a1, a0, a1  # a1 = a0 & -a0
    beq a0, a1, EQ
    li a0, 0
    j PRINT
EQ:
    li a0, 1
PRINT:
    li a7, 1
    ecall
    li a7, 10
    ecall
