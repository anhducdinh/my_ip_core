`timescale 1ns/1ps
module t22_tsr_rw ();
	
	tb top();

	reg	[7:0]	bitmask, address, rdata, wdata, exp_data;

	integer	a = 0;
	
	//Test process
	`define TSR 8'h02
	initial begin
		#200;
		$display("=====================================");
		$display("===== TSR WRIRE READ TEST BEGIN =====");
		$display("=====================================");

		top.fail_flag = 1'b0;
		address = `TSR;
		//bitmask = 8'b0000_0000;

		repeat (100) begin
			a = a + 1;
			$display("\nTEST No.%0d", a);
			wdata	[7:2]	=	6'd0;
			wdata	[1:0] = $random();
			top.CPU.write_data(address, wdata);
			top.CPU.read_data(address, rdata);
			//exp_data = wdata & bitmask;
			if ((wdata	[1:0]	== 2'b0) && (rdata == wdata)) begin
				$display("At time %0d, wdata = 8'h%0d, rdata = 8'h%0d, ---PASS---", $time, wdata, rdata);
			end
			else begin
				if (((wdata [1:0]	== 2'b01) || (wdata	[1:0] == 2'b10) || (wdata [1:0] == 2'b11)) && (rdata == 2'b0)) begin
					$display("At time %0d, wdata = 8'h%0d, rdata = 8'h%0d, ---PASS---", $time, wdata, rdata);
				end
				else begin
					top.fail_flag = 1'b1;
					$display("At time %0d, wdata = 8'h%0d, rdata = 8'h%0d, ---FAIL---", $time, wdata, rdata);
				end
			end
		end //repeat

	#50;
	top.get_result();
	$finish();

	end	//initial

endmodule
