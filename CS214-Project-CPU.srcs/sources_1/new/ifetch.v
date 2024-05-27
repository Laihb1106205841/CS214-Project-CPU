module ifetch(
    input                   clk,
    input                   rst_n,
    input                   in_PCSrc,
    input           [3:0]   in_testcase,
    input           [31:0]  in_PC_imm,
    input                   stall,
    output          [31:0]  out_instruction,
    output  reg     [31:0]  out_PC,
    
    // UART Programming Pinouts
    input                   upg_rst_i, // Active High Reset Signal
    input                   upg_clk_i,
    input                   upg_wen_i, // Write Enable
    input           [13:0]  upg_adr_i,
    input           [31:0]  upg_dat_i,
    input                   upg_done_i // UART Done and Init
);

    parameter   ADDR_WIDTH  = 32,
                INITIALIZATION  = 32'hFFFFFFFF;
    
    reg [ADDR_WIDTH -1:0] PC;
    
    // 1 means CPU works on normal mode.
    // Otherwise CPU works on UART communication mode.
    
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
        .clka(upg_done_i? ~clk: upg_clk_i),
        .addra(upg_done_i? inst_addr[13:0]: upg_adr_i),
        .dina(upg_done_i? 32'h00000000: upg_dat_i),
        .wea(upg_done_i? 1'b0 : upg_wen_i),
        .douta(out_instruction)
    );
    
endmodule