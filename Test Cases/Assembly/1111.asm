.text
main:
    li a7, 5
    ecall
    mv a2, a0  # a2 is the upper limit
    li a1, 20  # a1 is n
    ecall  # a0 is the mode
    # a0 = 0: print push stack
    # a0 = 1: print pop stack
    li s1, 2  # s1 is literal 2
    li a7, 1
    jal fib
    mv a0, s0  # s0 is the answer
    ecall
    li a7, 10
    ecall

fib:  # use s2 as return value
    bge a1, s1, cont  # if a1 >= 2, need calculation
    li s2, 1
    j end
cont:  # ra | fib(a1 - 1) | sp
    addi sp, sp, -8
    sw ra, 8(sp)
    addi a1, a1, -1
    jal fib
    sw s2, 4(sp)
    bnez a0, skip1
    mv a0, a2
    ecall
    li a0, 1
skip1:
    addi a1, a1, -1
    jal fib
    addi a1, a1, 2
    lw t2, 4(sp)
    beqz a0, skip2
    mv a0, t2
    ecall
    li a0, 0
skip2:
    lw ra, 8(sp)
    add s2, s2, t2
    addi sp, sp, 8
end:
    bge s2, a2, return
    blt a1, s0, return
    mv s0, a1
return:
    jr ra
