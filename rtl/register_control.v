`timescale 1ns/1ps
module register_control (
	
	input 			 	pclk,
	input 			 	presetn,
	input 			 	psel,
	input 			 	pwrite,
	input 	 		 	penable,
	input  [7:0] 		paddr,
	input  [7:0] 		pwdata,
	
	output reg [7:0] 	prdata,
	output reg   		pready,
	output reg			pslverr,
	output reg [7:0] 	tdr,
	output reg [7:0] 	tcr,
	//output reg [7:0] 	tsr,
	output reg [1:0] 	trig_clr,
	//output reg [1:0] 	s_tmr_udf,
	//output reg [1:0] 	s_tmr_ovf,

	input 						udf_trig,
	input 						ovf_trig
												);

	`define WAIT_CYCLES 2

	reg [1:0] count;
	reg [2:0] reg_sel;
	wire write_en, read_en;

	reg  	s_tmr_udf;
	reg  	s_tmr_ovf;

	//Register Select
		always @(paddr) begin
		case(paddr)
			8'h00: reg_sel= 3'b001;
			8'h01: reg_sel= 3'b010;
			8'h02: reg_sel= 3'b100;
		
			default: reg_sel=3'b000;
		endcase
	end

		// PSLVERR RESPONSE
		always @(posedge pclk or negedge presetn) begin
		if(~presetn) begin
			pslverr <= 1'b0;
		end
		else if (reg_sel == 8'd0) begin
			pslverr <= 1'b1;
		end
		else begin
			pslverr <= 1'b0;
		end
	end

		//PREADY RESPONSE
		always @(posedge pclk or negedge presetn) begin
		if(~presetn) begin
			pready <= 1'b0;
			count  <= 2'b0;
		end
		else if(psel && penable && count == 2'b00) begin
			#1;
			pready <= 1'b0;
		end	//psel penable count
		else if(psel) begin
			if(count == `WAIT_CYCLES) begin
				count  <= 2'b00;
				#1;
				pready <= 1'b1;
			end	// count= WAIT_CYCLES
			else begin
				count <= count+ 1;
			end	//wait count= WAIT_CYCLES
		end
		else begin
			pready <= 1'b0;
		end
	end

	//REGISTER ACCESS
	assign write_en = psel & penable & pready & pwrite;
	assign read_en  = psel & penable & pready & ~pwrite;

	//always @(posedge pclk, negedge presetn) begin
	//	if (~presetn) begin
	//		prdata <= 8'd0;
	//	end
	//	else begin
	always @(*) begin 
			if (read_en) begin
				case (reg_sel)
					3'b001 : prdata = tdr;
					3'b010 : prdata = tcr;
					3'b100 : prdata = {6'd0 , s_tmr_udf , s_tmr_ovf};
					default: prdata = 8'd0;
				endcase
			end
			else begin
				prdata <= prdata;
			end
		end
	//end


	always @(posedge pclk, negedge presetn) begin
		if(~presetn) begin
			tdr <= 8'd0;
		end
		else if(write_en && reg_sel[0]) begin
			tdr <= pwdata;
		end
		else begin
			tdr <= tdr;
		end
	end

	always @(posedge pclk, negedge presetn) begin
		if(~presetn) begin
			tcr <= 8'd0;
		end
		else if(write_en && reg_sel[1]) begin
			tcr[7]	 <= pwdata[7];
			tcr[5]	 <= pwdata[5];
			tcr[4] 	 <= pwdata[4];
			tcr[1:0] <= pwdata[1:0];
		end
		else begin
			tcr <= tcr;
		end
	end

	//UNDERFLOW
	always @(posedge pclk, negedge presetn) begin
		if (~presetn) begin
			trig_clr[1] 	<= 1'b0;
			s_tmr_udf 		<= 1'b0;
		end
		else begin
			//clear by Software
			if ((write_en && reg_sel[2]) && (pwdata[1] == 1'b0)) begin
				s_tmr_udf 	<= pwdata[1];
				trig_clr[1] <= 1'b0;
			end
			else begin
				//set by Hardware
				if (udf_trig) begin
					s_tmr_udf 	<= 1'b1;
					trig_clr[1] <= 1'b1;
				end
				else begin
					s_tmr_udf  	<= s_tmr_udf;
					trig_clr[1] <= trig_clr[1];
				end
			end
		end
	end
	

	//OVERFLOW
	always @(posedge pclk, negedge presetn) begin
		if (~presetn) begin
			trig_clr[0] 	<= 1'b0;
			s_tmr_ovf 		<= 1'b0;
		end
		else begin
			//clear by Software
			if ((write_en && reg_sel[2]) && (pwdata[0] == 1'b0)) begin
				s_tmr_ovf 	<= pwdata[0];
				trig_clr[0] <= 1'b0;
			end
			else begin
				//set by Hardware
				if (ovf_trig) begin
					s_tmr_ovf 	<= 1'b1;
					trig_clr[0] <= 1'b1;
				end
				else begin
					s_tmr_ovf  	<= s_tmr_ovf;
					trig_clr[0] <= trig_clr[0];
				end
			end
		end
	end


endmodule
