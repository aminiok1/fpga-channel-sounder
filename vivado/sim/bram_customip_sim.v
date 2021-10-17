`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2021 01:12:45 PM
// Design Name: 
// Module Name: bram_customip_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bram_customip_sim();

wire [47:0] tdata;
wire tlast, tvalid;
reg clk, rst;
reg tready;

initial begin
clk = 1'b0;
rst = 1'b0;
tready = 1'b1;

#300
rst = 1'b1;

#100
tready = 1'b1;
//tready = 1'b1;

#22210
tready = 1'b1;

#300
tready = 1'b1;


end


always #10 clk = ~clk;


 bram_customip_wrapper dma
   (
    .M00_AXIS_0_tdata(tdata),
    .M00_AXIS_0_tlast(tlast),
    .M00_AXIS_0_tready(tready),
    .M00_AXIS_0_tstrb(),
    .M00_AXIS_0_tvalid(tvalid),
    .m00_axis_aclk_0(clk),
    .m00_axis_aresetn_0(rst)
     );

endmodule
