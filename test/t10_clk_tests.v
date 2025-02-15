module t10_clk_test();
	
	tb top();
	
	`define		TCR			8'h01
	`define		CLK_2		2'b00
	`define		CLK_4		2'b01
	`define		CLK_8		2'b10
	`define		CLK_16	    2'b11

	integer		exp_period;
	integer	    clock_index;
	integer 	count;
	reg			count_en;
	reg [7:0] wdata;

	initial begin
		count_en = 1'b0;
		top.fail_flag = 1'b0;
		#200;
		$display("===============================================");
		$display("============== CLOCK TEST BEGIN ===============");
		$display("===============================================\n");
		clock_test(`CLK_2);
		clock_test(`CLK_4);
		clock_test(`CLK_8);
		clock_test(`CLK_16);
		#50;
		top.get_result();
		$finish();
	end

	task clock_test(input [1:0] clk_sel);
		begin
			case (clk_sel)
				`CLK_2:			clock_index = 2;
				`CLK_4:			clock_index = 4;	
				`CLK_8:			clock_index = 8;
				`CLK_16:		clock_index = 16;
				default:
					begin
						$display("Not any specified clock is testing");
						top.fail_flag = 1'b1;
					end
			endcase
			$display("--------------------------------------------------------");
			$display("\nAt time %0d Clock Clk_%0d is testing", $time, clock_index);
			wdata [7:2] = 6'd0;
			wdata [1:0] = clk_sel;
			top.CPU.write_data(`TCR, wdata);
			fork
				//thread 1
				begin
					@(posedge top.DUT.clk_cnt);
					$display("At %0d first posedge of clk_%0d detected", $time, clock_index);
					count_en = 1;
					@(posedge top.DUT.clk_cnt);
					$display("At %0d last posedge of clk_%0d detected", $time, clock_index);
					count_en = 0;
				end

				//thread 2
				begin
					count = 0;
					
					repeat (100) begin
						@(posedge top.pclk);
						if (count_en)
							count = count + 1;
						else
							count = count;
					end
				end
			join
			exp_period = clock_index;
			if (count == clock_index) begin
				$display("At time %0d select clk_%0d, period %0d cycles, expected %0d cycles --PASS--", $time, clock_index, count, exp_period);
			end
			else begin
				$display("At time %0d select clk_%0d, period %0d cycles, expected %0d cycles --FAIL--", $time, clock_index, count, exp_period);
				top.fail_flag = 1'b1;

			end
		end	

	endtask
endmodule
