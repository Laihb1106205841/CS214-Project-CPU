`include "define.v"

module control(
    input               clk,
    input               rst_n,
    input   [6:0]       opcode,
    input               stall,
    input               flush,
    output  reg         branch,
    output  reg         memRead,
    output  reg         memToReg,
    output  reg [1:0]   ALUOp,
    output  reg         memWrite,
    output  reg         ALUSrc_1, // Used to determine if the first input is from ReadData1 (0) or from PC (1)
    output  reg         ALUSrc_2, // Used to determine if the second input is from ReadData2 (0) or from Immediate (1)
    output  reg         regWrite,
    output  reg         PCSrc, // Used to determine if the PC should be PC + imm (0) or rs1 + imm (1)
    output  reg         uFlag
);

    always @(negedge clk or negedge rst_n) begin
        if(~rst_n || flush) begin
            branch      <= 1'b0;
            memRead     <= 1'b0;
            memToReg    <= 1'b0;
            ALUOp       <= 2'b00;
            memWrite    <= 1'b0;
            ALUSrc_1    <= 1'b0;
            ALUSrc_2    <= 1'b0;
            regWrite    <= 1'b0;
            PCSrc       <= 1'b0;
            uFlag       <= 1'b0;
        end
        else if(stall) begin
            branch      <= branch;
            memRead     <= memRead;
            memToReg    <= memToReg ;
            ALUOp       <= ALUOp;
            memWrite    <= memWrite;
            ALUSrc_1    <= ALUSrc_1 ;
            ALUSrc_2    <= ALUSrc_2;
            regWrite    <= regWrite;
            PCSrc       <= PCSrc;
            uFlag       <= uFlag;
        end
        else begin
            case(opcode)
                `R_OP: begin // R type: ResultData = ReadData1 + ReadData2
                    branch      <= 1'b0;
                    memRead     <= 1'b0;
                    memToReg    <= 1'b0;
                    ALUOp       <= 2'b10; // Determined by {funct7, funct3}
                    memWrite    <= 1'b0;
                    ALUSrc_1    <= 1'b0;
                    ALUSrc_2    <= 1'b0;
                    regWrite    <= 1'b1;
                    PCSrc       <= 1'b0;
                    uFlag       <= 1'b0;
                end
                `I_IMM_OP:begin // Immediate I type: ResultData = ReadData1 + Imm;  
                    branch      <= 1'b0;
                    memRead     <= 1'b0;
                    memToReg    <= 1'b0;
                    ALUOp       <= 2'b01; // Determined by {funct3}
                    memWrite    <= 1'b0;
                    ALUSrc_1    <= 1'b0;
                    ALUSrc_2    <= 1'b1;
                    regWrite    <= 1'b1;
                    PCSrc       <= 1'b0;
                    uFlag       <= 1'b0;
                end
                `I_LOAD_OP: begin // Load word I type: ResultData = ReadData1 + Imm;
                    branch      <= 1'b0;
                    memRead     <= 1'b1;
                    memToReg    <= 1'b1;
                    ALUOp       <= 2'b11; // Not relevant, can add directly
                    memWrite    <= 1'b0;
                    ALUSrc_1    <= 1'b0;
                    ALUSrc_2    <= 1'b1;
                    regWrite    <= 1'b1;
                    PCSrc       <= 1'b0;
                    uFlag       <= 1'b0;
                end
                `I_JUMP_OP:begin // Jump I type: PC = ReadData1 + Imm;  ResultData = PC + 4
                    branch      <= 1'b1;
                    memRead     <= 1'b0;
                    memToReg    <= 1'b0;
                    ALUOp       <= 2'b00; // Not relevant, can add directly: rd = PC + 4
                    memWrite    <= 1'b0;
                    ALUSrc_1    <= 1'b1; // PC
                    ALUSrc_2    <= 1'b1; // Immediate
                    regWrite    <= 1'b1; 
                    PCSrc       <= 1'b1; // ReadData1
                    uFlag       <= 1'b0;
                end
                `I_ECALL_OP:begin // ECALL I type
                    branch      <= 1'b0;
                    memRead     <= 1'b0;
                    memToReg    <= 1'b0;
                    ALUOp       <= 2'b00; 
                    memWrite    <= 1'b0;
                    ALUSrc_1    <= 1'b0; // PC
                    ALUSrc_2    <= 1'b0; // Immediate
                    regWrite    <= 1'b0; 
                    PCSrc       <= 1'b0; // ReadData1
                    uFlag       <= 1'b0;
                end
                `S_OP: begin // Store word S type: ResultData = ReadData + Imm
                    branch      <= 1'b0;
                    memRead     <= 1'b0;
                    memToReg    <= 1'b0;
                    ALUOp       <= 2'b11; // Add directly
                    memWrite    <= 1'b1;
                    ALUSrc_1    <= 1'b0;
                    ALUSrc_2    <= 1'b1;
                    regWrite    <= 1'b0;
                    PCSrc       <= 1'b0;
                    uFlag       <= 1'b0;
                end
                `J_OP: begin // J type: PC = PC + Imm; ResultData = PC + 4
                    branch      <= 1'b1;
                    memRead     <= 1'b0;
                    memToReg    <= 1'b0;
                    ALUOp       <= 2'b00; // Not relevant, can add directly: rd = PC + 4
                    memWrite    <= 1'b0;
                    ALUSrc_1    <= 1'b1; // PC
                    ALUSrc_2    <= 1'b1; // Imm
                    regWrite    <= 1'b1;
                    PCSrc       <= 1'b0; // PC
                    uFlag       <= 1'b0;
                end
                `B_OP: begin // B type: ResultData invalid
                    branch      <= 1'b1;
                    memRead     <= 1'b0;
                    memToReg    <= 1'b0;
                    ALUOp       <= 2'b01; // Determined by {funct3}
                    memWrite    <= 1'b0;
                    ALUSrc_1    <= 1'b0;
                    ALUSrc_2    <= 1'b0;
                    regWrite    <= 1'b0;
                    PCSrc       <= 1'b0;
                    uFlag       <= 1'b0;
                end
                `U_OP: begin // U type: ResultData = Imm
                    branch      <= 1'b0;
                    memRead     <= 1'b0;
                    memToReg    <= 1'b0;
                    ALUOp       <= 2'b11; // Not relevant, the shift process is done in decode module.
                    memWrite    <= 1'b0;
                    ALUSrc_1    <= 1'b0;
                    ALUSrc_2    <= 1'b1; 
                    regWrite    <= 1'b1;
                    PCSrc       <= 1'b0;
                    uFlag       <= 1'b1;
                end
                default: begin
                    branch      <= 1'b0;
                    memRead     <= 1'b0;
                    memToReg    <= 1'b0;
                    ALUOp       <= 2'b00;
                    memWrite    <= 1'b0;
                    ALUSrc_1    <= 1'b0;
                    ALUSrc_2    <= 1'b0;
                    regWrite    <= 1'b0;
                    PCSrc       <= 1'b0;
                    uFlag       <= 1'b0;
                end
            endcase
        end
    end
endmodule
