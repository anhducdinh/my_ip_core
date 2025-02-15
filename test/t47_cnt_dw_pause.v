`include "define.v"
module t47_cnt_dw_pause();
	tb top();

	reg	[7:0]	address, rdata, wdata;

	initial begin
		#200;
		top.fail_flag = 1'b0;
		//Test info
		$display("==================================================");
		$display("============== COUNT DW WITH PAUSE  ==============");
		$display("==================================================");
		
		testcase();

		top.test_end();
	end
	
	task testcase();
		reg [7:0]		pause_after_n_cycles, remaining_cycles;
		begin
			//STEP1
			//TIMER CONFIGURATION
			$display("\n------------------------------------------------");
			$display("STEP1: TIMER CONFIGRUATION");
			pause_after_n_cycles = $random();
			remaining_cycles = 256 - pause_after_n_cycles;
			$display ("At time %0d, pause_after_n_cycles is %0d", $time, pause_after_n_cycles);
			$display ("At time %0d, write TCR to start timer with clk2", $time);
			top.CPU.write_data(`TCR, 8'h30);

			//STEP 2
			$display("------------------------------------");
			$display("STEP 2: Pause timer after %0d cycles", pause_after_n_cycles);
			$display("At time %0d, wait for %0d cycles", $time, pause_after_n_cycles);
			repeat (pause_after_n_cycles * `PER_CLK_2) @(posedge top.pclk);
			$display ("At time %0d, write TCR to pause timer", $time);	
			top.CPU.write_data(`TCR, 8'h00);
			#200;
			$display("At time %0d, write TCR to start timer again", $time);
			top.CPU.write_data(`TCR, 8'h30);
			
			//STEP 3
			$display("------------------------------------");
			$display("STEP 3: Wait for timer to finish counting");
			$display("At time %0d, wait for %0d cycles", $time, remaining_cycles);
			repeat (remaining_cycles * `PER_CLK_2) @(posedge top.pclk);

			//STEP 4
			$display("------------------------------------");
			$display("STEP 4: Check TSR");
			$display("At time %0d, after %0d clk_int, read TSR", $time, remaining_cycles);
			top.CPU.read_data(`TSR, rdata);

			if (rdata == 8'h02) begin
				$display("At time %0d, TSR = 8'h%0h, UNDERFLOW --PASS--", $time, rdata);
			end
			else begin
				$display("At time %0d, TSR = 8'h%0h, NOT UNDERFLOW --FAIL--", $time, rdata);
				top.fail_flag = 1'b1;
			end

			//STEP 5
			$display("\n-------------------------------------------------");
			$display("STEP 5: CLEAR TSR AND DOUBLE CHECK TSR");
			$display("At time %0d, clear TSR", $time);
			top.CPU.write_data(`TSR, 8'h00);

			$display("At time %0d, read TSR", $time);
			top.CPU.read_data(`TSR, rdata);

			if (rdata == 8'h00) begin
				$display("At time %0d, TSR = 8'h%0h", $time, rdata);
				$display("BIT UNDERFLOW CLEARED --PASS--");
			end
			else begin
				$display("At time %0d, TSR = 8'h%0h", $time, rdata);
				$display("BIT UNDERFLOW NOT CLEARED --FAIL--");
				top.fail_flag = 1'b1;
			end
		end
	endtask

endmodule
