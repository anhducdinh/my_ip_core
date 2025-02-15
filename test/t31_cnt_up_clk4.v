`include "define.v"
module t31_cnt_up_clk4();

	tb top();

	reg		[7:0] address, wdata, rdata;

	initial begin
		#200;
		//Test info
		$display("==================================================");
		$display("=============== COUNT UP TEST CLOCK4==============");
		$display("==================================================");

		//STEP1
		//TIMER CONFIGURATION
		$display("------------------------------------------------");
		$display("STEP1: TIMER CONFIGRUATION");
		$display ("At time %0d, write TCR to start timer", $time);
		//wdata		BIT: 	7			6			5		4		3:2				1:0
		//						load	reserve	dw	en	reserved	clk_sel
		wdata = {1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 2'b01};
		//wdata = 8'h11;
		top.CPU.write_data(`TCR, wdata);

		//STEP2
		$display("\n------------------------------------------------");
		$display("STEP2: CHECK OVERFLOW FLAG");


		fork
			//STEP 2.1
			$display("\nAt time %0d, waiting for ovf", $time);
			begin
				repeat (`PER_CLK_4 * 220) @(posedge top.pclk);

				$display("At time %0d, after 220 clk_cnt, read TSR", $time);
				top.CPU.read_data(`TSR, rdata);

				if (rdata == 8'h00) begin
					$display("At time %0d, TSR = 8'h%0h, NOT OVERFLOW --PASS--", $time, rdata);
				end
				else begin
					$display("At time %0d, TSR = 8'h%0h, OVERFLOW --FAIL--", $time, rdata);
					top.fail_flag = 1'b1;
				end
			end

			//STEP 2.2
			begin
				repeat (`PER_CLK_4 * 256) @(posedge top.pclk);
				
				$display("\nAt time %0d, after 256 clk_cnt, read TSR (STEP 2.2)", $time);
				top.CPU.read_data(`TSR, rdata);

				if (rdata == 8'h01) begin
					$display("At time %0d, TSR = 8'h%0h, OVERFLOW --PASS--", $time, rdata);
				end
				else begin
					$display("At time %0d, TSR = 8'h%0h, NOT OVERFLOW --FAIL--", $time, rdata);
					top.fail_flag = 1'b1;
				end
			end

		join
		//STEP 3
		$display("\n-------------------------------------------------");
		$display("STEP 3: CLEAR TSR");
		$display("At time %0d, clear TSR", $time);
		top.CPU.write_data(`TSR, 8'h00);

		//STEP 4
		$display("\n-------------------------------------------------");
		$display("STEP 4: CLEAR TSR");
		$display("At time %0d, read TSR", $time);
		top.CPU.read_data(`TSR, rdata);

		if (rdata == 8'h00) begin
			$display("At time %0d, TSR = 8'h%0h", $time, rdata);
			$display("BIT OVERFLOW CLEARED --PASS--");
		end
		else begin
			$display("At time %0d, TSR = 8'h%0h", $time, rdata);
			$display("BIT OVERFLOW CLEARED --FAIL--");
			top.fail_flag = 1'b1;
		end
		top.test_end();
	end


endmodule
