.text
    li a7, 5
    ecall
    sw a0, -4(sp)
    lbu a1, -4(sp)
    add x0, x0, x0
    mv a0, a1
    li a7, 1
    ecall

    li a7, 10
    ecall
