`timescale 1ns/1ps
module t20_tdr_rw ();
	
	tb top();

	reg	[7:0]	bitmask;
	reg	[7:0]	address;
	reg	[7:0]	rdata;
	reg	[7:0]	wdata;
	reg	[7:0]	exp_data;

	integer	a = 0;
	
	//Test process
	`define TDR 8'h00
	initial begin
		#200;
		$display("=====================================");
		$display("===== TDR WRITE READ TEST BEGIN =====");
		$display("=====================================");

		top.fail_flag = 1'b0;
		address = `TDR;
		bitmask = 8'b1111_1111;

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
