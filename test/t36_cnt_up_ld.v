`include "define.v"
module t36_cnt_up_ld();

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
      reg[7:0]  init_value;
	  reg[7:0]  wait_cycles_1; 
	  reg[7:0]  wait_cycles_2;
       begin
          //step 1 configuration 
          //STEP1
          //TIMER CONFIGURATION
           $display("------------------------------------------------");
           $display("STEP1: TIMER CONFIGRUATION");
		   $display("At time %0d, Generated init value for Timer Counter",$time);
		   init_value = $random;
		   if(init_value < 8'd50) begin 
			  init_value = init_value + 50;
			  $display(" At time %0d, init_value is smaller than 50 --> add 50", $time);
		   end 
		   else if(init_value > 8'd150) begin
			  init_value = init_value - 100;
			  $display(" At time %0d, init_value is greated than 150 --> sub 100 ", $time);
		   end
		   else begin 
			   $display(" At time %0d, init_value is in range 50 --> 150 ", $time);
		   end
          //wait cycles 1: not overflow
		  //wait cycles 2: overflow
		   
		   wait_cycles_2 = 256 - init_value;
		   wait_cycles_1 = wait_cycles_2 - 20;
		   $display(" At time %0d, wait_cycles_1 = %0d ", $time, wait_cycles_1);
		   $display(" At time %0d, wait_cycles_2 = %0d ", $time, wait_cycles_2);
         
		   // generated initial value of TDR and TCR 
		   $display("\nAt %0d Starting counting to TDR at %0d ",$time, init_value);
		   top.CPU.write_data(`TDR, init_value);
		   $display("\nAt %0d Start load count to TCR at %0d ",$time, init_value);
		   top.CPU.write_data(`TCR, 8'h80);	

		   $display ("At time %0d, write TCR to start timer", $time);
		//wdata		BIT: 	7	6	 5	    4		3:2		1:0
		//		       load   reserve    dw	    en        reserved	     clk_sel
		wdata = {1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 2'b00};
		//wdata = 8'h10;
		top.CPU.write_data(`TCR, wdata);

		 //STEP2
                $display("\n------------------------------------------------");
                $display("STEP2: CHECK OVERFLOW FLAG");


                fork
                        //STEP 2.1
                        $display("\nAt time %0d, waiting for ovf", $time);
                        begin
                                repeat (`PER_CLK_2 * wait_cycles_1) @(posedge top.pclk);

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
                                repeat (`PER_CLK_2 * wait_cycles_2) @(posedge top.pclk);
                              
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
                
	    end            // end begin task
      endtask
endmodule



