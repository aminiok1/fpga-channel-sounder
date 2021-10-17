
`timescale 1 ns / 1 ps

	module stream_to_bram_fft_v1_0_S00_AXIS #
	(
	  parameter integer BRAM_DEPTH = 10,
        parameter integer BRAM_DATA_WIDTH = 64,

		// AXI4Stream sink: Data Width
		parameter integer C_S_AXIS_TDATA_WIDTH	= 96
	)
	(
		output wire [BRAM_DEPTH-1 : 0] BRAM_ADDR,
		output wire [BRAM_DATA_WIDTH-1 : 0] BRAM_DATAOUT,
		output wire BRAM_W_ENABLE,

		// AXI4Stream sink: Clock
		input wire  S_AXIS_ACLK,
		// AXI4Stream sink: Reset
		input wire  S_AXIS_ARESETN,
		// Ready to accept data in
		output wire  S_AXIS_TREADY,
		// Data in
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
		// Byte qualifier
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
		// Indicates boundary of last packet
		input wire  S_AXIS_TLAST,
		// Data is in valid
		input wire  S_AXIS_TVALID
	);
	
	localparam NUMBER_OF_INPUT_WORDS  = 1024;
	
	parameter [1:0] IDLE = 2'b00,
	                RECEIVE_STREAM   = 2'b01; 
	
	reg  [1:0] c_state , r_state ;
	
	reg r_w_enable;
	reg r_axi_tlast;
	
	reg [BRAM_DEPTH-1 : 0] r_write_pointer, c_write_pointer;                                                      

    (* dont_touch = "true" *) reg [C_S_AXIS_TDATA_WIDTH-1 : 0] r_axis_tdata;
    (* dont_touch = "true" *) wire [42 : 0] r_axis_tdata_low, r_axis_tdata_high; 
    
	assign S_AXIS_TREADY = 1'b1;
	assign BRAM_ADDR = r_write_pointer;
	assign BRAM_W_ENABLE = r_w_enable;
	
	assign r_axis_tdata_low = (r_axis_tdata[42:0] >> 10);
	assign r_axis_tdata_high = (r_axis_tdata[90:48] >> 10);
	assign BRAM_DATAOUT = {r_axis_tdata_high[31:0], r_axis_tdata_low[31:0]};
	
	always @(*) begin

		c_state  = r_state;
		
		c_write_pointer = r_write_pointer;
		
		case (r_state)
		
		IDLE: begin
					
			c_state = RECEIVE_STREAM;
		
		end
		
		RECEIVE_STREAM: begin

			if (r_w_enable) begin
				
				if((r_write_pointer == NUMBER_OF_INPUT_WORDS - 1) || r_axi_tlast)
					c_write_pointer = 'd0;
				else
					c_write_pointer = r_write_pointer + 'd1;
			end
		end
		
		default: begin 
			c_state = IDLE ; 
		end 
		endcase
	end
	
	
	always @(posedge S_AXIS_ACLK) begin
	
		r_state  <= (!S_AXIS_ARESETN) ?  'd0 : c_state;
		r_w_enable  <= (!S_AXIS_ARESETN) ?  'd0 : S_AXIS_TVALID;
		r_axi_tlast  <= (!S_AXIS_ARESETN) ?  'd0 : S_AXIS_TLAST;

		r_write_pointer <= (!S_AXIS_ARESETN) ?  'd0 : c_write_pointer;
		
		r_axis_tdata <= (!S_AXIS_ARESETN) ?  'd0 : S_AXIS_TDATA;
	end


endmodule
