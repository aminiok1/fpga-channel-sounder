
`timescale 1 ns / 1 ps

	module stream_to_bram_fft_v1_0 #
	(
		// Users to add parameters here
         parameter integer BRAM_DEPTH = 10,
        parameter integer BRAM_DATA_WIDTH = 64,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 96
	)
	(
		// Users to add ports here
        output wire [BRAM_DEPTH-1 : 0] bram_addr,
		output wire [BRAM_DATA_WIDTH-1 : 0] bram_dataout,
		output wire bram_w_enable,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid
	);
// Instantiation of Axi Bus Interface S00_AXIS
	stream_to_bram_fft_v1_0_S00_AXIS # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
		.BRAM_DEPTH(BRAM_DEPTH),
        .BRAM_DATA_WIDTH(BRAM_DATA_WIDTH)
	) stream_to_bram_fft_v1_0_S00_AXIS_inst (
		.S_AXIS_ACLK(s00_axis_aclk),
		.S_AXIS_ARESETN(s00_axis_aresetn),
		.S_AXIS_TREADY(s00_axis_tready),
		.S_AXIS_TDATA(s00_axis_tdata),
		.S_AXIS_TSTRB(s00_axis_tstrb),
		.S_AXIS_TLAST(s00_axis_tlast),
		.S_AXIS_TVALID(s00_axis_tvalid),
		
		.BRAM_ADDR(bram_addr),
		.BRAM_DATAOUT(bram_dataout),
		.BRAM_W_ENABLE(bram_w_enable)
	);

	// Add user logic here

	// User logic ends

	endmodule
