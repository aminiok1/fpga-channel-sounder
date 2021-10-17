`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/18/2021 10:36:01 AM
// Design Name: 
// Module Name: fifo_sim
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


module fifo_sim();

reg s_axis_aresetn;
reg s_axis_aclk;

reg s_axis_tvalid, s_axis_tlast;
reg [63:0] s_axis_tdata;

wire s_axis_tready, m_axis_tvalid, m_axis_tlast;
reg m_axis_tready;
wire [63:0] m_axis_tdata;

initial begin

s_axis_aresetn = 1'b0;
s_axis_aclk = 1'b0;

s_axis_tvalid = 1'b0;
s_axis_tlast = 1'b0;
s_axis_tdata = 'd0;

m_axis_tready = 1'b0;

#90
s_axis_aresetn = 1'b1;

#20
s_axis_tvalid = 1'b1;
m_axis_tready = 1'b1;


end


always #10 s_axis_aclk = ~s_axis_aclk;

always @(posedge s_axis_aclk) begin

    if (s_axis_tvalid) begin
        s_axis_tdata = s_axis_tdata + 'd1;
        
    end
    
    if (s_axis_tdata % 'd1024 == 0 && s_axis_tdata != 'd0)
        s_axis_tlast = 1'b1;
    else
        s_axis_tlast = 1'b0;
    
end

axis_data_fifo_0 fifo (
  .s_axis_aresetn(s_axis_aresetn),  // input wire s_axis_aresetn
  .s_axis_aclk(s_axis_aclk),        // input wire s_axis_aclk
  .s_axis_tvalid(s_axis_tvalid),    // input wire s_axis_tvalid
  .s_axis_tready(s_axis_tready),    // output wire s_axis_tready
  .s_axis_tdata(s_axis_tdata),      // input wire [63 : 0] s_axis_tdata
  .s_axis_tlast(s_axis_tlast),      // input wire s_axis_tlast
  .m_axis_tvalid(m_axis_tvalid),    // output wire m_axis_tvalid
  .m_axis_tready(m_axis_tready),    // input wire m_axis_tready
  .m_axis_tdata(m_axis_tdata),      // output wire [63 : 0] m_axis_tdata
  .m_axis_tlast(m_axis_tlast)      // output wire m_axis_tlast
);
endmodule
