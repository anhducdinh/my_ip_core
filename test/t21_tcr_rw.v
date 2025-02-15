`timescale 1ns/1ps
module t21_tcr_rw ();
	
	tb top();

	reg	[7:0]	bitmask, address, rdata, wdata, exp_data;

	integer	a = 0;
	
	//Test process
	`define TCR 8'h01
	initial begin
		#200;
		$display("=====================================");
		$display("===== TCR WRIRE READ TEST BEGIN =====");
		$display("=====================================");

		top.fail_flag = 1'b0;
		address = `TCR;
		bitmask = 8'b1011_0011;

		repeat (100) begin
			a = a + 1;
			$display("\nTEST No.%0d", a);
			wdata = $random();
			top.CPU.write_data(address, wdata);
			top.CPU.read_data(address, rdata);
			exp_data = wdata & bitmask;

			if (rdata == exp_data) begin
				$display("At time %0d, wdata = 8'h%0h, rdata = 8'h%0h, exp_data = 8'h%0h ---PASS---", $time, wdata, rdata, exp_data);
			end
			else begin
				top.fail_flag = 1'b1;
				$display("At time %0d, wdata = 8'h%0h, rdata = 8'h%0h, exp_data = 8'h%0h ---FAIL---", $time, wdata, rdata, exp_data);
			end
		end

	#50;
	top.get_result();
	$finish();

	end	

endmodule
