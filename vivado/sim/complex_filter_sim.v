`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/24/2021 06:11:59 PM
// Design Name: 
// Module Name: complex_filter_sim
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


module complex_filter_sim();

  wire [63:0]M00_AXIS_0_tdata;
  wire M00_AXIS_0_tlast;
  reg M00_AXIS_0_tready;
  wire M00_AXIS_0_tvalid;
  
  reg [63:0]S00_AXIS_0_tdata;
  reg S00_AXIS_0_tlast;
  wire S00_AXIS_0_tready;
  reg S00_AXIS_0_tvalid;
  
  reg  [63:0]S01_AXIS_0_tdata;
  reg S01_AXIS_0_tlast;
  wire S01_AXIS_0_tready;
  reg S01_AXIS_0_tvalid;
  
  reg s01_axis_aclk_0;
  reg s01_axis_aresetn_0;

  initial begin
  
    s01_axis_aclk_0 = 1'b0;
    s01_axis_aresetn_0 = 1'b0;
    
    M00_AXIS_0_tready = 1'b1;
    
    S00_AXIS_0_tdata = 64'h0000_0002_0000_0000;
    S00_AXIS_0_tlast = 1'b0;
    S00_AXIS_0_tvalid = 1'b0;
    
    S01_AXIS_0_tdata = 64'h0000_0001_0000_0000;
    S01_AXIS_0_tlast = 1'b0;
    S01_AXIS_0_tvalid = 1'b0;
    
    #70
    s01_axis_aresetn_0 = 1'b1;
    
    #60
    S00_AXIS_0_tvalid = 1'b1;
    S01_AXIS_0_tvalid = 1'b1;

  end
  
  
  always #10  s01_axis_aclk_0 = ~s01_axis_aclk_0;

  always @(posedge s01_axis_aclk_0) begin
    
        if (S00_AXIS_0_tvalid == 1'b1) begin
            S00_AXIS_0_tdata = S00_AXIS_0_tdata + 'd1;
            S01_AXIS_0_tdata = S01_AXIS_0_tdata + 'd1;
        end
        
        if(S00_AXIS_0_tdata == 64'h0000_0002_0000_0400) begin
            S00_AXIS_0_tlast = 1'b1;
            S01_AXIS_0_tlast = 1'b1;
            S00_AXIS_0_tdata = 64'h0000_0002_0000_0000;
            S01_AXIS_0_tdata = 64'h0000_0001_0000_0000;
            
        end else begin
            S00_AXIS_0_tlast = 1'b0;
            S01_AXIS_0_tlast = 1'b0;
        end
        
       
  end
  
  
  complex_filter complex_filter_i
       (.M00_AXIS_0_tdata(M00_AXIS_0_tdata),
        .M00_AXIS_0_tlast(M00_AXIS_0_tlast),
        .M00_AXIS_0_tready(M00_AXIS_0_tready),
        .M00_AXIS_0_tstrb(),
        .M00_AXIS_0_tvalid(M00_AXIS_0_tvalid),
        
        .S00_AXIS_0_tdata(S00_AXIS_0_tdata),
        .S00_AXIS_0_tlast(S00_AXIS_0_tlast),
        .S00_AXIS_0_tready(S00_AXIS_0_tready),
        .S00_AXIS_0_tstrb(),
        .S00_AXIS_0_tvalid(S00_AXIS_0_tvalid),
        
        .S01_AXIS_0_tdata(S01_AXIS_0_tdata),
        .S01_AXIS_0_tlast(S01_AXIS_0_tlast),
        .S01_AXIS_0_tready(S01_AXIS_0_tready),
        .S01_AXIS_0_tstrb(),
        .S01_AXIS_0_tvalid(S01_AXIS_0_tvalid),
        
        .s01_axis_aclk_0(s01_axis_aclk_0),
        .s01_axis_aresetn_0(s01_axis_aresetn_0));
endmodule
