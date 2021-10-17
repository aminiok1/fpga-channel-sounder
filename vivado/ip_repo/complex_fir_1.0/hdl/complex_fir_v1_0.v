
`timescale 1 ns / 1 ps

	module complex_fir_v1_0 #
	(
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 64,
		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 64,
		// Parameters of Axi Slave Bus Interface S01_AXIS
		parameter integer C_S01_AXIS_TDATA_WIDTH	= 64
	)
	(
	
		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,

		// Ports of Axi Slave Bus Interface S01_AXIS
		input wire  s01_axis_aclk,
		input wire  s01_axis_aresetn,
		output wire  s01_axis_tready,
		input wire [C_S01_AXIS_TDATA_WIDTH-1 : 0] s01_axis_tdata,
		input wire [(C_S01_AXIS_TDATA_WIDTH/8)-1 : 0] s01_axis_tstrb,
		input wire  s01_axis_tlast,
		input wire  s01_axis_tvalid,

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
	complex_fir_v1_0_M00_AXIS  # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH)
	) complex_filter_mult_v1_0_M00_AXIS_inst (
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN(m00_axis_aresetn),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TSTRB(m00_axis_tstrb),
		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TREADY(m00_axis_tready),
		
		.S0_AXIS_ACLK(s00_axis_aclk),
		.S0_AXIS_ARESETN(s00_axis_aresetn),
		.S0_AXIS_TREADY(s00_axis_tready),
		.S0_AXIS_TDATA(s00_axis_tdata),
		.S0_AXIS_TSTRB(s00_axis_tstrb),
		.S0_AXIS_TLAST(s00_axis_tlast),
		.S0_AXIS_TVALID(s00_axis_tvalid),
		
		.S1_AXIS_ACLK(s01_axis_aclk),
		.S1_AXIS_ARESETN(s01_axis_aresetn),
		.S1_AXIS_TREADY(s01_axis_tready),
		.S1_AXIS_TDATA(s01_axis_tdata),
		.S1_AXIS_TSTRB(s01_axis_tstrb),
		.S1_AXIS_TLAST(s01_axis_tlast),
		.S1_AXIS_TVALID(s01_axis_tvalid)
	);

	// Add user logic here

	// User logic ends

	endmodule
