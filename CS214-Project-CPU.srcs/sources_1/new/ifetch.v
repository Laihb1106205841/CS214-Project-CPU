module ifetch(
    input                   clk,
    input                   rst_n,
    input                   in_PCSrc,
    input           [3:0]   in_testcase,
    input           [31:0]  in_PC_imm,
    input                   imemWriteEn,
    input           [31:0]  imemWriteData,
    input                   stall,
    output          [31:0]  out_instruction,
    output  reg     [31:0]  out_PC
);

    parameter   ADDR_WIDTH  = 32,
                INITIALIZATION  = 32'hFFFFFFFF;
    
    reg [ADDR_WIDTH -1:0] PC;
    
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            PC <= INITIALIZATION;
        end
        else if (stall) begin
            PC <= PC;
        end
        else begin
            PC <= (in_PCSrc) ? in_PC_imm : (PC + 1);
        end
    end

    always @(negedge clk or negedge rst_n) begin
        if(~rst_n) begin
            out_PC <= 32'h0;
        end
        else begin
            out_PC <= stall ? out_PC : PC;
        end
    end
    
    wire    [ADDR_WIDTH -1:0]   inst_addr;
    assign  inst_addr = PC + in_testcase * 25;
    
    instr_mem u_instr_mem(
        .clka(~clk),
        .addra(inst_addr[13:0]),
        .dina(imemWriteData),
        .douta(out_instruction),
        .ena(rst_n & ~stall),
        .wea(imemWriteEn)
    );
    
endmodule