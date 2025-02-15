`include "define.v"
`timescale 1ns/1ps

 module t45_cnt_dw_udf ();

   tb top();

   reg [7:0] address, wdata, rdata;
   reg [7:0] wait_cycles;
   integer test_No;


   initial begin 
    #200;
     top.fail_flag = 1'b0;
      //Test info
          $display("==================================================");
          $display("=============== COUNT DW WITH UDF=================");
          $display("==================================================");

       testcase();

      top.test_end();
   end

   task testcase();
        begin 
	test_No = 0;
	       repeat(20) begin
                 test_No = test_No + 1;
		 $display("\n...................................................");
		 $display("...Test No.%0d...",test_No);
		 $display("..................................................");

         //STEP1
         //TIMER CONFIGURATION
         $display("------------------------------------------------");
         $display("STEP1: TIMER CONFIGRUATION");
			top.CPU.write_data(`TDR, 8'hff);
			top.CPU.write_data(`TCR, 8'h80);
             $display ("At time %0d, write TCR to start timer", $time);
                        //wdata  BIT:    7      6       5       4      3:2         1:0
                        //            load    reserve dw      en      reserved        clk_sel
                        //wdata = {1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 2'b00};
                        wdata[1:0] = $random;  //random clk_sel
			wdata[7:2] = 6'h0C;     // 0 0 1 1 0 0_ _
                        top.CPU.write_data(`TCR, wdata);

		case(wdata[1:0]) 
		  2'b00:      wait_cycles = `PER_CLK_2; 
		  2'b01:      wait_cycles = `PER_CLK_4;
		  2'b10:      wait_cycles = `PER_CLK_8;
		  2'b11:      wait_cycles = `PER_CLK_16;
		  default:   $display(" Not any clocks specified");
		endcase

	$display(" At time %0d, timer run with clk( %0d ) ", $time, wait_cycles);

        //STEP2
                $display("\n------------------------------------------------");
                $display("STEP2: CHECK UNDERFLOW FLAG");


                fork
                        //STEP 2.1
                        $display("\nAt time %0d, waiting for udf", $time);
                        begin
                                repeat (wait_cycles * 220) @(posedge top.pclk);

                                $display("At time %0d, after 220 clk_cnt, read TSR", $time);
                                top.CPU.read_data(`TSR, rdata);

                                if (rdata == 8'h00) begin
                                        $display("At time %0d, TSR = 8'h%0h, NOT UNDERFLOW --PASS--", $time, rdata);
                                end
                                else begin
                                        $display("At time %0d, TSR = 8'h%0h, UNDERFLOW --FAIL--", $time, rdata);
                                        top.fail_flag = 1'b1;
                                end
                        end

                        //STEP 2.2
                        begin
                                repeat (wait_cycles * 256) @(posedge top.pclk);
                              
                                $display("\nAt time %0d, after 256 clk_cnt, read TSR (STEP 2.2)", $time);
                                top.CPU.read_data(`TSR, rdata);

                                if (rdata == 8'h02) begin
                                        $display("At time %0d, TSR = 8'h%0h, UNDERFLOW --PASS--", $time, rdata);
                                end
                                else begin
                                        $display("At time %0d, TSR = 8'h%0h, NOT UNDERFLOW --FAIL--", $time, rdata);
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
                        $display("BIT UNDERFLOW CLEARED --PASS--");
                end
                else begin
                        $display("At time %0d, TSR = 8'h%0h", $time, rdata);
                        $display("BIT UNDERFLOW CLEARED --FAIL--");
                        top.fail_flag = 1'b1;
                end
                
	end     // end repeat
      end       // end begin task
      endtask
endmodule


