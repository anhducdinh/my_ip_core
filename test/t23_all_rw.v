`timescale 1ns/1ps
module t23_all_rw ();
	
	tb top();

	reg	[7:0]	bitmask_tdr, bitmask_tcr;
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
		$display("===== ALL WRITE READ TEST BEGIN =====");
		$display("=====================================");

		top.fail_flag = 1'b0;

		repeat (100) begin
			address	[7:3]	= 5'd0;
			address	[2:0]	= $random();
			a = a + 1;
			$display("\nTEST No.%0d", a);
			wdata = $random();
			if (address >= 8'd3) begin
				$display("INVALID ADDRESS");
			end
			else begin
				top.CPU.write_data(address, wdata);
				top.CPU.read_data(address, rdata);
				case (address)
					8'h00: begin
						bitmask_tdr = 8'b1111_1111;
						exp_data = wdata & bitmask_tdr;

						if (rdata == exp_data) begin
							$display("At time %0d, wdata = 8'h%0h, rdata = 8'h%0h, exp_data = 8'h%0h ---PASS---", $time, wdata, rdata, exp_data);
						end
						else begin
							top.fail_flag = 1'b1;
							$display("At time %0d, wdata = 8'h%0h, rdata = 8'h%0h, exp_data = 8'h%0h ---FAIL---", $time, wdata, rdata, exp_data);
						end
					end


					8'h01: begin
						bitmask_tcr = 8'b1011_0011;
						exp_data = wdata & bitmask_tcr;

						if (rdata == exp_data) begin
							$display("At time %0d, wdata = 8'h%0h, rdata = 8'h%0h, exp_data = 8'h%0h ---PASS---", $time, wdata, rdata, exp_data);
						end
						else begin
							top.fail_flag = 1'b1;
							$display("At time %0d, wdata = 8'h%0h, rdata = 8'h%0h, exp_data = 8'h%0h ---FAIL---", $time, wdata, rdata, exp_data);
						end
					end
				

					8'h02: begin
						if ((wdata	[1:0]	== 2'b0) && (rdata [1:0] == wdata [1:0])) begin
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
					end


				endcase
			end
		end // repeat
	#50;
	top.get_result();
	$finish();
	end //initial

endmodule
