module smoke_test();
	
	//Instance testbench
	tb top();

	//Test process
	initial begin
		top.fail_flag = 1'b0;
		top.get_result();
		top.fail_flag = 1'b1;
		top.get_result();
		$finish();
	end
endmodule
