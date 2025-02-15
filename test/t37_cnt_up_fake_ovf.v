`include "define.v"
module t37_cnt_up_fake_ovf();

	tb top();

	reg	[7:0]	address, rdata, wdata;

	initial begin
		#200;
		top.fail_flag = 1'b0;
		//Test info
		$display("==================================================");
		$display("============== COUNT UP FAKE OVERFLOW  ===========");
		$display("==================================================");
		
		testcase();

		top.test_end();
	end//initiae
	
	task testcase();
		begin
			//PART 1: EN = 0
			//Step 1: load 8'hff to timer
			$display("------------------------------------");
			$display("----PART 1: TIMER IS NOT ENBLE");
			$display("------------------------------------");
			$display("STEP 1: Load 8'hff to timer");
			$display("At time %0d, write TDR to load", $time);
			top.CPU.write_data(`TDR, 8'hff);
			$display("At time %0d, write TCR to load", $time);
			top.CPU.write_data(`TCR, 8'h80);

			//Step 2: loaf 8'h00 to timer
			$display("------------------------------------");
			$display("STEP 2: Load 8'h00 to timer");
			$display("At time %0d, write TDR to load", $time);
			top.CPU.write_data(`TDR, 8'h00);
			$display("At time %0d, write TCR to load", $time);
			top.CPU.write_data(`TCR, 8'h80);

			//Step 3: check ovf flag
			$display("------------------------------------");
			$display("STEP 3: Check TSR");
			$display("At time %0d, read TSR", $time);
			top.CPU.read_data(`TSR, rdata);
			if (rdata[0] == 1'b0) begin
				$display("At time %0d, TSR = 8'h%0h, NOT OVERFLOW --PASS--", $time, rdata);
			end
			else begin
				$display("At time %0d, TSR = 8'h%0h, OVERFLOW --FAIL--", $time, rdata);
				top.fail_flag = 1'b1;
			end

			//PART 2: EN = 1
			//Step 1: load 8'hff to timer
			$display("------------------------------------");
			$display("----PART 2: TIMER IS NOT ENBLE");
			$display("------------------------------------");
			$display("STEP 1: Load 8'hff to timer");
			$display("At time %0d, write TDR to load", $time);
			top.CPU.write_data(`TDR, 8'hff);
			$display("At time %0d, write TCR to load", $time);
			top.CPU.write_data(`TCR, 8'h80);

			//Step 2: loaf 8'h00 to timer
			$display("------------------------------------");
			$display("STEP 2: Load 8'h00 to timer");
			$display("At time %0d, write TDR to load", $time);
			top.CPU.write_data(`TDR, 8'h00);
			$display("At time %0d, write TCR to load", $time);
			top.CPU.write_data(`TCR, 8'h90);

			//Step 3: check ovf flag
			$display("------------------------------------");
			$display("STEP 3: Check TSR");
			$display("At time %0d, read TSR", $time);
			top.CPU.read_data(`TSR, rdata);
			if (rdata[0] == 1'b0) begin
				$display("At time %0d, TSR = 8'h%0h, NOT OVERFLOW --PASS--", $time, rdata);
			end
			else begin
				$display("At time %0d, TSR = 8'h%0h, OVERFLOW --FAIL--", $time, rdata);
				top.fail_flag = 1'b1;
			end 

		end
	endtask

endmodule
