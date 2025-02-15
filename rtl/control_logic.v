module control_logic(
	input 				pclk,
	input 				presetn,

	input 	[7:0]       cnt,
	input 	[7:0]       tdr,
	input 	[7:0]       tcr,
	input 	[1:0]       trig_clr,

	output 	[1:0]       clk_sel,
	output 				en,
	output 				load,
	output 	[7:0]       ld_val,
	output 				dw,
	output 	reg		    udf_trig,
	output 	reg		    ovf_trig
								);
	reg			[7:0] last_cnt;

	always @(posedge pclk, negedge presetn) begin
		if (~presetn) begin
			last_cnt <= 8'd0;
		end
		else begin
			last_cnt <= cnt;
		end
	end

	assign 		ld_val 	= tdr;

	assign 		load 		= tcr[7];
	assign 		dw			= tcr[5];
	assign 		en			= tcr[4];
	assign 		clk_sel     = tcr[1:0];

	always @(posedge pclk, negedge presetn) begin
		if (~presetn) begin
			udf_trig <= 1'b0;
		end
		else begin
			if (trig_clr[1])begin
				udf_trig <= 1'b0;
			end
			else if ((cnt == 8'hff) && (last_cnt == 8'd0) && (dw == 1'b1) && (en == 1'b1) && (load == 1'b0)) begin
				udf_trig <= 1'b1;
			end
			else begin
				udf_trig <= udf_trig;
			end
		end
	end

	always @(posedge pclk, negedge presetn) begin
		if (~presetn) begin
			ovf_trig <= 1'b0;
		end
		else begin
			if (trig_clr[0]) begin
				ovf_trig <= 1'b0;
			end
			else if ((cnt == 8'h00) && (last_cnt == 8'hff) && (dw == 1'b0) && (en == 1'b1) && (load == 1'b0)) begin
				ovf_trig <= 1'b1;
			end
			else begin
				ovf_trig <= ovf_trig;
			end
		end
	end

endmodule
