.text
    li a7, 5
    ecall
    mv a1, a0  # a1 is the number
    li a0, 8  # a0 is the answer
loop:
    beqz a1, end
    addi a0, a0, -1
    srli a1, a1, 1
    j loop
end:
    li a7, 1
    ecall
    li a7, 10
    ecall
