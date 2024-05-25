module fwd (
    input   [4:0]   in_rs1,
    input   [4:0]   in_rs2,
    input   [4:0]   EX_rd_out,
    input           EX_RegWrite_out,
    input   [4:0]   MEM_rd_out,
    input           MEM_RegWrite_out,
    output  [1:0]   out_ForwardA,
    output  [1:0]   out_ForwardB
);
    assign out_ForwardA = {
        EX_RegWrite_out && EX_rd_out != 0 && EX_rd_out == in_rs1,
        MEM_RegWrite_out && MEM_rd_out != 0 && MEM_rd_out == in_rs1
    };
    assign out_ForwardB = {
        EX_RegWrite_out && EX_rd_out != 0 && EX_rd_out == in_rs2,
        MEM_RegWrite_out && MEM_rd_out != 0 && MEM_rd_out == in_rs2
    };
endmodule