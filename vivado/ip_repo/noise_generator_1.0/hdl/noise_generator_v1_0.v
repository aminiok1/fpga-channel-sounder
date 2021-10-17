
`timescale 1 ns / 1 ps

	module noise_generator_v1_0 #
	(
		// Users to add parameters here
        parameter integer BRAM_DEPTH_BITS = 11,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 64,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 64
	)
	(
		// Users to add ports here
        output wire [BRAM_DEPTH_BITS-1:0] bram_addr,
        input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] bram_datain,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,

		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready,
		
		input wire [31:0]scale_factor
	);
// Instantiation of Axi Bus Interface S00_AXIS
//	noise_generator_v1_0_S00_AXIS # ( 
//		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
//	) noise_generator_v1_0_S00_AXIS_inst (
//		.S_AXIS_ACLK(s00_axis_aclk),
//		.S_AXIS_ARESETN(s00_axis_aresetn),
//		.S_AXIS_TREADY(s00_axis_tready),
//		.S_AXIS_TDATA(s00_axis_tdata),
//		.S_AXIS_TSTRB(s00_axis_tstrb),
//		.S_AXIS_TLAST(s00_axis_tlast),
//		.S_AXIS_TVALID(s00_axis_tvalid)
//	);

// Instantiation of Axi Bus Interface M00_AXIS
	noise_generator_v1_0_M00_AXIS # (
		.BRAM_DEPTH_BITS(BRAM_DEPTH_BITS),
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH)
	) noise_generator_v1_0_M00_AXIS_inst (
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN(m00_axis_aresetn),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TSTRB(m00_axis_tstrb),
		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TREADY(m00_axis_tready),
		
		.FIR_AXIS_TVALID(s00_axis_tvalid),
        .FIR_AXIS_TLAST(s00_axis_tlast),
        .FIR_AXIS_TDATA(s00_axis_tdata),
        
        .BRAM_ADDR(bram_addr),
        .BRAM_DATAIN(bram_datain),
        
        .SCALE_FACTOR(scale_factor)
	);

	// Add user logic here
	// If the downstream module (FFT) is not ready to accept data, noise generator stops receiving new data
    assign s00_axis_tready = m00_axis_tready;
	// User logic ends

	endmodule
