
`timescale 1 ns / 1 ps

	module bram_to_stream_dual_v1_0 #
	(
		parameter integer BRAM_DEPTH_BITS = 10,
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 48,
		parameter integer BRAM_TDATA_WIDTH	= 64
	)
	(
	
        output wire [BRAM_DEPTH_BITS-1:0] bram_addr,
        input wire [BRAM_TDATA_WIDTH-1 : 0] bram_datain,
		
		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready,

		// Ports of Axi Master Bus Interface M01_AXIS
		input wire  m01_axis_aclk,
		input wire  m01_axis_aresetn,
		output wire  m01_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m01_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m01_axis_tstrb,
		output wire  m01_axis_tlast,
		input wire  m01_axis_tready
	);
// Instantiation of Axi Bus Interface M00_AXIS
	bram_to_stream_dual_v1_0_M00_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH)
	) bram_to_stream_dual_v1_0_M00_AXIS_inst (
		.M0_AXIS_ACLK(m00_axis_aclk),
		.M0_AXIS_ARESETN(m00_axis_aresetn),
		.M0_AXIS_TVALID(m00_axis_tvalid),
		.M0_AXIS_TDATA(m00_axis_tdata),
		.M0_AXIS_TSTRB(m00_axis_tstrb),
		.M0_AXIS_TLAST(m00_axis_tlast),
		.M0_AXIS_TREADY(m00_axis_tready),
		
		.M1_AXIS_ACLK(m01_axis_aclk),
		.M1_AXIS_ARESETN(m01_axis_aresetn),
		.M1_AXIS_TVALID(m01_axis_tvalid),
		.M1_AXIS_TDATA(m01_axis_tdata),
		.M1_AXIS_TSTRB(m01_axis_tstrb),
		.M1_AXIS_TLAST(m01_axis_tlast),
		.M1_AXIS_TREADY(m01_axis_tready),
		
		.BRAM_ADDR(bram_addr),
        .BRAM_DATAIN(bram_datain)
		
	);



	endmodule
