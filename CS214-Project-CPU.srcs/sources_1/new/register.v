module register(
    input               clk,
    input               rst_n,
    input               regWrite,
//  input               isFloat,
    input       [4:0]   readReg1,
    input       [4:0]   readReg2,
    input       [4:0]   writeReg,
    input       [31:0]  writeData,
    input               stall,
    output  reg [31:0]  readData1,
    output  reg [31:0]  readData2,
    output      [31:0]  real_time_a0
);
    
    reg     [31:0]  x[31:0];
    // For integer registers
    // x0 zero zero constant
    // x1 ra return address
    // x2 sp stack pointer
    // x3 gp global pointer
    // x4 tp thread pointer
    // x5-x7 t0-t2 temporaries
    // x8 s0/fp saved/frame pointer
    // x9 s1 saved register
    // x10-x11 a0-a1 Fn args/return values
    // x12-17 a2-a7 Fn args
    // x18-x27 s2-s11 saved registers
    // x28-x31 t3-t6 temporaries
    
    integer i;
    always @(posedge clk or negedge rst_n) begin // Because the regWrite signal, writeReg signal and readReg signals are updated at posedge. 
        if(~rst_n) begin
            // if(isFloat) begin
            //     for(i = 0; i < 31; i = i + 1) begin
            //         x[i] <= 0;
            //     end
            // end
            // else begin
            for(i = 0; i < 31; i = i + 1) begin
                case (i)
                    2: x[i] <= 32'h00000020;  // sp: 0x7fffeffc
                    3: x[i] <= 32'h10008000;  // gp
                    default: x[i] <= 32'h00000000;
                endcase
            end
            // end
        end
        else begin
            if(regWrite) begin
                x[writeReg] <= writeData;
            end
            else begin
                for(i = 0; i < 31; i = i + 1) begin
                    case (i)
                        0: x[i] <= 32'h00000000;
                    default: x[i] <= x[i];
                    endcase
                end
            end
        end
    end 
    
    always @(negedge clk) begin
        readData1 <= stall ? readData1 : x[readReg1];
        readData2 <= stall ? readData2 : x[readReg2];
        // real_time_a0 <= stall ? real_time_a0 : x[10];
        // real_time_a0 <= x[10];
    end

    assign real_time_a0 = x[10];
endmodule
