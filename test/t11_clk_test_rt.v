`include "define.v"
module t11_clk_test_rt();

	tb top();
	
	initial begin
		top.fail_flag = 1'b0;
		#200;
		$display("===============================================");
		$display("============== CLOCK TEST BEGIN ===============");
		$display("===============================================\n");
		clock_test(2'dx);
		top.fail_flag = 1'b0;
		clock_test(`CLK_2);
		clock_test(`CLK_4);
		clock_test(`CLK_8);
		clock_test(`CLK_16);
	
		top.test_end();

	end
	
	task clock_test(input [1:0] clk_sel);
		integer		exp_period, period;
		integer	  clock_index;
		integer 	time1, time2;
		reg	   [7:0] wdata;
		reg 			start, stop;
		reg				rising_edge_detected;

		begin
			stop = 1'b0;
			start = 1'b0;
			rising_edge_detected = 1'b0;
			time1 = $realtime;
			time2 = $realtime;

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

			exp_period = clock_index * `PCLK_PERIOD;

			//config counter
			$display("--------------------------------------------------------");
			$display("\nAt time %0d Clock Clk_%0d is testing", $time, clock_index);
			wdata [7:2] = 6'd0;
			wdata [1:0] = clk_sel;
			top.CPU.write_data(`TCR, wdata);
			#100;
			
			repeat (20) begin
				@(posedge top.pclk);

				if (stop != 1'b1) begin
					start = 1;
				end
				else begin
					start = 0;
				end
				if (rising_edge_detected != 1'b1) begin
						rising_edge_detected = top.DUT.counter.pos_clk_int;
				end
				else
					if ((start == 1) && (rising_edge_detected == 1'b1)) begin
						@(posedge top.DUT.clk_cnt);
						$display("At %0d first posedge of clk_%0d detected", $time, clock_index);
						time1 = $realtime;
						repeat (20) @(posedge top.DUT.clk_cnt);
						time2 = $realtime;
						$display("At %0d last posedge of clk_%0d detected", $time, clock_index);
						
						stop = 1;
					end
			end//repeat
			period = (time2 - time1)/20;
			if (period == 0) begin
				$display("At time %0d clk_%0d is not working --FAIL--", $time, clock_index);
				top.fail_flag = 1'b1;
			end

			else if (period == exp_period) begin
				$display("At time %0d select clk_%0d, period %0d ns, expected %0d ns --PASS--", $time, clock_index, period, exp_period);
			end
			else begin
				$display("At time %0d select clk_%0d, period %0d ns, expected %0d ns --FAIL--", $time, clock_index, period, exp_period);
				top.fail_flag = 1'b1;

			end

		end
	endtask


endmodule
