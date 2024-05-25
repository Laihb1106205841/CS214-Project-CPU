.text
    li a7, 5
    ecall
    mv a1, a0
    ecall
    add a0, a0, a1
    li a1, 255
    bge a1, a0, PRINT
    andi a0, a0, 255
    addi a0, a0, 1
    xori a0, a0, -1
PRINT:
    li a7, 1
    ecall
    li a7, 10
    ecall
