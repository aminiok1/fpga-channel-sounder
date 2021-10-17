
`timescale 1 ns / 1 ps

	module custom_complex_mult_v1_0 #
	(

        parameter integer BRAM_DEPTH_BITS = 10,
        
		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 96,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 64
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

		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready,
		
		output wire [BRAM_DEPTH_BITS-1:0] bram_addr,
        input wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] bram_datain
	);
// Instantiation of Axi Bus Interface S00_AXIS
	custom_complex_mult_v1_0_S00_AXIS # ( 
	    .BRAM_DEPTH_BITS(BRAM_DEPTH_BITS),
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH)
	) custom_complex_mult_v1_0_S00_AXIS_inst (
		.S_AXIS_ACLK(s00_axis_aclk),
		.S_AXIS_ARESETN(s00_axis_aresetn),
		.S_AXIS_TREADY(s00_axis_tready),
		.S_AXIS_TDATA(s00_axis_tdata),
		.S_AXIS_TSTRB(s00_axis_tstrb),
		.S_AXIS_TLAST(s00_axis_tlast),
		.S_AXIS_TVALID(s00_axis_tvalid),
		
		.BRAM_ADDR(bram_addr),
        .BRAM_DATAIN(bram_datain),
        
        .MAXI_CLK(m00_axis_aclk),
        .MAXI_RST(m00_axis_aresetn),
        .MAXI_VALID(m00_axis_tvalid),
        .MAXI_LAST(m00_axis_tlast),
        .MAXI_READY(m00_axis_tready),
        .MAXI_DATA(m00_axis_tdata),
        .MAXI_TSTRB(m00_axis_tstrb)
	);

	endmodule
