`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2021 12:37:09 PM
// Design Name: 
// Module Name: accumulator_sim
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


module accumulator_sim();

  reg [95:0]S00_AXIS_0_tdata;
  reg S00_AXIS_0_tlast;
  wire S00_AXIS_0_tready;
  reg S00_AXIS_0_tvalid;
  
  wire [9:0]result_bram_addr_write_0;
  wire [63:0]result_bram_dataout_0;
  wire result_bram_w_enable_0;
    
  reg s00_axis_aclk_0;
  reg s00_axis_aresetn_0;
  
  initial begin
    s00_axis_aclk_0 = 1'b0;
    s00_axis_aresetn_0 = 1'b0;
    S00_AXIS_0_tvalid = 1'b0;
    S00_AXIS_0_tlast = 1'b0;
    S00_AXIS_0_tdata = 'd0;
    
    #70
    s00_axis_aresetn_0 = 1'b1;
    
    #80
    S00_AXIS_0_tvalid = 1'b1;
    
  end

  always #10 s00_axis_aclk_0 = ~s00_axis_aclk_0;
  
  
  always @(posedge s00_axis_aclk_0) begin
    if (S00_AXIS_0_tvalid) begin
        
        if (S00_AXIS_0_tlast) begin
            S00_AXIS_0_tlast = 1'b0;
            S00_AXIS_0_tdata = 96'h0000_0000_0400_0000_0000_0400;
            
        end else begin
            S00_AXIS_0_tdata = S00_AXIS_0_tdata + 96'h0000_0000_0400_0000_0000_0400;
   
        end
        
        if (S00_AXIS_0_tdata == 96'h0000_0010_0000_0000_0010_0000)
            S00_AXIS_0_tlast = 1'b1;
        
    end
  end
  
  accumulator accumulator_i
       (.S00_AXIS_0_tdata(S00_AXIS_0_tdata),
        .S00_AXIS_0_tlast(S00_AXIS_0_tlast),
        .S00_AXIS_0_tready(S00_AXIS_0_tready),
        .S00_AXIS_0_tstrb(),
        .S00_AXIS_0_tvalid(S00_AXIS_0_tvalid),
        .result_bram_addr_write_0(result_bram_addr_write_0),
        .result_bram_dataout_0(result_bram_dataout_0),
        .result_bram_w_enable_0(result_bram_w_enable_0),
        .s00_axis_aclk_0(s00_axis_aclk_0),
        .s00_axis_aresetn_0(s00_axis_aresetn_0));
        
endmodule
