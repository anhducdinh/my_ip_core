module tb_counter();
	wire 			 clk;
	wire			 rstn;
	wire [7:0] cnt_out;
	wire			 cnt_clk;

	reg				 en, load, dw;
	reg	 [1:0] sel;
	reg  [7:0] ld_val;

	clk_rst_gen clk_rst_gen_inst(
		.sys_clk		(clk),
		.sys_resetn	(rstn)
															);
	clk_sel clk_int_inst(
		.pclk			(clk),
		.presetn	(rstn),
		.sel			(sel),
		.clk_out	(cnt_clk)
											);

	timer_counter DUT(
		.pclk			(clk),
    .presetn  (rstn),
            
    .clk_int	(cnt_clk),
            
    .en				(en),
    .load			(load),
    .ld_val		(ld_val),
    .dw				(dw),
            
    .cnt_out	(cnt_out)
									 );

	initial begin

		sel   = 2'b00;
		en 		= 1'b0;
		load 	= 1'b0;
		dw 		= 1'b0;
		ld_val= 8'd0;
		#50;
		
		sel   = 2'b00;
		en 		= 1'b1;
		load 	= 1'b0;
		dw 		= 1'b0;

		$display("At time 0%t,TIMER COUNTER is counting up", $time);
		#400;

		ld_val = 8'h50;
		load = 1'b1;
		$display("At time 0%t,TIMER COUNTER is loading new value", $time);
		#100;

		$display("At time 0%t,TIMER COUNTER is counting down", $time);
		load 	= 1'b0;
		dw 		= 1'b1;
		#400;
		$stop();

	end

endmodule
