`define HalfClockPeriod     1000000
module KeyDebouncer(
	input			sys_clk, // UART: 100MHz
	input           cpu_clk, // CPU: clk 
	input			rst_n,
	input			but_in,
	output	reg 	but_posedge,
	output	reg 	but_negedge,
	output	reg 	but_active
);

    reg		[19:0]	cnt;
    reg     slow_clk;
    always @(posedge sys_clk or negedge rst_n) begin
        if(~rst_n) begin
            cnt <= 20'b0;
            slow_clk <= 1'b0;
        end
        else if (cnt == `HalfClockPeriod - 1) begin
            cnt <= 20'b0;
            slow_clk <= ~slow_clk;
        end
        else begin
            cnt <= cnt + 1;
            slow_clk <= slow_clk;
        end
    end

	// The smallest unit (1 key) of key debouncer
	// inputs:
	// - slow_clk: slow clock
	// - rst_n: reset signal
	// - but_in: input button signal
	// outputs:
	// - but_posedge: whether the button is pressed in this cycle
	// - but_negedge: whether the button is released in this cycle
	// - but_active: whether the button is pressed during the last cycle
	reg prev, cur;
	// prev: the button state in the last cycle
	// cur: the button state in this cycle
	always @(posedge slow_clk or negedge rst_n) begin
		if(~rst_n) begin
			prev <= 1'b0;
			cur  <= 1'b0;
			but_active <= 1'b0;
		end
		else begin
			{prev, cur, but_active} <= {cur, but_in, but_in};
		end
	end
    wire but_posedge_slow;
    wire but_negedge_slow;
	assign but_posedge_slow = (~prev) & cur;
	// posedge = (last == 0) &&	(cur == 1)
	assign but_negedge_slow = prev & (~cur);
	// negedge = (last == 1) && (cur == 0)
	
	reg prev_posedge_slow;
	reg prev_negedge_slow; 
	always @(posedge cpu_clk or negedge rst_n) begin
	    if (~rst_n) begin
	        prev_posedge_slow <= 1'b0;
	        prev_negedge_slow <= 1'b0;
	        but_posedge <= 1'b0;
	        but_negedge <= 1'b0;
	    end
	    else begin
	        {prev_posedge_slow, but_posedge} <= {but_posedge_slow, (~prev_posedge_slow) & but_posedge_slow};
	        {prev_negedge_slow, but_negedge} <= {but_negedge_slow, (~prev_negedge_slow) & but_negedge_slow};
	    end
    end
endmodule