// Define Opcode
`define     R_OP            7'b0110011
`define     I_IMM_OP        7'b0010011
`define     I_LOAD_OP       7'b0000011
`define     I_JUMP_OP       7'b1100111  // jalr
`define     I_ECALL_OP      7'b1110011
`define     S_OP            7'b0100011
`define     J_OP            7'b1101111  // jal
`define     B_OP            7'b1100011
`define     U_OP            7'b0110111

// Define Funct for R type: {funct7, funct3}
`define     ADD_FUNCT       10'b0000000000
`define     AND_FUNCT       10'b0000000111 

// Define Funct for I type IMM: {funct3}
`define     ADDI_FUNCT      3'b000
`define     XORI_FUNCT      3'b100
`define     ANDI_FUNCT      3'b111
`define     SLLI_FUNCT      3'b001
`define     SRLI_FUNCT      3'b101

// Define Funct for I type LOAD: {funct3}
`define     LB_FUNCT        3'b000
`define     LBU_FUNCT       3'b100
`define     LW_FUNCT        3'b010

// Define Funct for I type JUMP: {funct3}
`define     JALR_FUNCT      3'b000

// Define Funct for S type: {funct3}
`define     SW_FUNCT        3'b010 

// Define Funct for B type: {funct3}
`define     BEQ_FUNCT       3'b000
`define     BNE_FUNCT       3'b001
`define     BLT_FUNCT       3'b100
`define     BGE_FUNCT       3'b101
`define     BLTU_FUNCT      3'b110
`define     BGEU_FUNCT      3'b111

`define     LI7_PTRN        32'h00000893
