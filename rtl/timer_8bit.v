module timer_8bit(
	input									pclk,
	input									presetn,
	input 								psel,
	input									penable,
	input									pwrite,
	input				[7:0]			paddr,
	input 			[7:0]			pwdata,

	output wire	[7:0] 		prdata,
	output wire						pready,
	output wire						pslverr
);
	
	wire	[1:0]						cks;
	wire									clk_cnt;
	wire									en, load, dw;
	wire	[7:0]						ld_val, cnt;
	wire 	[1:0]						trig_clr;
	wire									udf_trig, ovf_trig;
	wire	[7:0]						tdr, tcr;


	clk_sel clk_rst_gen(
		.pclk				(pclk),
		.presetn    (presetn),
		.sel				(cks),
		.clk_out		(clk_cnt)
	);

	timer_counter counter(
		.pclk				(pclk),
    .presetn		(presetn),
            
    .clk_int		(clk_cnt),
            
    .en					(en),
    .load				(load),
    .ld_val			(ld_val),
    .dw					(dw),
            
    .cnt_out		(cnt)
	);

	control_logic timer_control(
		.pclk				(pclk),
    .presetn		(presetn),
             
    .cnt				(cnt),
    .tdr				(tdr),
    .tcr				(tcr),
    .trig_clr		(trig_clr),
             
    .clk_sel		(cks),
    .en					(en),
    .load				(load),
    .ld_val			(ld_val),
    .dw					(dw),
    .udf_trig		(udf_trig),
    .ovf_trig		(ovf_trig)
	);

	register_control timer_register(
		.pclk				(pclk),
    .presetn		(presetn),
    .psel				(psel),
    .pwrite			(pwrite),
    .penable		(penable),
    .paddr			(paddr),
    .pwdata			(pwdata),
             
    .prdata			(prdata),
    .pready			(pready),
    .pslverr		(pslverr),
    .tdr				(tdr),
    .tcr				(tcr),
    .trig_clr		(trig_clr),         
    .udf_trig		(udf_trig),
    .ovf_trig		(ovf_trig)
	);

endmodule
