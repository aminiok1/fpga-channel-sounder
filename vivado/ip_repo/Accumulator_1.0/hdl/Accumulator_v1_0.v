
`timescale 1 ns / 1 ps

	module Accumulator_v1_0 #
	(
		parameter integer BRAM_DEPTH = 10,
        parameter integer ACC_BRAM_DATA_WIDTH = 128,
        parameter integer RES_BRAM_DATA_WIDTH = 64,
		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 96
	)
	(
		 // scratchpad BRAM used to store intermidiate results of accumulator
		output wire [BRAM_DEPTH-1 : 0] acc_bram_addr_read,
		output wire [BRAM_DEPTH-1 : 0] acc_bram_addr_write,
		output wire [ACC_BRAM_DATA_WIDTH-1 : 0] acc_bram_dataout,
		input wire [ACC_BRAM_DATA_WIDTH-1 : 0] acc_bram_datain,
		output wire acc_bram_w_enable,
		
		// result BRAM stores the results after every 128 accumulation
		output wire [BRAM_DEPTH-1 : 0] result_bram_addr_write,
		output wire [RES_BRAM_DATA_WIDTH-1 : 0] result_bram_dataout,
		output wire result_bram_w_enable,
		
		input wire [15:0] accumulate_count,

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
	Accumulator_v1_0_S00_AXIS # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
		.ACC_BRAM_DATA_WIDTH(ACC_BRAM_DATA_WIDTH),
        .RES_BRAM_DATA_WIDTH(RES_BRAM_DATA_WIDTH)
	) Accumulator_v1_0_S00_AXIS_inst (
		.S_AXIS_ACLK(s00_axis_aclk),
		.S_AXIS_ARESETN(s00_axis_aresetn),
		.S_AXIS_TREADY(s00_axis_tready),
		.S_AXIS_TDATA(s00_axis_tdata),
		.S_AXIS_TSTRB(s00_axis_tstrb),
		.S_AXIS_TLAST(s00_axis_tlast),
		.S_AXIS_TVALID(s00_axis_tvalid),
		
		.ACCUMULATE_COUNT(accumulate_count),
		
		.ACC_BRAM_ADDR_READ(acc_bram_addr_read),
		.ACC_BRAM_ADDR_WRITE(acc_bram_addr_write),
		.ACC_BRAM_DATAOUT(acc_bram_dataout),
		.ACC_BRAM_DATAIN(acc_bram_datain),
		.ACC_BRAM_WENABLE(acc_bram_w_enable),
		
		.RESULT_BRAM_ADDR_WRITE(result_bram_addr_write),
		.RESULT_BRAM_DATAOUT(result_bram_dataout),
		.RESULT_BRAM_WENABLE(result_bram_w_enable)
	);

	// Add user logic here

	// User logic ends

	endmodule
