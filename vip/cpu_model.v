
module cpu_model(
									input  		   cpu_pclk,
									input  		   cpu_presetn,

									input  		   cpu_pready,
									output  reg	   cpu_psel,
									output 	reg	   cpu_pwrite,
									output 	reg	   cpu_penable,
									input  		   cpu_pslverr,

									output reg [7:0] 		cpu_paddr,
									output reg [7:0] 		cpu_pwdata,
									input  	   [7:0]	 	cpu_prdata
								);
	task write_data(input [7:0] address, wdata);
		begin
			@(posedge cpu_pclk);
			#1;
			//Setuo phase
			cpu_paddr= address;
			cpu_pwdata= wdata;
			cpu_psel= 1'b1;
			cpu_pwrite= 1'b1;
			$display("At %0d Start writing wdata = 8'h%0h to address = 8'h%0h", $time, wdata, address);

			@(posedge cpu_pclk);
			#1;
			cpu_penable= 1'b1;

			//Acess phase
			@(posedge cpu_pclk);
			while(!cpu_pready) begin
				@(posedge cpu_pclk);
			end

			//Start transfering
			#1;
			cpu_psel= 1'b0;
			cpu_pwrite= 1'b0;
			cpu_penable= 1'b0;
			cpu_pwdata= 8'd0;
			$display("At %0d Write Transfer has been finished", $time);

		end
	endtask

	task read_data(input [7:0] address, output [7:0] rdata);
		begin	
			@(posedge cpu_pclk);
			#1;
			//Setup phase
			cpu_paddr= address;
			cpu_psel= 1'b1;
			cpu_pwrite= 1'b0;
			$display("At %0d Start reading data at  address = 8'h%0h", $time, address);

			@(posedge cpu_pclk);
			#1;
			cpu_penable= 1'b1;

			//Acess phase
			@(posedge cpu_pclk);
			while(!cpu_pready) begin
				@(posedge cpu_pclk);
			end
			rdata= cpu_prdata;

			//Start transfering
			#1;
			cpu_psel= 1'b0;
			cpu_pwrite= 1'b0;
			cpu_penable= 1'b0;
			$display("At %0d Read Transfer has been finished", $time);

		end

	endtask

endmodule
