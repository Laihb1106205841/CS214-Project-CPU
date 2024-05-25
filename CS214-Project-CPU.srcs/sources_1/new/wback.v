module wback (
    input               clk,
    input               rst_n,
    input               in_RegWrite,
    input               in_MemtoReg,
    input       [31:0]  in_ReadData,
    input       [31:0]  in_ALUResult,
    input       [4:0]   in_WriteReg,
    input               stall,
    input       [3:0]   in_ecall_a7,
    
    output  reg         out_RegWrite,
    output  reg [31:0]  out_WriteData,
    output  reg [4:0]   out_WriteReg,
    output  reg         uart_output_ready,
    output  reg         out_ecall_10
);
    reg                 RegWrite ;
    reg    [31:0]       WriteData;
    reg    [4:0]        WriteReg ;

    always @(posedge clk) begin
        RegWrite            <= in_RegWrite;
        WriteData           <= in_MemtoReg ? in_ReadData : in_ALUResult;
        WriteReg            <= in_WriteReg;
        uart_output_ready   <= (in_ecall_a7 == 4'h1);
        out_ecall_10        <= (in_ecall_a7 == 4'ha);
    end

    always @(negedge clk) begin
        out_RegWrite        <= stall ? out_RegWrite  : RegWrite ;
        out_WriteData       <= stall ? out_WriteData : WriteData;
        out_WriteReg        <= stall ? out_WriteReg  : WriteReg ;
    end
endmodule
