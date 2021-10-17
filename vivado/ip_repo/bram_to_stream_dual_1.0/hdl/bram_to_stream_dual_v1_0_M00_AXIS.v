
`timescale 1 ns / 1 ps

	module bram_to_stream_dual_v1_0_M00_AXIS #
	(
		 parameter integer BRAM_DEPTH_BITS =  10,
		parameter integer C_M_AXIS_TDATA_WIDTH	= 48,
		parameter integer BRAM_TDATA_WIDTH	= 64
	)
	(
		output wire [BRAM_DEPTH_BITS-1:0] BRAM_ADDR,
        input wire [BRAM_TDATA_WIDTH-1 : 0] BRAM_DATAIN,
		// Global ports
		input wire  M0_AXIS_ACLK, M1_AXIS_ACLK,
		// 
		input wire  M0_AXIS_ARESETN, M1_AXIS_ARESETN,
		// Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		output wire  M0_AXIS_TVALID, M1_AXIS_TVALID,
		// TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M0_AXIS_TDATA, M1_AXIS_TDATA,
		// TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M0_AXIS_TSTRB, M1_AXIS_TSTRB,
		// TLAST indicates the boundary of a packet.
		output wire  M0_AXIS_TLAST, M1_AXIS_TLAST,
		// TREADY indicates that the slave can accept a transfer in the current cycle.
		input wire  M0_AXIS_TREADY, M1_AXIS_TREADY
	);
	
	// Number of zero pad outptus
	localparam FILTER_SIZE = 16;
	// Number of real and imaginary values
	localparam NUMBER_OF_REAL_IMAG_WORDS = 1024;
	// Total number of output data                                                 
	localparam NUMBER_OF_OUTPUT_WORDS = NUMBER_OF_REAL_IMAG_WORDS + FILTER_SIZE;          
	
	parameter [1:0] IDLE = 2'b00,
	                SEND_STREAM   = 2'b01; 
	
	reg  [1:0] c_state , r_state ;
	
	//reg r_axi_tready;
	reg r_axi_tvalid, c_axi_tvalid;
	reg c_axi_tlast, r_axi_tlast;
	
	wire [BRAM_DEPTH_BITS-1 : 0] r_read_pointer; 
	reg [BRAM_DEPTH_BITS : 0] r_read_ctr, c_read_ctr;      
	                                                 

    assign r_read_pointer = (r_read_ctr < NUMBER_OF_REAL_IMAG_WORDS) ? r_read_ctr[BRAM_DEPTH_BITS-1:0] : 'd0;
	assign BRAM_ADDR = r_read_pointer;
	
	assign M0_AXIS_TDATA	= (r_read_ctr <= NUMBER_OF_REAL_IMAG_WORDS) ? {BRAM_DATAIN[55:32], BRAM_DATAIN[23:0]} : 'd0; //stream_data_out;
	assign M0_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
	assign M0_AXIS_TVALID = r_axi_tvalid;
	assign M0_AXIS_TLAST	= r_axi_tlast;
	
	assign M1_AXIS_TDATA	= (r_read_ctr <= NUMBER_OF_REAL_IMAG_WORDS) ? {BRAM_DATAIN[55:32], BRAM_DATAIN[23:0]} : 'd0; //stream_data_out;
	assign M1_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
	assign M1_AXIS_TVALID = r_axi_tvalid;
	assign M1_AXIS_TLAST	= r_axi_tlast;
	
	
	
	always @(*) begin

		c_state  = r_state;
		
		c_axi_tvalid = r_axi_tvalid;
		c_axi_tlast = r_axi_tlast;
		
		c_read_ctr = r_read_ctr;
		
		case (r_state)
		
		IDLE: begin
		
			c_axi_tvalid = 1'b0;
			
			c_state = SEND_STREAM;
		
		end
		
		SEND_STREAM: begin

			c_axi_tvalid = 1'b1;
			
			if (M0_AXIS_TREADY & M1_AXIS_TREADY) begin
			
			    if (r_read_ctr == NUMBER_OF_REAL_IMAG_WORDS + FILTER_SIZE - 1)  
			         c_axi_tlast = 1'b1;
			    else 
			         c_axi_tlast = 1'b0;
				
				if (r_read_ctr == NUMBER_OF_REAL_IMAG_WORDS + FILTER_SIZE)
				    c_read_ctr = 'd1;
				else
				    c_read_ctr = r_read_ctr + 'd1;

			end
			
			c_state = SEND_STREAM;
			
		end
		
		default: begin 
			c_state = IDLE ; 
		end 
		endcase
	end
	
	
	always @(posedge M0_AXIS_ACLK) begin
	
		r_state  <= (!M0_AXIS_ARESETN) ?  'd0 : c_state;
		
		//r_axi_tready <= (!M_AXIS_ARESETN) ?  'd0 : M_AXIS_TREADY;
		r_axi_tvalid <= (!M0_AXIS_ARESETN) ?  'd0 : c_axi_tvalid;
		r_axi_tlast <= (!M0_AXIS_ARESETN) ?  'd0 : c_axi_tlast;
		
		r_read_ctr <= (!M0_AXIS_ARESETN) ?  'd0 : c_read_ctr;
	end


endmodule
