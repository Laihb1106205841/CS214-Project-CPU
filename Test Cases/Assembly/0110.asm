.text
    lw a1, 0(sp)
    lw a2, -4(sp)
    add x0, x0, x0
    bltu a1, a2, TRUE
    li a0, 0
    j PRINT
TRUE:
    li a0, 1
PRINT:
    li a7, 1
    ecall
    li a7, 10
    ecall
