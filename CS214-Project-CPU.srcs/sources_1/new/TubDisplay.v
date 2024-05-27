`include "TubParams.v"
module TubDisplay #(
	parameter 		IMM_LEN = 4,
	parameter		NUM_TUBS = 8,
	parameter		NUM_DIGITS = 8
) (
	input								sys_clk,
	input								rst_n,
	input		[(IMM_LEN - 1):0]		data7,
	input		[(IMM_LEN - 1):0]		data6,
	input		[(IMM_LEN - 1):0]		data5,
	input		[(IMM_LEN - 1):0]		data4,
	input		[(IMM_LEN - 1):0]		data3,
	input		[(IMM_LEN - 1):0]		data2,
	input		[(IMM_LEN - 1):0]		data1,
	input		[(IMM_LEN - 1):0]		data0,
	input								en,
	output	reg [(NUM_DIGITS - 1):0]	tub_sel,
	output	reg [(NUM_TUBS - 1):0]		tub_data1,
	output	reg [(NUM_TUBS - 1):0]		tub_data2
);
	// module for displaying info on 7-segment tubes
	// inputs:
	// - sys_clk: system clock
	// - rst_n: reset signal
	// - data7 to data0: expected data to be displayed
	// - en: enable signal (when en = 0, the display is turned off)
	// outputs:
	// - tub_sel: selection signal for the 7-segment tubes
	// - tub_data1: data to be displayed on the left 4 tubes
	// - tub_data2: data to be displayed on the right 4 tubes

	initial begin
		tub_sel = 8'h01;
		tub_data1 = 0;
		tub_data2 = 0;
	end

	reg    [(NUM_TUBS - 1):0]  tub_in7, tub_in6, tub_in5, tub_in4, tub_in3, tub_in2, tub_in1, tub_in0;
	always @(posedge sys_clk or negedge rst_n) begin
        if (~rst_n) begin
            tub_in7 <= `tub_nil;
			tub_in6 <= `tub_nil;
			tub_in5 <= `tub_nil;
			tub_in4 <= `tub_nil;
			tub_in3 <= `tub_nil;
			tub_in2 <= `tub_nil;
			tub_in1 <= `tub_nil;
			tub_in0 <= `tub_nil;
		end
        // Use tub to display number inputs from switches.
        else begin
            case (data7)
                0: tub_in7 <= `tub_0;
                1: tub_in7 <= `tub_1;
                2: tub_in7 <= `tub_2;
                3: tub_in7 <= `tub_3;
                4: tub_in7 <= `tub_4;
                5: tub_in7 <= `tub_5;
                6: tub_in7 <= `tub_6;
                7: tub_in7 <= `tub_7;
                8: tub_in7 <= `tub_8;
                9: tub_in7 <= `tub_9;
				10: tub_in7 <= `tub_A;
				11: tub_in7 <= `tub_B;
				12: tub_in7 <= `tub_C;
				13: tub_in7 <= `tub_D;
				14: tub_in7 <= `tub_E;
				15: tub_in7 <= `tub_F;
                default: tub_in7 <= `tub_nil;
            endcase
            case (data6)
                0: tub_in6 <= `tub_0;
                1: tub_in6 <= `tub_1;
                2: tub_in6 <= `tub_2;
                3: tub_in6 <= `tub_3;
                4: tub_in6 <= `tub_4;
                5: tub_in6 <= `tub_5;
                6: tub_in6 <= `tub_6;
                7: tub_in6 <= `tub_7;
                8: tub_in6 <= `tub_8;
                9: tub_in6 <= `tub_9;
				10: tub_in6 <= `tub_A;
				11: tub_in6 <= `tub_B;
				12: tub_in6 <= `tub_C;
				13: tub_in6 <= `tub_D;
				14: tub_in6 <= `tub_E;
				15: tub_in6 <= `tub_F;
                default: tub_in6 <= `tub_nil;
            endcase
            case (data5)
                0: tub_in5 <= `tub_0;
                1: tub_in5 <= `tub_1;
                2: tub_in5 <= `tub_2;
                3: tub_in5 <= `tub_3;
                4: tub_in5 <= `tub_4;
                5: tub_in5 <= `tub_5;
                6: tub_in5 <= `tub_6;
                7: tub_in5 <= `tub_7;
                8: tub_in5 <= `tub_8;
                9: tub_in5 <= `tub_9;
				10: tub_in5 <= `tub_A;
				11: tub_in5 <= `tub_B;
				12: tub_in5 <= `tub_C;
				13: tub_in5 <= `tub_D;
				14: tub_in5 <= `tub_E;
				15: tub_in5 <= `tub_F;
                default: tub_in5 <= `tub_nil;
            endcase
            case (data4)
                0: tub_in4 <= `tub_0;
                1: tub_in4 <= `tub_1;
                2: tub_in4 <= `tub_2;
                3: tub_in4 <= `tub_3;
                4: tub_in4 <= `tub_4;
                5: tub_in4 <= `tub_5;
                6: tub_in4 <= `tub_6;
                7: tub_in4 <= `tub_7;
                8: tub_in4 <= `tub_8;
                9: tub_in4 <= `tub_9;
				10: tub_in4 <= `tub_A;
				11: tub_in4 <= `tub_B;
				12: tub_in4 <= `tub_C;
				13: tub_in4 <= `tub_D;
				14: tub_in4 <= `tub_E;
				15: tub_in4 <= `tub_F;
                default: tub_in4 <= `tub_nil;
            endcase
            case (data3)
                0: tub_in3 <= `tub_0;
                1: tub_in3 <= `tub_1;
                2: tub_in3 <= `tub_2;
                3: tub_in3 <= `tub_3;
                4: tub_in3 <= `tub_4;
                5: tub_in3 <= `tub_5;
                6: tub_in3 <= `tub_6;
                7: tub_in3 <= `tub_7;
                8: tub_in3 <= `tub_8;
                9: tub_in3 <= `tub_9;
				10: tub_in3 <= `tub_A;
				11: tub_in3 <= `tub_B;
				12: tub_in3 <= `tub_C;
				13: tub_in3 <= `tub_D;
				14: tub_in3 <= `tub_E;
				15: tub_in3 <= `tub_F;
                default: tub_in3 <= `tub_nil;
            endcase
            case (data2)
                0: tub_in2 <= `tub_0;
                1: tub_in2 <= `tub_1;
                2: tub_in2 <= `tub_2;
                3: tub_in2 <= `tub_3;
                4: tub_in2 <= `tub_4;
                5: tub_in2 <= `tub_5;
                6: tub_in2 <= `tub_6;
                7: tub_in2 <= `tub_7;
                8: tub_in2 <= `tub_8;
                9: tub_in2 <= `tub_9;
				10: tub_in2 <= `tub_A;
				11: tub_in2 <= `tub_B;
				12: tub_in2 <= `tub_C;
				13: tub_in2 <= `tub_D;
				14: tub_in2 <= `tub_E;
				15: tub_in2 <= `tub_F;
                default: tub_in2 <= `tub_nil;
            endcase
            case (data1)
                0: tub_in1 <= `tub_0;
                1: tub_in1 <= `tub_1;
                2: tub_in1 <= `tub_2;
                3: tub_in1 <= `tub_3;
                4: tub_in1 <= `tub_4;
                5: tub_in1 <= `tub_5;
                6: tub_in1 <= `tub_6;
                7: tub_in1 <= `tub_7;
                8: tub_in1 <= `tub_8;
                9: tub_in1 <= `tub_9;
				10: tub_in1 <= `tub_A;
				11: tub_in1 <= `tub_B;
				12: tub_in1 <= `tub_C;
				13: tub_in1 <= `tub_D;
				14: tub_in1 <= `tub_E;
				15: tub_in1 <= `tub_F;
                default: tub_in1 <= `tub_nil;
            endcase
            case (data0)
                0: tub_in0 <= `tub_0;
                1: tub_in0 <= `tub_1;
                2: tub_in0 <= `tub_2;
                3: tub_in0 <= `tub_3;
                4: tub_in0 <= `tub_4;
                5: tub_in0 <= `tub_5;
                6: tub_in0 <= `tub_6;
                7: tub_in0 <= `tub_7;
                8: tub_in0 <= `tub_8;
                9: tub_in0 <= `tub_9;
				10: tub_in0 <= `tub_A;
				11: tub_in0 <= `tub_B;
				12: tub_in0 <= `tub_C;
				13: tub_in0 <= `tub_D;
				14: tub_in0 <= `tub_E;
				15: tub_in0 <= `tub_F;
                default: tub_in0 <= `tub_nil;
            endcase
        end
    end


	// to achieve a better display effect
	// we use a medium-speed clock of about 1500Hz here
	reg [15:0] cnt;
    always @(posedge sys_clk) begin
        cnt <= cnt + 1;
    end

    reg slow_clk;
    always @(posedge sys_clk) begin
        if (cnt == 0) begin
            slow_clk <= ~slow_clk;
        end
    end

	// determine which bit to display
	always @(posedge slow_clk or negedge rst_n) begin
		if (~rst_n)
			tub_sel <= 8'h01;
		else
			tub_sel <= {tub_sel[6:0], tub_sel[7]};
	end

	// determine what to display
	always @* begin
		if (~rst_n) begin
			tub_data1 = 0;
			tub_data2 = 0;
		end
		else begin
			case (tub_sel)
				8'h80: tub_data1 = tub_in7;
				8'h40: tub_data1 = tub_in6;
				8'h20: tub_data1 = tub_in5;
				8'h10: tub_data1 = tub_in4;
				8'h08: tub_data2 = tub_in3;
				8'h04: tub_data2 = tub_in2;
				8'h02: tub_data2 = tub_in1;
				default: tub_data2 = tub_in0;
			endcase
		end
	end
endmodule