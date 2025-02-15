module clk_rst_gen(
										output reg sys_clk,
										output reg sys_resetn
									);
	//Clock gen
	initial begin
		sys_clk= 1'b0;
		#10;
		forever begin
			#10;
			sys_clk= ~sys_clk;
		end
	end

	initial begin
		sys_resetn= 1'b1;
		#20;
		$display("At %0t, Assert reset signal", $time);
		sys_resetn= 1'b0;
		#20;
		sys_resetn= 1'b1;
		$display("At %0t, De-assert reset signal", $time);
	end

endmodule





