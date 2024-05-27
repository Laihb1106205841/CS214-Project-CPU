
module cpu_top(
    input                   fpga_clk,
    input                   fpga_rst_n,
    input       [7:0]       sw_l,
    input       [7:0]       sw_r,
    input                   but_center,
    output      [7:0]       led_l,
    output      [7:0]       led_r,
    output		[7:0]	    tub_sel,
    output      [7:0]       tub_data1,
    output      [7:0]       tub_data2,
    
    // Uart Communicate
    input                   start_pg,
    input                   upg_rst_raw,
    input                   uart_rx,
    output                  uart_tx
);

    // Wire Connection between Modules
    reg                         clk;
    wire                        clk_5;
    reg     [23:0]              cnt;  // test
    wire                        tub_clk;
    wire                        PCSrc;
    wire    [31:0]              PC_imm;
    wire    [31:0]              PC_imm_ex;
    wire    [31:0]              instruction_if;
    wire    [31:0]              instruction_id;
    wire                        RegWrite_wb;
    wire    [4:0]               rd_id;
    wire    [4:0]               rd_ex;
    wire    [4:0]               rd_mem;
    wire    [4:0]               rd_wb;
    wire    [31:0]              WriteData_wb;
    wire                        Branch_id;
    wire                        Branch_ex;
    wire                        MemRead_id;
    wire                        MemRead_ex;
    wire                        MemtoReg_id;
    wire                        MemtoReg_ex;
    wire                        MemtoReg_mem;
    wire    [1:0]               ALUOp_id;
    wire                        MemWrite_id;
    wire                        MemWrite_ex;
    wire                        RegWrite_id;
    wire                        RegWrite_ex;
    wire                        RegWrite_mem;
    wire                        ALUSrc_1_id;
    wire                        ALUSrc_2_id;
    wire    [31:0]              ReadData1_id;
    wire    [31:0]              ReadData2_id;
    wire    [31:0]              ReadData_mem;
    wire    [31:0]              ALUResult_ex;
    wire    [31:0]              ALUResult_mem;
    wire    [31:0]              Imm_id;
    wire    [6:0]               funct7_id;
    wire    [2:0]               funct3_id;
    wire                        Zero_ex;
    wire    [4:0]               rs1_id;
    wire    [4:0]               rs2_id;
    wire    [4:0]               rs1_ex;
    wire    [4:0]               rs2_ex;
    wire    [1:0]               forward_a;
    wire    [1:0]               forward_b;
    reg     [31:0]              uart_input_raw;
    wire    [31:0]              uart_input;
    wire                        uart_input_ready;
    wire    [31:0]              uart_output;
    wire                        uart_output_ready;
    wire                        stall;
    wire    [31:0]              PC_if;
    wire                        PCSrc_id;
    wire                        uFlag_id;
    wire    [31:0]              PC_id;
    wire    [3:0]               ecall_a7_id;
    wire    [3:0]               ecall_a7_ex;
    wire    [3:0]               ecall_a7_mem;
    wire    [31:0]              ReadData2_ex;
    wire                        ecall_10_wb;
    wire                        flush_ex;
    wire    [3:0]               test_case;
    
       // UART Programmer Pinouts
    wire                        upg_clk, upg_clk_o;
    wire                        upg_wen_o;
    wire                        upg_done_o;
    
    // Data to which memory unit of program_rom/dmemory32
    wire    [14:0]              upg_adr_o; // The first bits which memory unit the data is transmitted to.
    wire    [31:0]              upg_dat_o;

    // generate slow clock
    clk_wiz clk_wiz_inst(
        .clk_in1(fpga_clk),
        .resetn(fpga_rst_n),
        .clk_out1(clk_5),
        .clk_out2(tub_clk),
        .clk_out3(upg_clk)
    );
    
    // Used to modify the speed of the clock for debugging.
    always @(posedge clk_5) begin
        cnt <= cnt + 1;
        clk <= cnt[5];
    end


    //-----------------Key Debouncer-----------------//
    wire                        but_posedge; // Pressed
    wire                        but_negedge; // Released
    wire                        but_active; // Push
    KeyDebouncer u_but(
        .sys_clk            (tub_clk),
        .cpu_clk            (clk),
        .rst_n              (fpga_rst_n),
        .but_in             (but_center),
        .but_posedge        (but_posedge),
        .but_negedge        (but_negedge),
        .but_active         (but_active)
    );
    
    wire                upg_rst, upg_rst_neg, upg_rst_active;
    KeyDebouncer uart_rst_but(
        .sys_clk            (tub_clk),
        .cpu_clk            (clk),
        .rst_n              (fpga_rst_n),
        .but_in             (upg_rst_raw),
        .but_posedge        (upg_rst),
        .but_negedge        (upg_rst_neg),
        .but_active         (upg_rst_active)
    );
    
    // Uart Module 
    uart_bmpg_0 lut(
        .upg_clk_i          (upg_clk),
        .upg_rst_i          (upg_rst),
        .upg_rx_i           (uart_rx),
        .upg_clk_o          (upg_clk_o),
        .upg_wen_o          (upg_wen_o),
        .upg_adr_o          (upg_adr_o),
        .upg_dat_o          (upg_dat_o),
        .upg_done_o         (upg_done_o),
        .upg_tx_o           (uart_tx)
     );
     
     reg    uartDoneInit;
     initial begin
        uartDoneInit = 1'b1;
     end
     always @(upg_done_o) begin
        uartDoneInit = upg_done_o;
     end
    
    //------------------Tub Display------------------//

    wire    tub_en = 1'b1;
    wire  [3:0]   number_7, number_6, number_5, number_4, number_3, number_2, number_1, number_0;
    TubDisplay TubDisplay_inst(
        // Tub Display Input
        .sys_clk      (tub_clk   ),
        .rst_n        (fpga_rst_n),
        .data7        (number_7   ),
        .data6        (number_6   ),
        .data5        (number_5   ),
        .data4        (number_4   ),
        .data3        (number_3   ),
        .data2        (number_2   ),
        .data1        (number_1   ),
        .data0        (number_0   ),
        .en           (tub_en     ),
        // Tub Display Output
        .tub_sel      (tub_sel    ),
        .tub_data1    (tub_data1  ),
        .tub_data2    (tub_data2  )
    );
    
    // Only determine at each position which number should be displayed.
    wire  [11:0]   display_number_1;
    wire  [11:0]   display_number_2;
    wire  [11:0]   display_number_3;
    wire  [11:0]   display_number_4;
    wire  [11:0]   display_number;
    wire  [31:0]   operand1;
    wire  [31:0]   operand2;
    wire  [31:0]   SubResult;
    wire  [31:0]   real_time_a3;
    
    assign display_number_1 = PC_if[11:0];
    assign number_7 = display_number_1 / 10;
    assign number_6 = display_number_1 - number_7 * 10;
    assign number_5 = uart_output[23:20];
    assign number_4 = uart_output[19:16];
    assign number_3 = uart_output[15:12];
    assign number_2 = uart_output[11:8];
    assign number_1 = uart_output[7:4];
    assign number_0 = uart_output[3:0];

    assign led_l[7] = stall;
    assign led_l[6] = uart_output_ready;
    assign led_l[5:4] = {ALUSrc_2_id, ALUSrc_1_id};
    assign led_l[3] = RegWrite_mem;
    assign led_l[2] = RegWrite_wb;
    
    assign led_l[1:0] = {Branch_ex, Zero_ex};
    wire    [6:0]   addr;
    // assign led_r[7] = upg_done_o;
    assign led_r[6] = ecall_10_wb;
    assign led_r[3:0] = {forward_a, forward_b};

    //------------------UART------------------//
    always @* begin
        case(test_case)
            4'b1001, 4'b1010, 4'b1011: uart_input_raw = {16'b0, sw_r[6], sw_l[7:0], 7'b0};
            4'b1101: uart_input_raw = {20'b0, sw_l[7:6], sw_l[5:2], sw_l[5:2], sw_l[1:0]};
            default: uart_input_raw = {24'b0, sw_l[7:0]};
        endcase
    end
    assign uart_input_ready = but_posedge;  
    assign test_case = sw_r[3:0];
    
    fcvt fcvt_inst(
        .uart_input(uart_input_raw),
        .test_case(test_case),
        .real_input(uart_input)
    );

    // Uart
    // uart_top uart_top_inst(
    //     .clk                    (clk),
    //     .rst_n                  (rst_n),
    //     .uart_rcv               (uart_rcv),  // one bit signal, computer -> FPGA
    //     .uart_output            (uart_output),  // [31:0], FPGA -> computer
    //     .uart_output_ready      (uart_output_ready),

    //     .uart_snd               (uart_snd),  // one bit signal, FPGA -> computer
    //     .uart_input             (uart_input),  // [31:0], computer -> FPGA
    //     .uart_input_ready       (uart_input_ready)
    // );


    // Ifetch
    // - Instruct_urom
    ifetch ifetch_inst(
        .clk                    (clk),
        .rst_n                  (fpga_rst_n),
        .in_PCSrc               (flush_ex),
        .in_testcase            (test_case),  // [3:0]
        .in_PC_imm              (PC_imm_ex),  // [31:0]
        .stall                  (stall),
        .out_instruction        (instruction_if),  // [31:0]
        .out_PC                 (PC_if),  // [31:0]
        
        .upg_rst_i              (upg_rst), // Active High Reset Signal
        .upg_clk_i              (upg_clk_o),
        .upg_wen_i              (upg_wen_o & !upg_adr_o[14]), // Write Enable
        .upg_adr_i              (upg_adr_o[13:0]),
        .upg_dat_i              (upg_dat_o),
        .upg_done_i             (start_pg)
    );

    // Idecode
    // - Control
    // - Register
    idecode idecode_inst(
        .clk                    (clk),
        .rst_n                  (fpga_rst_n),
        .in_RegWrite            (RegWrite_wb),
        .in_rd                  (rd_wb),  // [4:0]
        .in_WriteData           (WriteData_wb),  // [31:0]
        .in_instruction         (instruction_if),  // [31:0]
        .in_PC                  (PC_if),  // [31:0]
        .in_ecall_10            (ecall_10_wb),
        .in_flush               (flush_ex),
        .uart_input_ready       (uart_input_ready),
        .uart_input             (uart_input),  // [31:0]
    
        // Control Output
        .out_Branch             (Branch_id),
        .out_MemRead            (MemRead_id),
        .out_MemtoReg           (MemtoReg_id),
        .out_ALUOp              (ALUOp_id),
        .out_MemWrite           (MemWrite_id),
        .out_ALUSrc_1           (ALUSrc_1_id),
        .out_ALUSrc_2           (ALUSrc_2_id),
        .out_RegWrite           (RegWrite_id),
        .out_PCSrc              (PCSrc_id),
        .out_uFlag              (uFlag_id),
    
        // Register Output
        .out_ReadData1          (ReadData1_id),  // [31:0]
        .out_ReadData2          (ReadData2_id),  // [31:0]
        .uart_output            (uart_output),  // [31:0]
    
        // Other Input/Output
        .out_PC                 (PC_id),  // [31:0]
        .out_imm                (Imm_id),  // [31:0]
        .out_funct7             (funct7_id),  // [6:0]
        .out_funct3             (funct3_id),  // [2:0]
        .out_rd                 (rd_id),   // [4:0]
        .out_instruction        (instruction_id),
        .out_rs1                (rs1_id),  // [4:0]
        .out_rs2                (rs2_id),  // [4:0]
        .out_ecall_a7           (ecall_a7_id),  // [3:0]
        .stall                  (stall),
        .real_time_a3           (real_time_a3)
    );
    
    // Exe
    exe exe_inst(
        .clk                    (clk),
        .rst_n                  (fpga_rst_n),
    
        .in_RegWrite            (RegWrite_id),
        .in_MemtoReg            (MemtoReg_id),
        .in_Branch              (Branch_id),
        .in_MemRead             (MemRead_id),
        .in_MemWrite            (MemWrite_id),     
        .in_ALUOp               (ALUOp_id),  // [1:0] 
        .in_ALUSrc_1            (ALUSrc_1_id),
        .in_ALUSrc_2            (ALUSrc_2_id),
        .in_PCSrc               (PCSrc_id),
        .in_uFlag               (uFlag_id),

        .in_PC                  (PC_id),  // [31:0]
        .in_ReadData1           (ReadData1_id),  // [31:0]
        .in_ReadData2           (ReadData2_id),  // [31:0]
        .in_Imm                 (Imm_id),  // [31:0]
        .in_funct7              (funct7_id),  // [6:0] 
        .in_funct3              (funct3_id),  // [2:0] 
        .in_rd                  (rd_id),  // [4:0] 
        .in_rs1                 (rs1_id),  // [4:0]
        .in_rs2                 (rs2_id),  // [4:0]       
        
        // Forward Inpu
        .in_ForwardA            (forward_a),  // [1:0] 
        .in_ForwardB            (forward_b),  // [1:0] 
        .in_ReadData            ((MemtoReg_mem) ? ReadData_mem : ALUResult_mem),  // [31:0] Forward from MEM
        .in_WriteData           (WriteData_wb), // [31:0] Forward from WB
        .in_ALUResult           (ALUResult_ex),  // [31:0] Forward from EXE

        .in_ecall_a7            (ecall_a7_id),  // [3:0]
        .stall                  (stall),
        .flush                  (flush_ex),

        .out_MemtoReg           (MemtoReg_ex),
        .out_RegWrite           (RegWrite_ex),
        .out_Branch             (Branch_ex),
        .out_MemRead            (MemRead_ex),
        .out_MemWrite           (MemWrite_ex),
        .out_PC_imm             (PC_imm_ex),  // [31:0]
        .out_Zero               (Zero_ex),
        .out_ALUResult          (ALUResult_ex),  // [31:0]
        .out_ReadData2          (ReadData2_ex),  // [31:0]
        .out_rd                 (rd_ex),  // [4:0] 
        .out_rs1                (rs1_ex),  // [4:0]
        .out_rs2                (rs2_ex),  // [4:0]
        .out_ecall_a7           (ecall_a7_ex),  // [3:0]
        .operand1               (operand1),
        .operand2               (operand2),
        .SubResult              (SubResult)
    );

    // Dmem
    // - Dmem_uram
    dmem dmem_inst(
        .clk                    (clk),      
        .rst_n                  (fpga_rst_n), 
             
        .in_RegWrite            (RegWrite_ex),     
        .in_MemtoReg            (MemtoReg_ex),     
        .in_MemRead             (MemRead_ex),     
        .in_MemWrite            (MemWrite_ex),     
        .in_Branch              (Branch_ex),   
        .in_Zero                (Zero_ex),      
        .in_PC_imm              (PC_imm_ex),  // [31:0]
        .in_ALUResult           (ALUResult_ex),  // [31:0]
        .in_WriteData           (ReadData2_ex),  // Use ReadData2 in ALU as input  // [31:0]
        .in_rd                  (rd_ex),  // [4:0]
        
        .stall                  (stall),
        .in_ecall_a7            (ecall_a7_ex),  // [3:0]
        .in_flush               (1'b0),
        // Output to IFETCH
        .out_PCSrc              (PCSrc),      
        .out_PC_imm             (PC_imm),  // [31:0]

        // Output to WriteBack
        .out_RegWrite           (RegWrite_mem),      
        .out_MemtoReg           (MemtoReg_mem),      
        .out_ReadData           (ReadData_mem),  // [31:0]
        .out_ALUResult          (ALUResult_mem),  // [31:0]

        // Other Outputs
        .out_rd                 (rd_mem),  // [4:0]
        .out_ecall_a7           (ecall_a7_mem),  // [3:0]
        .out_addr               (addr),
        
        .upg_rst_i              (upg_rst), // Active High Reset Signal
        .upg_clk_i              (upg_clk_o),
        .upg_wen_i              (upg_wen_o & upg_adr_o[14]), // Write Enable
        .upg_adr_i              (upg_adr_o[13:0]),
        .upg_dat_i              (upg_dat_o),
        .upg_done_i             (start_pg)
    );
    
    // Wback
    wback wback_inst(
        .clk                    (clk),
        .rst_n                  (fpga_rst_n),
        
        .in_RegWrite            (RegWrite_mem),
        .in_MemtoReg            (MemtoReg_mem),
        .in_ReadData            (ReadData_mem),  // [31:0] 
        .in_ALUResult           (ALUResult_mem),  // [31:0]
        .in_WriteReg            (rd_mem),  // [4:0]
        .stall                  (stall),
        .in_ecall_a7            (ecall_a7_mem),  // [3:0]
    
        .out_RegWrite           (RegWrite_wb),
        .out_WriteData          (WriteData_wb),  // [31:0]
        .out_WriteReg           (rd_wb),  // [4:0]
        .uart_output_ready      (uart_output_ready),
        .out_ecall_10           (ecall_10_wb)
    );

    // Forward
    fwd fwd_inst(
        .in_rs1                 (rs1_id),  // [4:0]   
        .in_rs2                 (rs2_id),  // [4:0]   
        .EX_rd_out              (rd_ex),  // [4:0]  Input 
        .EX_RegWrite_out        (RegWrite_ex),//       Input
        .MEM_rd_out             (rd_mem),  // [4:0]  Input 
        .MEM_RegWrite_out       (RegWrite_mem),//       Input
        .WB_rd_out              (rd_wb),
        .WB_RegWrite_out        (RegWrite_wb),
        .out_ForwardA           (forward_a),  // [1:0]
        .out_ForwardB           (forward_b)  // [1:0]
    );
endmodule
