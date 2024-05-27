`timescale 1ns / 1ps

module idecode_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg in_RegWrite;
    reg [4:0] in_rd;
    reg [31:0] in_WriteData;
    reg [31:0] in_instruction;
    reg [31:0] in_PC;

    // Outputs
    wire out_Branch;
    wire out_MemRead;
    wire out_MemtoReg;
    wire [1:0] out_ALUOp;
    wire out_MemWrite;
    wire out_ALUSrc_1;
    wire out_ALUSrc_2;
    wire out_RegWrite;
    wire out_uFlag;
    wire [31:0] out_ReadData1;
    wire [31:0] out_ReadData2;
    wire [31:0] out_PC;
    wire [31:0] out_imm;
    wire [6:0] out_funct7;
    wire [2:0] out_funct3;
    wire [4:0] out_rd;
    wire [31:0] out_instruction;
    wire [4:0] out_rs1;
    wire [4:0] out_rs2;
    wire [6:0] opcode;

    // Instantiate the idecode module
    idecode uut (
        .clk(clk),
        .rst_n(rst_n),
        .in_RegWrite(in_RegWrite),
        .in_rd(in_rd),
        .in_WriteData(in_WriteData),
        .in_instruction(in_instruction),
        .in_PC(in_PC),
        .out_Branch(out_Branch),
        .out_MemRead(out_MemRead),
        .out_MemtoReg(out_MemtoReg),
        .out_ALUOp(out_ALUOp),
        .out_MemWrite(out_MemWrite),
        .out_ALUSrc_1(out_ALUSrc_1),
        .out_ALUSrc_2(out_ALUSrc_2),
        .out_RegWrite(out_RegWrite),
        .out_uFlag(out_uFlag),
        .out_ReadData1(out_ReadData1),
        .out_ReadData2(out_ReadData2),
        .out_PC(out_PC),
        .out_imm(out_imm),
        .out_funct7(out_funct7),
        .out_funct3(out_funct3),
        .out_rd(out_rd),
        .out_instruction(out_instruction),
        .out_rs1(out_rs1),
        .out_rs2(out_rs2),
        .opcode(opcode)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        in_RegWrite = 0;
        in_rd = 0;
        in_WriteData = 0;
        in_instruction = 0;
        in_PC = 0;

        // Wait for reset
        #8;
        rst_n = 1;
        #12;

        // Test R-type instruction: ADD x3, x1, x2
        in_instruction = {7'b0000000, 5'b00010, 5'b00001, 3'b000, 5'b00011, 7'b0110011};
        #10;

        // Test R-type instruction: AND x3, x1, x2
        in_instruction = {7'b0000000, 5'b00010, 5'b00001, 3'b111, 5'b00011, 7'b0110011};
        #10;

        // Test I-type IMM instruction: ADDI x2, x1, 10
        in_instruction = {12'b000000001010, 5'b00001, 3'b000, 5'b00010, 7'b0010011};
        #10;

        // Test I-type IMM instruction: ANDI x2, x1, 10
        in_instruction = {12'b000000001010, 5'b00001, 3'b111, 5'b00010, 7'b0010011};
        #10;

        // Test I-type LOAD instruction: LW x1, 4(x2)
        in_instruction = {12'b000000000100, 5'b00010, 3'b010, 5'b00001, 7'b0000011};
        #10;

        // Test I-type JUMP instruction: JALR x1, x2, 8
        in_instruction = {12'b000000001000, 5'b00010, 3'b000, 5'b00001, 7'b1100111};
        #10;

        // Test S-type instruction: SW x1, 8(x2)
        in_instruction = {7'b0000000, 5'b00001, 5'b00010, 3'b010, 5'b001000, 7'b0100011};
        #10;

        // Test B-type instruction: BEQ x1, x2, 16
        in_instruction = {7'b0000000, 5'b00001, 5'b00010, 3'b000, 5'b001000, 7'b1100011};
        #10;

        // Test B-type instruction: BNE x1, x2, 16
        in_instruction = {7'b0000000, 5'b00001, 5'b00010, 3'b001, 5'b001000, 7'b1100011};
        #10;

        // Test U-type instruction: LUI x1, 0x12345
        in_instruction = {20'b00000001000100100001, 5'b00001, 7'b0110111};
        #10;

        // Test J-type instruction: JAL x1, 0x12345
        in_instruction = {1'b0, 10'b0010010000, 1'b0, 8'b00100100, 5'b00001, 7'b1101111};
        #10;

        // Test RegWrite functionality
        in_RegWrite = 1;
        in_rd = 2'b10;
        in_WriteData = 32'h00000011;
        in_instruction = 32'b0000000_00010_00001_000_00111_0110011; // ADD x7, x1, x2 (funct7=0, rs2=2, rs1=1, funct3=0, rd=7, opcode=0110011)
        #20;

        // Finish simulation
        $stop;
    end

endmodule
