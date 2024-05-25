.text
    li a7, 5
    ecall
    mv a1, a0  # a1 is the number
    ecall  # a0 is the mode
    beqz a0, PRINT
    lui a2, 1
    add a2, a2, a1
    li a1, 0
loop:
    andi t0, a2, 1
    slli a1, a1, 1
    add a1, a1, t0
    srli a2, a2, 1
    bnez a2, loop

    srli a1, a1, 1
PRINT:
    mv a0, a1
    li a7, 1
    ecall
    li a7, 10
    ecall
