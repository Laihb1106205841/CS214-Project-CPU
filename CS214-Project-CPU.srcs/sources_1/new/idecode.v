`include "define.v"

module idecode(
    input                   clk,
    input                   rst_n,
    input                   in_RegWrite,
    input           [4:0]   in_rd,
    input           [31:0]  in_WriteData,
    input           [31:0]  in_instruction,
    input           [31:0]  in_PC,
    input                   uart_input_ready,
    input           [31:0]  uart_input,
    input                   in_ecall_10,
    
    // Input from DMem flush
    input                   in_flush,
    // Control Output
    output                  out_Branch,
    output                  out_MemRead,
    output                  out_MemtoReg,
    output          [1:0]   out_ALUOp,
    output                  out_MemWrite,
    output                  out_ALUSrc_1,
    output                  out_ALUSrc_2,
    output                  out_RegWrite,
    output                  out_PCSrc,
    output                  out_uFlag,
    
    // Register Output
    output          [31:0]  out_ReadData1, // Output from rs1 
    output          [31:0]  out_ReadData2, // Output from rs2 
    output          [31:0]  uart_output,  // Output from register a0
    
    // Other Input/Output
    output  reg     [31:0]  out_PC, // Output PC, the final input will be determined by ALUSrc in EXE module. 
    output  reg     [31:0]  out_imm, // Output Immediate, the final input will be determined by ALUSrc in EXE module. 
    output  reg     [6:0]   out_funct7,
    output  reg     [2:0]   out_funct3,
    output  reg     [4:0]   out_rd,
    output  reg     [31:0]  out_instruction,
    output  reg     [4:0]   out_rs1,
    output  reg     [4:0]   out_rs2,
    output  reg     [3:0]   out_ecall_a7,
    output  reg             stall
);
    reg     [6:0]       opcode;   
    reg     [31:0]      instruction;
    reg     [31:0]      PC;
    reg     [3:0]       last_time_a7;
    reg     [3:0]       curr_time_a7;
    reg     [4:0]       rs_1;
    reg     [4:0]       rs_2;

    // Posedge, we let the data flow in the IDecode Module.
    always @(posedge clk) begin
        opcode      <= in_instruction[6:0];
        instruction <= in_instruction;
        PC          <= in_PC;
        rs_1        <= in_instruction[19:15];
        rs_2        <= in_instruction[24:20];
        // Judge whether the instruction is SYSCALL instruction and store the SYSCALL type
        last_time_a7<= curr_time_a7;
        curr_time_a7<= ((in_instruction & `LI7_PTRN) == `LI7_PTRN) ? in_instruction[23:20] : 0;
    end
    
    // When an `ecall` instruction is detected, we need to stall when the input immediate is 5 or 6. (Read Int or Read Float)
    // And the stall will end when an input ready signal is sent.
    wire    is_ecall_input, is_end_input;
    assign  is_ecall_input = (opcode == `I_ECALL_OP) && (last_time_a7 == 5 || last_time_a7 == 6);
    assign  is_end_input = (opcode == `I_ECALL_OP) && (last_time_a7 == 10);

    // always @* begin
    always @(negedge clk or negedge rst_n) begin
        if (~rst_n) begin
            stall <= 1'b0;
        end
        else begin
            if (in_ecall_10) begin
                stall <= 1'b1;
            end
            else if (is_ecall_input) begin  // || is_end_input
                stall <= 1'b1;
            end
            else if (uart_input_ready && in_instruction) begin
                stall <= 1'b0;
            end
            else begin
                stall <= stall;
            end
        end
    end
   
    // Negedge, we let the data flow out the IDecode Module.
    always @(negedge clk or negedge rst_n) begin
        if(~rst_n || in_flush) begin
            out_funct7 <= 7'b0;
            out_funct3 <= 3'b0;
            out_rd <= 5'b0;
            out_instruction <= 32'b0;
            out_rs1 <= 5'b0;
            out_rs2 <= 5'b0;
            out_PC <= 32'b0;
            out_imm <= 32'b0;
        end
        else begin
            out_funct7      <= stall ? out_funct7      : {instruction[31:25]};
            out_funct3      <= stall ? out_funct3      : {instruction[14:12]};
            out_rd          <= stall ? out_rd          : {instruction[11:7]};
            out_instruction <= stall ? out_instruction : instruction;
            out_rs1         <= stall ? out_rs1         : rs_1;
            out_rs2         <= stall ? out_rs2         : rs_2;
            out_PC          <= stall ? out_PC          : PC;
            out_ecall_a7    <= (opcode == `I_ECALL_OP) ? last_time_a7 : 0;
            case(opcode)
                `I_IMM_OP, `I_LOAD_OP, `I_JUMP_OP: out_imm <= stall ? out_imm : {{20{instruction[31]}}, instruction[31:20]};
                `S_OP: out_imm <= stall ? out_imm : {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                `B_OP: out_imm <= stall ? out_imm : {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                `U_OP: out_imm <= stall ? out_imm : {instruction[31:12], 12'b0};
                `J_OP: out_imm <= stall ? out_imm : {{19{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                default: out_imm <= stall ? out_imm : 32'b0;
            endcase
        end
    end

    control ucontrol(
        .clk            (clk),
        .rst_n          (rst_n),
        .opcode         (opcode),
        .stall          (stall),
        .flush          (in_flush),
        .branch         (out_Branch),
        .memRead        (out_MemRead),
        .memToReg       (out_MemtoReg),
        .ALUOp          (out_ALUOp),
        .memWrite       (out_MemWrite),
        .ALUSrc_1       (out_ALUSrc_1),
        .ALUSrc_2       (out_ALUSrc_2),
        .regWrite       (out_RegWrite),
        .PCSrc          (out_PCSrc),
        .uFlag          (out_uFlag)
    );
    
    register uregister(
        .clk            (clk),
        .rst_n          (rst_n),
        .regWrite       (uart_input_ready ? 1'b1 : in_RegWrite),
//      .isFloat        (1'b0),
        .stall          (stall),
        .readReg1       (rs_1),
        .readReg2       (rs_2),
        .writeReg       (uart_input_ready ? 10 : in_rd),
        .writeData      (uart_input_ready ? uart_input : in_WriteData),
        .readData1      (out_ReadData1),
        .readData2      (out_ReadData2),
        .real_time_a0   (uart_output)
    );
endmodule
