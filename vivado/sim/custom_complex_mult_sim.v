`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2021 01:53:57 PM
// Design Name: 
// Module Name: custom_complex_mult_sim
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


module custom_complex_mult_sim();

  wire [63:0]M00_AXIS_0_tdata;
  wire M00_AXIS_0_tlast;
  reg M00_AXIS_0_tready;
  wire M00_AXIS_0_tvalid;
  
  reg [95:0]S00_AXIS_0_tdata;
  reg S00_AXIS_0_tlast;
  wire S00_AXIS_0_tready;
  reg S00_AXIS_0_tvalid;
  
  reg m00_axis_aclk_0;
  reg m00_axis_aresetn_0;
  
  wire [9:0]bram_addr_0;
 // wire [63:0]doutb_0;
  
  reg [7:0] ctr;
  initial begin
  
    m00_axis_aclk_0 = 1'b0;
    m00_axis_aresetn_0 = 1'b0;
    
    ctr = 'd0;
    
    S00_AXIS_0_tdata = 'd0;
    S00_AXIS_0_tlast = 1'b0;
    S00_AXIS_0_tvalid = 1'b0;
    
    M00_AXIS_0_tready = 1'b1;
    
    #50
    m00_axis_aresetn_0 = 1'b1;
    
    #20
    S00_AXIS_0_tvalid = 1'b1;
    
  end
  
  always #10 m00_axis_aclk_0 = ~m00_axis_aclk_0;
  
  always @(posedge m00_axis_aclk_0) begin
  
    if(S00_AXIS_0_tdata == 'd1024) begin
        S00_AXIS_0_tvalid = 1'b0;
        ctr = ctr + 'd1;
    end
    
    if (ctr == 65) begin
        ctr = 'd0;
        S00_AXIS_0_tvalid = 1'b1;
        S00_AXIS_0_tdata = 'd0;
    end
        
    if(S00_AXIS_0_tvalid == 1)
        S00_AXIS_0_tdata = S00_AXIS_0_tdata + 'd1;
  
  end
  
  
  custom_complex_mult custom_complex_mult_i
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
        .m00_axis_aclk_0(m00_axis_aclk_0),
        .m00_axis_aresetn_0(m00_axis_aresetn_0),
        .bram_addr_0(bram_addr_0)//,
        //.doutb_0(doutb_0)
        );
endmodule
