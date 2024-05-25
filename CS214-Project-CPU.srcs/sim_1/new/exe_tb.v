`timescale 1ns / 1ps

module exe_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg in_RegWrite;
    reg in_MemtoReg;
    reg in_Branch;
    reg in_MemRead;
    reg in_MemWrite;
    reg [1:0] in_ALUOp;
    reg in_ALUSrc_1;
    reg in_ALUSrc_2;
    reg in_PCSrc;
    reg in_uFlag;
    reg [31:0] in_PC;
    reg [31:0] in_ReadData1;
    reg [31:0] in_ReadData2;
    reg [31:0] in_Imm;
    reg [6:0] in_funct7;
    reg [2:0] in_funct3;
    reg [4:0] in_rd;
    reg [1:0] in_ForwardA;
    reg [1:0] in_ForwardB;
    reg [31:0] in_WriteData;
    reg [31:0] in_ALUResult;
    reg [4:0] in_rs1;
    reg [4:0] in_rs2;

    // Outputs
    wire out_RegWrite;
    wire out_MemtoReg;
    wire out_Branch;
    wire out_MemRead;
    wire out_MemWrite;
    wire [31:0] out_PC_imm;
    wire out_Zero;
    wire [31:0] out_ALUResult;
    wire [31:0] out_ReadData2;
    wire [4:0] out_rd;
    wire [4:0] out_rs1;
    wire [4:0] out_rs2;

    // Instantiate the Unit Under Test (UUT)
    exe uut (
        .clk(clk),
        .rst_n(rst_n),
        .in_RegWrite(in_RegWrite),
        .in_MemtoReg(in_MemtoReg),
        .in_Branch(in_Branch),
        .in_MemRead(in_MemRead),
        .in_MemWrite(in_MemWrite),
        .in_ALUOp(in_ALUOp),
        .in_ALUSrc_1(in_ALUSrc_1),
        .in_ALUSrc_2(in_ALUSrc_2),
        .in_PCSrc(in_PCSrc),
        .in_uFlag(in_uFlag),
        .in_PC(in_PC),
        .in_ReadData1(in_ReadData1),
        .in_ReadData2(in_ReadData2),
        .in_Imm(in_Imm),
        .in_funct7(in_funct7),
        .in_funct3(in_funct3),
        .in_rd(in_rd),
        .in_ForwardA(in_ForwardA),
        .in_ForwardB(in_ForwardB),
        .in_WriteData(in_WriteData),
        .in_ALUResult(in_ALUResult),
        .in_rs1(in_rs1),
        .in_rs2(in_rs2),
        .out_RegWrite(out_RegWrite),
        .out_MemtoReg(out_MemtoReg),
        .out_Branch(out_Branch),
        .out_MemRead(out_MemRead),
        .out_MemWrite(out_MemWrite),
        .out_PC_imm(out_PC_imm),
        .out_Zero(out_Zero),
        .out_ALUResult(out_ALUResult),
        .out_ReadData2(out_ReadData2),
        .out_rd(out_rd),
        .out_rs1(out_rs1),
        .out_rs2(out_rs2)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        in_RegWrite = 0;
        in_MemtoReg = 0;
        in_Branch = 0;
        in_MemRead = 0;
        in_MemWrite = 0;
        in_ALUOp = 2'b00;
        in_ALUSrc_1 = 0;
        in_ALUSrc_2 = 0;
        in_PCSrc = 0;
        in_uFlag = 0;
        in_PC = 0;
        in_ReadData1 = 0;
        in_ReadData2 = 0;
        in_Imm = 0;
        in_funct7 = 0;
        in_funct3 = 0;
        in_rd = 0;
        in_ForwardA = 2'b00;
        in_ForwardB = 2'b00;
        in_WriteData = 0;
        in_ALUResult = 0;
        in_rs1 = 0;
        in_rs2 = 0;

        // Reset the system
        #10;
        rst_n = 1;

        // Test R-type instruction: ADD x3, x1, x2
        in_RegWrite = 1;
        in_MemtoReg = 0;
        in_Branch = 0;
        in_MemRead = 0;
        in_MemWrite = 0;
        in_ALUOp = 2'b10;
        in_ALUSrc_1 = 0;
        in_ALUSrc_2 = 0;
        in_PCSrc = 0;
        in_uFlag = 0;
        in_funct7 = 7'b0000000;
        in_funct3 = 3'b000;
        in_ReadData1 = 32'd10;
        in_ReadData2 = 32'd20;
        in_rd = 5'd3;
        in_ForwardA = 2'b00;
        in_ForwardB = 2'b00;
        #10;

        // Test I-type instruction: ADDI x2, x1, 10
        in_RegWrite = 1;
        in_MemtoReg = 0;
        in_Branch = 0;
        in_MemRead = 0;
        in_MemWrite = 0;
        in_ALUOp = 2'b01;
        in_ALUSrc_1 = 0;
        in_ALUSrc_2 = 1;
        in_PCSrc = 0;
        in_uFlag = 0;
        in_funct3 = 3'b000;
        in_ReadData1 = 32'd5;
        in_Imm = 32'd10;
        in_rd = 5'd2;
        #10;

        // Test I-type LOAD instruction: LW x1, 4(x2)
        in_RegWrite = 1;
        in_MemtoReg = 1;
        in_Branch = 0;
        in_MemRead = 1;
        in_MemWrite = 0;
        in_ALUOp = 2'b00;
        in_ALUSrc_1 = 0;
        in_ALUSrc_2 = 1;
        in_PCSrc = 0;
        in_uFlag = 0;
        in_funct3 = 3'b010;
        in_ReadData1 = 32'd8;
        in_Imm = 32'd4;
        in_rd = 5'd1;
        #10;

        // Test I-type JUMP instruction: JALR x1, x2, 8
        in_RegWrite = 1;
        in_MemtoReg = 0;
        in_Branch = 1;
        in_MemRead = 0;
        in_MemWrite = 0;
        in_ALUOp = 2'b00;
        in_ALUSrc_1 = 1;
        in_ALUSrc_2 = 1;
        in_PCSrc = 1;
        in_uFlag = 0;
        in_funct3 = 3'b000;
        in_ReadData1 = 32'd100;
        in_Imm = 32'd8;
        in_rd = 5'd1;
        #10;

        // Test S-type instruction: SW x1, 8(x2)
        in_RegWrite = 0;
        in_MemtoReg = 0;
        in_Branch = 0;
        in_MemRead = 0;
        in_MemWrite = 1;
        in_ALUOp = 2'b00;
        in_ALUSrc_1 = 0;
        in_ALUSrc_2 = 1;
        in_PCSrc = 0;
        in_uFlag = 0;
        in_funct3 = 3'b010;
        in_ReadData1 = 32'd100;
        in_ReadData2 = 32'd200;
        in_Imm = 32'd8;
        #10;

        // Test B-type instruction: BEQ x1, x2, label
        in_RegWrite = 0;
        in_MemtoReg = 0;
        in_Branch = 1;
        in_MemRead = 0;
        in_MemWrite = 0;
        in_ALUOp = 2'b01;
        in_ALUSrc_1 = 0;
        in_ALUSrc_2 = 0;
        in_PCSrc = 0;
        in_uFlag = 0;
        in_funct3 = 3'b000;
        in_ReadData1 = 32'd8;
        in_ReadData2 = 32'd8;
        in_Imm = 32'd16;
        in_rd = 5'd0;
        #10;

        // Test U-type instruction: LUI x1, 0xFFFFF000
        in_RegWrite = 1;
        in_MemtoReg = 0;
        in_Branch = 0;
        in_MemRead = 0;
        in_MemWrite = 0;
        in_ALUOp = 2'b11;
        in_ALUSrc_1 = 0;
        in_ALUSrc_2 = 1;
        in_PCSrc = 0;
        in_uFlag = 1;
        in_funct3 = 3'b000;
        in_ReadData1 = 32'd0;
        in_Imm = 32'hFFFFF000;
        in_rd = 5'd1;
        #10;

        $finish;
    end

endmodule
