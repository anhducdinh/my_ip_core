module tb_clk_sel();

	wire			clk;
	wire			rstn;
	reg [1:0] sel;
	wire			clk_out;

	clk_rst_gen clk_rst_gen_inst(
																.sys_clk (clk),
																.sys_resetn (rstn)
															);
	clk_sel DUT(
							.pclk (clk),
							.presetn (rstn),
							.sel (sel),
							.clk_out (clk_out)
						 );
	initial begin
		#50;
		sel = 2'b00;
		#800;
		sel = 2'b01;
		#800;
		sel = 2'b10;
		#800;
		sel = 2'b11;
		$stop();
	
	end


endmodule
