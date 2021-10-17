`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/06/2021 12:15:32 PM
// Design Name: 
// Module Name: dsp_sim
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


module dsp_sim();

  wire [31:0]M_AXIS_DATA_0_tdata;
  wire M_AXIS_DATA_0_tlast;
  reg M_AXIS_DATA_0_tready;
  wire M_AXIS_DATA_0_tvalid;
  
  reg [15:0]S_AXIS_DATA_0_tdata;
  reg S_AXIS_DATA_0_tlast;
  wire S_AXIS_DATA_0_tready;
  reg S_AXIS_DATA_0_tvalid;
  
  reg [7:0] ctr;
  
  reg aclk_0;
  reg aresetn_0;

initial begin
aclk_0 = 1'b0;
aresetn_0 = 1'b1;
ctr = 8'd0;

M_AXIS_DATA_0_tready = 1'b1;

S_AXIS_DATA_0_tdata = 16'd0;
S_AXIS_DATA_0_tlast = 1'b0;
S_AXIS_DATA_0_tvalid = 1'b1;

end

always #10 aclk_0 = ~aclk_0;

always @(posedge aclk_0) begin

     if (ctr <= 8'd31)
        S_AXIS_DATA_0_tdata = ctr;
    else
      S_AXIS_DATA_0_tdata = 16'd0;
      
    
    if (S_AXIS_DATA_0_tready) begin
        ctr = ctr + 8'd1;
        S_AXIS_DATA_0_tvalid = 1'b1;
    end
          
    if (ctr == 8'd40 || ctr == 8'd39) begin
        S_AXIS_DATA_0_tlast = 1'b1;
    end else begin
        S_AXIS_DATA_0_tlast = 1'b0;
    end
    
    if (ctr == 8'd40)
        ctr = 8'd0;
    
        
end
  simul_test simul_test_1
       (.M_AXIS_DATA_0_tdata(M_AXIS_DATA_0_tdata),
        .M_AXIS_DATA_0_tlast(M_AXIS_DATA_0_tlast),
        .M_AXIS_DATA_0_tready(M_AXIS_DATA_0_tready),
        .M_AXIS_DATA_0_tvalid(M_AXIS_DATA_0_tvalid),
        .S_AXIS_DATA_0_tdata(S_AXIS_DATA_0_tdata),
        .S_AXIS_DATA_0_tlast(S_AXIS_DATA_0_tlast),
        .S_AXIS_DATA_0_tready(S_AXIS_DATA_0_tready),
        .S_AXIS_DATA_0_tvalid(S_AXIS_DATA_0_tvalid),
        .aclk_0(aclk_0),
        .aresetn_0(aresetn_0));
endmodule
