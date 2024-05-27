module dmem(
    input                       clk,
    input                       rst_n,
    input                       in_RegWrite,
    input                       in_MemtoReg,
    input                       in_MemRead,
    input                       in_MemWrite,
    input                       in_Branch, 
    input                       in_Zero,
    input           [31:0]      in_PC_imm,
    input           [31:0]      in_ALUResult,
    input           [31:0]      in_WriteData, // Use ReadData2 in ALU as input
    input           [4:0]       in_rd,
    input                       stall,
    input           [3:0]       in_ecall_a7,
    input           [6:0]       in_funct7,
    input           [2:0]       in_funct3,
    input                       in_flush,
    // Output to IFETCH
    // output  reg                 flush,
    output  reg                 out_PCSrc,
    output  reg     [31:0]      out_PC_imm,
    // Output to WriteBack
    output  reg                 out_RegWrite,
    output  reg                 out_MemtoReg,
    output  reg     [31:0]      out_ReadData,
    output  reg     [31:0]      out_ALUResult,
    // Other Outputs
    output  reg     [4:0]       out_rd,
    output  reg     [3:0]       out_ecall_a7,
    output          [14:0]      out_addr,
    
    // UART Programming Pinouts
    input                   upg_rst_i, // Active High Reset Signal
    input                   upg_clk_i,
    input                   upg_wen_i, // Write Enable
    input           [13:0]  upg_adr_i,
    input           [31:0]  upg_dat_i,
    input                   upg_done_i
);
    reg     [13:0]  addr     ;
    reg             PCSrc    ;
    reg     [31:0]  PC_imm   ;
    reg             RegWrite ;
    reg             MemtoReg ;
    reg     [31:0]  ALUResult;
    reg     [4:0]   rd       ;
    reg     [3:0]   ecall_a7 ;
    reg     [6:0]   funct7   ;
    reg     [2:0]   funct3   ;
    wire    [31:0]  dmem_out ;
    assign out_addr = addr;

    dmem_uram udram(  // ip core
        .clka(upg_done_i ? ~clk : upg_clk_i),
        .wea(upg_done_i ? in_MemWrite : upg_wen_i),  // write enable
        .addra(upg_done_i ? addr : upg_adr_i),  // address
        .dina(upg_done_i ? in_WriteData : upg_dat_i),  // input data
        .douta(dmem_out)  // output data
    );

    always @* begin
        case ({funct7, funct3})
             `LW_FUNCT : out_ReadData = dmem_out;
             `LB_FUNCT : out_ReadData = {{24{dmem_out[7]}}, dmem_out[7:0]};
             `LBU_FUNCT: out_ReadData = {24'b0, dmem_out[7:0]};
             default: out_ReadData = dmem_out;
        endcase
    end
    
    always @(posedge clk) begin
        if (in_flush) begin
            addr            <= 14'b0;
            RegWrite        <= 1'b0;
            MemtoReg        <= 1'b0;
            ALUResult       <= 32'b0;
            rd              <= 5'b0;
            ecall_a7        <= 4'b0;
            funct7          <= 7'b0;
            funct3          <= 3'b0;
        end
        else begin
            addr            <= stall ? addr : in_ALUResult[15:2];
            //flush           <= in_Branch & in_Zero;
            //out_PCSrc       <= (stall) ? out_PCSrc : in_Branch & in_Zero;
            //out_PC_imm      <= (stall) ? out_PC_imm : in_PC_imm;
            RegWrite        <= in_RegWrite;
            MemtoReg        <= in_MemtoReg;
            ALUResult       <= in_ALUResult;
            rd              <= in_rd;
            ecall_a7        <= in_ecall_a7;
            funct7          <= in_funct7;
            funct3          <= in_funct3;
        end
    end

    always @(negedge clk or negedge rst_n) begin
        if(~rst_n) begin
            out_RegWrite    <= 1'b0     ;
            out_MemtoReg    <= 1'b0     ;
            out_ALUResult   <= 32'b0    ;
            out_rd          <= 5'b0     ;
            out_ecall_a7    <= 0        ;
        end
        else begin
            out_RegWrite    <= stall ? out_RegWrite  : RegWrite ;
            out_MemtoReg    <= stall ? out_MemtoReg  : MemtoReg ;
            out_ALUResult   <= stall ? out_ALUResult : ALUResult;
            out_rd          <= stall ? out_rd        : rd       ;
            out_ecall_a7    <= stall ? out_ecall_a7  : ecall_a7 ;
        end
    end
    
endmodule
