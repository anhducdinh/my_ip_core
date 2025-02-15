`include "define.v"
module t34_cnt_up_rst();

	tb top();

	reg	[7:0] address, wdata, rdata;

	initial begin
		#200;
		//Test info
		$display("==================================================");
		$display("=============== COUNT UP WITH RESET ==============");
		$display("==================================================");

		testcase();

		top.test_end();

	end

	task testcase();
		begin
			//STEP1
			//TIMER CONFIGURATION
			$display("------------------------------------------------");
			$display("STEP1: TIMER CONFIGRUATION");
			$display ("At time %0d, write TCR to start timer", $time);
			//wdata		BIT: 	7			6			5		4		3:2				1:0
			//						load	reserve	dw	en	reserved	clk_sel
			//wdata = {1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 2'b00};
			wdata = 8'h10;
			top.CPU.write_data(`TCR, wdata);

			//STEP2
			repeat (`PER_CLK_2 * 220) @(posedge top.pclk);
			$display("\n------------------------------------------------");
			$display("STEP2: CHECK OVERFLOW FLAG");
			$display("At time %0d, after 220 clk_cnt, read TSR", $time);
			top.CPU.read_data(`TSR, rdata);

			if (rdata == 8'h00) begin
				$display("At time %0d, TSR = 8'h%0h, NOT OVERFLOW --PASS--", $time, rdata);
			end
			else begin
				$display("At time %0d, TSR = 8'h%0h, OVERFLOW --FAIL--", $time, rdata);
				top.fail_flag = 1'b1;
			end
		
			//STEP 3
			$display("\n-------------------------------------------------");
			$display("STEP 3: RESET TIMER");
			top.clk_rst_gen_inst.sys_resetn = 1'b0;
			$display("At time %0d, assert reset: reset value = %0b", $time, top.clk_rst_gen_inst.sys_resetn);
			#200;
			top.clk_rst_gen_inst.sys_resetn = 1'b1;
			$display("At time %0d, de-assert reset: reset value = %0b", $time, top.clk_rst_gen_inst.sys_resetn);
			$display("\n---------------------RESET DONE---------------------");
			
			//STEP 4
			$display("\n-------------------------------------------------");
			$display("STEP 4: START TIMERR AGAIN");
			top.CPU.write_data(`TCR, 8'h10);

			//STEP 5
			$display("\n-------------------------------------------------");
			$display("STEP 5: WAIT FOR OVF");
			repeat (`PER_CLK_2 * 256) @(posedge top.pclk);

			//STEP 6
			$display("\n-------------------------------------------------");
			$display("STEP 6: CHECK OVF");
			$display("At time %0d, read TSR", $time);
			top.CPU.read_data(`TSR, rdata);
			if (rdata == 8'h01) begin
				$display("At time %0d, TSR = 8'h%0h, OVERFLOW --PASS--", $time, rdata);
			end
			else begin
				$display("At time %0d, TSR = 8'h%0h, NOT OVERFLOW --FAIL--", $time, rdata);
				top.fail_flag = 1'b1;
			end

			//STEP 7
			$display("\n-------------------------------------------------");
			$display("STEP 7: CLEAR TSR");
			$display("At time %0d, clear TSR", $time);
			top.CPU.write_data(`TSR, 8'h00);

			//STEP 8
			$display("\n-------------------------------------------------");
			$display("STEP 8: READ TSR AND CHECK");
			$display("At time %0d, read TSR", $time);
			top.CPU.read_data(`TSR, rdata);
			if (rdata == 8'h00) begin
				$display("At time %0d, TSR = 8'h%0h", $time, rdata);
				$display("BIT OVERFLOW CLEARED --PASS--");
			end
			else begin
				$display("At time %0d, TSR = 8'h%0h", $time, rdata);
				$display("BIT OVERFLOW NOTCLEARED --FAIL--");
				top.fail_flag = 1'b1;
			end
		end

	endtask


endmodule
