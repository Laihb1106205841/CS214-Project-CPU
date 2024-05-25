`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2024 06:40:33 AM
// Design Name: 
// Module Name: ifetch_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module iftech_tb();

    // Inputs
    reg clk;
    reg rst_n;
    reg in_PCSrc;
    reg [3:0] in_testcase;
    reg [31:0] in_PC_imm;
    reg [31:0] in_data;

    // Outputs
    wire [31:0] out_instruction;
    wire [31:0] PC;

    // Instantiate the Unit Under Test (UUT)
    ifetch uut (
        .clk(clk),
        .rst_n(rst_n),
        .in_PCSrc(in_PCSrc),
        .in_testcase(in_testcase),
        .in_PC_imm(in_PC_imm),
        .in_uart_flag(0),
        .in_uart_data(in_data),
        .out_instruction(out_instruction),
        .PC(PC)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        rst_n = 0;
        in_PCSrc = 0;
        in_testcase = 2;
        in_PC_imm = 0;
        in_data = 0;

        // Reset the system
        #3 rst_n = 1; // Release reset after 10ns

        // Test 2: Branch to in_PC_imm
        in_PCSrc = 1;
        in_PC_imm = 32'h00000004;
        #20;
        in_PCSrc = 0;
        
        // Test 3: Continue with normal increment
        #40;
        
        // Test 4: Another branch
        in_PCSrc = 1;
        in_PC_imm = 32'h00000008;
        #20;
        in_PCSrc = 0;

        // Test 5: Check normal increment again
        #40;

        // End simulation
        $stop;
    end

endmodule

