`timescale 1ns/1ps
module tb();

	wire 									pclk, presetn;
  wire 									psel, pwrite, penalbe, pready;
  wire 									pslverr;
  wire [7:0] 						pwdata, prdata,  paddr;

	reg										fail_flag;

	clk_rst_gen clk_rst_gen_inst(
		.sys_clk		(pclk),
		.sys_resetn	(presetn)
															);
	
	timer_8bit DUT(
	.pclk				(pclk   ),
    .presetn		(presetn),
    .psel				(psel   ),
    .penable		(penable),
    .pwrite			(pwrite ),
    .paddr			(paddr  ),
    .pwdata			(pwdata ),
                        
    .prdata			(prdata ),
    .pready			(pready ),
    .pslverr		(pslverr)
	);

	cpu_model CPU(
		.cpu_pclk		(pclk		),
    .cpu_presetn(presetn),
                       
    .cpu_pready	(pready	),
    .cpu_psel		(psel		),
    .cpu_pwrite	(pwrite	),
    .cpu_penable(penable),
    .cpu_pslverr(pslverr),
                       
    .cpu_paddr	(paddr	),
    .cpu_pwdata	(pwdata	),
    .cpu_prdata	(prdata	)

	);

	task get_result();
		if(fail_flag) begin
			$display("===============================");
			$display("============ FAILED ===========");
			$display("===============================");
		end
		else begin
			$display("===============================");
			$display("============ PASSED ===========");
			$display("===============================");
		end
	endtask
  task test_end();
		begin
			#50;
			get_result();
			$finish();
		end
	endtask

endmodule
