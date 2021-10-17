`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2021 04:32:26 PM
// Design Name: 
// Module Name: main_sim
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


module main_sim();

  wire [31:0]M00_AXIS_0_tdata;
  wire M00_AXIS_0_tlast;
  reg M00_AXIS_0_tready;
  wire [3:0]M00_AXIS_0_tstrb;
  wire M00_AXIS_0_tvalid;
 
  wire [10:0]addr_0;
 
  reg m00_axis_aclk_0;
  reg m00_axis_aresetn_0;


  initial begin
 
    m00_axis_aclk_0 = 1'b0;
    m00_axis_aresetn_0 = 1'b0;
    
    M00_AXIS_0_tready = 1'b0;
    
    #30
    M00_AXIS_0_tready = 1'b1;
    m00_axis_aresetn_0 = 1'b1;
      
    end
    
    
    always #10 m00_axis_aclk_0 = ~m00_axis_aclk_0;
  main main_i
       (.M00_AXIS_0_tdata(M00_AXIS_0_tdata),
        .M00_AXIS_0_tlast(M00_AXIS_0_tlast),
        .M00_AXIS_0_tready(M00_AXIS_0_tready),
        .M00_AXIS_0_tstrb(M00_AXIS_0_tstrb),
        .M00_AXIS_0_tvalid(M00_AXIS_0_tvalid),
        .M_AXIS_DATA_0_tdata(),
        .M_AXIS_DATA_0_tlast(),
        .M_AXIS_DATA_0_tready(),
        .M_AXIS_DATA_0_tvalid(),
        .addr_0(addr_0),
        .event_s_reload_tlast_missing_0(),
        .event_s_reload_tlast_unexpected_0(),
        .m00_axis_aclk_0(m00_axis_aclk_0),
        .m00_axis_aresetn_0(m00_axis_aresetn_0));
  
endmodule
