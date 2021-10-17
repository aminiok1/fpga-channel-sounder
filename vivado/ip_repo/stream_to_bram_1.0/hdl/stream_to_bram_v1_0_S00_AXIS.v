
`timescale 1 ns / 1 ps

	module stream_to_bram_v1_0_S00_AXIS #
	(
        parameter integer BRAM_DEPTH = 11,
        parameter integer BRAM_DATA_WIDTH = 64,

		// AXI4Stream sink: Data Width
		parameter integer C_S_AXIS_TDATA_WIDTH	= 64
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
	
	// 32 is for FIR filter flush, remove for FFT 
	localparam NUMBER_OF_INPUT_WORDS  = 1024 + 32;
	
	parameter [1:0] IDLE = 2'b00,
	                RECEIVE_STREAM   = 2'b01; 
	
	reg  [1:0] c_state , r_state ;
	
	reg r_w_enable;
	reg r_axi_tlast;
	
	reg [BRAM_DEPTH-1 : 0] r_write_pointer, c_write_pointer;                                                      

    (* dont_touch = "true" *) reg [BRAM_DATA_WIDTH-1 : 0] r_axis_tdata;
    
	assign S_AXIS_TREADY = 1'b1;
	assign BRAM_ADDR = r_write_pointer;
	assign BRAM_W_ENABLE = r_w_enable;
	assign BRAM_DATAOUT = r_axis_tdata; //{S_AXIS_TDATA[90:59], S_AXIS_TDATA[42:11]};
	
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
