module timer_counter(
											input  			 pclk,
											input  			 presetn,

											input  			 clk_int,
											
											input  			 en,
											input  			 load,
											input  [7:0] ld_val,
											input  			 dw,

											output [7:0] cnt_out

											
										);
	reg [7:0] count;
	reg last_clk_int;
	wire pos_clk_int;

	//Rising edge detector
	always @(posedge pclk, negedge presetn) begin
		if (~presetn) begin
			last_clk_int <= 1'b0;
		end
		else begin
			last_clk_int <= clk_int;
		end
	end

	assign pos_clk_int = ~last_clk_int & clk_int;

	//Counter
	always @(posedge pclk, negedge presetn) begin
		if (~presetn) begin
			count <= 8'd0;
		end
		else begin
			if (load) begin
				count <= ld_val;
			end
			else begin
				if (~en) begin
					count <= count;
				end
				else begin
					if (~pos_clk_int) begin
						count <= count;
					end
					else begin
						if (~dw) begin
							count <= count + 1;
						end
						else begin
							count <= count - 1;
						end
					end
				end
			end
		end
	end
	assign cnt_out = count;

endmodule
