`include "define.v"

module exe (
    input               clk,
    input               rst_n,
    
    // Control Input
    input               in_RegWrite,
    input               in_MemtoReg,
    input               in_Branch,
    input               in_MemRead,
    input               in_MemWrite,
    input       [1:0]   in_ALUOp,
    input               in_ALUSrc_1,
    input               in_ALUSrc_2,
    input               in_PCSrc,
    input               in_uFlag,
    
    // Input from Dmem isFlush
    input               in_flush,
    
    input       [31:0]  in_PC,
    input       [31:0]  in_ReadData1,
    input       [31:0]  in_ReadData2,
    input       [31:0]  in_Imm,
    input       [6:0]   in_funct7,
    input       [2:0]   in_funct3,
    input       [4:0]   in_rd,
    input       [1:0]   in_ForwardA,
    input       [1:0]   in_ForwardB,
    input       [31:0]  in_WriteData,
    input       [31:0]  in_ALUResult,
    input       [4:0]   in_rs1,
    input       [4:0]   in_rs2,
    input       [3:0]   in_ecall_a7,
    input               stall,

    output  reg         out_RegWrite,
    output  reg         out_MemtoReg,
    output  reg         out_Branch,
    output  reg         out_MemRead,
    output  reg         out_MemWrite,
    output  reg [31:0]  out_PC_imm,
    output  reg         out_Zero,
    output  reg [31:0]  out_ALUResult,
    output  reg [31:0]  out_ReadData2,
    output  reg [6:0]   out_funct7,
    output  reg [2:0]   out_funct3,
    output  reg [4:0]   out_rd,
    output  reg [4:0]   out_rs1,
    output  reg [4:0]   out_rs2,
    output  reg [3:0]   out_ecall_a7
);

    wire        [31:0]  PCSrc;
    reg         [31:0]  ALUSrc1;
    reg         [31:0]  ALUSrc2;
    wire        [31:0]  SubResult;
    reg         [31:0]  operand1;
    reg         [31:0]  operand2;
    reg         [2:0]   ALUControl;
    
    // Reg for mid-data transmission
    reg                 RegWrite ;
    reg                 MemtoReg ;
    reg                 Branch   ;
    reg                 MemRead  ;
    reg                 MemWrite ;
    reg         [31:0]  ReadData2;
    reg         [4:0]   rd       ;
    reg         [4:0]   rs1      ;
    reg         [4:0]   rs2      ;
    reg         [31:0]  PC_imm   ;
    reg         [6:0]   funct7   ;
    reg         [2:0]   funct3   ;
    reg         [1:0]   ALUOp    ;
    reg         [1:0]   ForwardA ;
    reg         [1:0]   ForwardB ;
    reg         [31:0]  WriteData;
    reg         [31:0]  ALUResult;
    reg         [3:0]   ecall_a7 ;
    
    assign PCSrc = in_PCSrc? in_ReadData1 : in_PC;
    
    always @(posedge clk) begin  // copies and small ALU
        // Directly pass to output
        RegWrite            <= in_RegWrite;
        MemtoReg            <= in_MemtoReg;
        Branch              <= in_Branch;
        MemRead             <= in_MemRead;
        MemWrite            <= in_MemWrite;
        ReadData2           <= in_ReadData2;
        rd                  <= in_rd;
        rs1                 <= in_rs1;
        rs2                 <= in_rs2;
        PC_imm              <= PCSrc + (in_Imm >> 2);
        ecall_a7            <= in_ecall_a7;
        
        // Used in the module.
        funct7              <= in_funct7;
        funct3              <= in_funct3;
        ALUOp               <= in_ALUOp;
        WriteData           <= in_WriteData;
        ALUResult           <= in_ALUResult;
        ForwardA            <= in_ForwardA;
        ForwardB            <= in_ForwardB;
        ALUSrc1             <= in_ALUSrc_1 ? in_PC : in_ReadData1;
        ALUSrc2             <= in_ALUSrc_2 ? in_Imm : in_ReadData2;
    end
    
    always @* begin
        case (ForwardA)
            2'b00: operand1 = ALUSrc1;
            2'b01: operand1 = WriteData;
            2'b10: operand1 = ALUResult;
            default: operand1 = 0;
        endcase
    end
    
    always @* begin
        case (ForwardB)
            2'b00: operand2 = ALUSrc2;
            2'b01: operand2 = WriteData;
            2'b10: operand2 = ALUResult;
            default: operand2 = 0;
        endcase
    end

    assign SubResult = operand1 - operand2;

    always  @* begin
        case(ALUOp) 
            2'b10: begin
                case({funct7, funct3})
                    `ADD_FUNCT: ALUControl = 3'b000; // add
                    `AND_FUNCT: ALUControl = 3'b001; // and
                endcase
            end
            2'b01: begin
                if(in_Branch == 1'b0) begin
                    case(funct3)
                        `ADDI_FUNCT:    ALUControl = 3'b000;  // addi
                        `ANDI_FUNCT:    ALUControl = 3'b001;  // andi
                        `XORI_FUNCT:    ALUControl = 3'b010;  // xori
                        `SLLI_FUNCT:    ALUControl = 3'b011;  // slli
                        `SRLI_FUNCT:    ALUControl = 3'b101;  // srli
                        default:        ALUControl = 3'b111;
                    endcase
                end
                else begin
                    ALUControl = 3'b111;
                end
            end
            2'b00: ALUControl = 3'b110;
            2'b11: ALUControl = (in_uFlag) ? 3'b100: 3'b000;
            default: ALUControl = 3'b111;
        endcase
    end

    always @(negedge clk or negedge rst_n) begin  // Big ALU calculation
        if(~rst_n || in_flush) begin
            out_ALUResult   <= 0;
            out_Zero        <= 0;
            out_RegWrite    <= 0;
            out_MemtoReg    <= 0;
            out_Branch      <= 0;
            out_MemRead     <= 0;
            out_MemWrite    <= 0;
            out_ReadData2   <= 0;
            out_funct7      <= 0;
            out_funct3      <= 0;
            out_rd          <= 0;
            out_rs1         <= 0;
            out_rs2         <= 0;
            out_PC_imm      <= 0;
            out_ecall_a7    <= 0;
        end
        else begin
            case(ALUControl)
                3'b000: out_ALUResult <= stall ? out_ALUResult : operand1 + operand2;
                3'b001: out_ALUResult <= stall ? out_ALUResult : operand1 & operand2;
                3'b010: out_ALUResult <= stall ? out_ALUResult : operand1 ^ operand2;
                3'b011: out_ALUResult <= stall ? out_ALUResult : operand1 << operand2[4:0];
                3'b101: out_ALUResult <= stall ? out_ALUResult : operand1 >> operand2[4:0];
                3'b110: begin
                    out_ALUResult <= stall ? out_ALUResult : operand1 + 1; // Because our RAM is word addressable, this is not PC + 1.
                    out_Zero <= stall ? out_Zero : (out_PC_imm == 0);
                end
                3'b100: out_ALUResult <= stall ? out_ALUResult : operand2;
                default: begin
                    case(funct3)
                        `BEQ_FUNCT:     out_Zero <= stall ? out_Zero : (SubResult == 0);
                        `BNE_FUNCT:     out_Zero <= stall ? out_Zero : (SubResult != 0);
                        `BLT_FUNCT:     out_Zero <= stall ? out_Zero : (SubResult < 0);
                        `BGE_FUNCT:     out_Zero <= stall ? out_Zero : (SubResult >= 0);
                        `BLTU_FUNCT:    out_Zero <= stall ? out_Zero : (SubResult < 0);
                        `BGEU_FUNCT:    out_Zero <= stall ? out_Zero : (SubResult >= 0);
                        default:        out_Zero <= stall ? out_Zero : (SubResult == 0);
                    endcase
                end
            endcase
            out_RegWrite    <= stall ? out_RegWrite  : RegWrite ;
            out_MemtoReg    <= stall ? out_MemtoReg  : MemtoReg ;
            out_Branch      <= stall ? out_Branch    : Branch   ;
            out_MemRead     <= stall ? out_MemRead   : MemRead  ;
            out_MemWrite    <= stall ? out_MemWrite  : MemWrite ;
            out_ReadData2   <= stall ? out_ReadData2 : ReadData2;
            out_funct7      <= stall ? out_funct7    : funct7   ;
            out_funct3      <= stall ? out_funct3    : funct3   ;
            out_rd          <= stall ? out_rd        : rd       ;
            out_rs1         <= stall ? out_rs1       : rs1      ;
            out_rs2         <= stall ? out_rs2       : rs2      ;
            out_PC_imm      <= stall ? out_PC_imm    : PC_imm   ;
            out_ecall_a7    <= stall ? out_ecall_a7  : ecall_a7 ;
        end
    end
endmodule
