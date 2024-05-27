module fwd (
    input   [4:0]   in_rs1,
    input   [4:0]   in_rs2,
    input   [4:0]   EX_rd_out,
    input           EX_RegWrite_out,
    input   [4:0]   MEM_rd_out,
    input           MEM_RegWrite_out,
    input   [4:0]   WB_rd_out,
    input           WB_RegWrite_out,
    output  reg [1:0]   out_ForwardA,
    output  reg [1:0]   out_ForwardB
);

    always @* begin
        if(EX_RegWrite_out && EX_rd_out != 0 && EX_rd_out == in_rs1) begin
            out_ForwardA = 2'b10;
        end
        else if(MEM_RegWrite_out && MEM_rd_out != 0 && MEM_rd_out == in_rs1) begin
            out_ForwardA = 2'b01;
        end
        else if(WB_RegWrite_out && WB_rd_out != 0 && WB_rd_out == in_rs1) begin
            out_ForwardA = 2'b11;
        end
        else begin
            out_ForwardA = 2'b00;
        end
    end
    
    always @* begin
        if(EX_RegWrite_out && EX_rd_out != 0 && EX_rd_out == in_rs2) begin
            out_ForwardB = 2'b10;
        end
        else if(MEM_RegWrite_out && MEM_rd_out != 0 && MEM_rd_out == in_rs2) begin
            out_ForwardB = 2'b01;
        end
        else if(WB_RegWrite_out && WB_rd_out != 0 && WB_rd_out == in_rs2) begin
            out_ForwardB = 2'b11;
        end
        else begin
            out_ForwardB = 2'b00;
        end
    end
        
endmodule