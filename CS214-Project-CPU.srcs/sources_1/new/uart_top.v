module uart_top (
    input           clk,
    input           rst_n,
    input           uart_rcv,
    input   [31:0]  uart_output,
    input           uart_output_ready,

    output          uart_snd,
    output  [31:0]  uart_input,
    output          uart_input_ready
);

endmodule