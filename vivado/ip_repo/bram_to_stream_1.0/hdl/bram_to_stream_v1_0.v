
`timescale 1 ns / 1 ps

	module bram_to_stream_v1_0 #
	(
		
        parameter integer BRAM_DEPTH_BITS = 10,
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 48,
		parameter integer BRAM_TDATA_WIDTH	= 64
	)
	(
		// Users to add ports here
        output wire [BRAM_DEPTH_BITS-1:0] bram_addr,
        input wire [BRAM_TDATA_WIDTH-1 : 0] bram_datain,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
	);
// Instantiation of Axi Bus Interface M00_AXIS
	bram_to_stream_v1_0_M00_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
		.BRAM_TDATA_WIDTH(BRAM_TDATA_WIDTH),
		.BRAM_DEPTH_BITS(BRAM_DEPTH_BITS)
	) bram_to_stream_v1_0_M00_AXIS_inst (
	    .BRAM_ADDR(bram_addr),
        .BRAM_DATAIN(bram_datain),
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN(m00_axis_aresetn),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TSTRB(m00_axis_tstrb),
		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TREADY(m00_axis_tready)
	);

	// Add user logic here

	// User logic ends

	endmodule
