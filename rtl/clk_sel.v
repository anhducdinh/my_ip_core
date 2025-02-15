module clk_sel(
									input pclk,
									input presetn,
									input [1:0] sel,

									output reg clk_out
								);
	reg 	q1, q2, q3, q4;
	wire 	clk_div_2, clk_div_4, clk_div_8, clk_div_16;

	//----------------------------------
	// CLK GENERATOR
	//----------------------------------

	// clk_div_2
	always @(posedge pclk, negedge presetn) begin
		if (~presetn)
			q1 <= 1'b0;
		else
			q1 <= ~q1;
	end

	// clk_div_4
	always @(posedge clk_div_2, negedge presetn) begin
		if (~presetn)
			q2 <= 1'b0;
		else
			q2 <= ~q2;
	end

	// clk_div_8
	always @(posedge clk_div_4, negedge presetn) begin
		if (~presetn)
			q3 <= 1'b0;
		else
			q3 <= ~q3;
	end

	// clk_div_16
	always @(posedge clk_div_8, negedge presetn) begin
		if (~presetn)
			q4 <= 1'b0;
		else
			q4 <= ~q4;
	end

	assign clk_div_2 = ~q1;
	assign clk_div_4 = ~q2;
	assign clk_div_8 = ~q3;
	assign clk_div_16= ~q4;

	//-------------------------------
	// CLK SEL
	//-------------------------------
	always @(clk_div_2, clk_div_4, clk_div_8, clk_div_16) begin
		case (sel)
			2'b00:      clk_out = clk_div_2;
			2'b01:      clk_out = clk_div_4;
			2'b10:      clk_out = clk_div_8;
			2'b11:      clk_out = clk_div_16;
		    default:    clk_out = 1'bX;
		endcase
	end

endmodule
