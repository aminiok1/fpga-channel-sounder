`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2021 02:32:05 PM
// Design Name: 
// Module Name: noise_generator_sim
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


module noise_generator_sim();


  wire [63:0]M00_AXIS_0_tdata;
  wire M00_AXIS_0_tlast;
  reg M00_AXIS_0_tready;
  wire M00_AXIS_0_tvalid;
  
  reg [63:0]S00_AXIS_0_tdata;
  reg S00_AXIS_0_tlast;
  wire S00_AXIS_0_tready;
  reg S00_AXIS_0_tvalid;
  
  reg m00_axis_aclk_0;
  reg m00_axis_aresetn_0;
  
  reg [31:0] scale_factor_0;
  
  reg [10:0] ctr;
    
initial begin
m00_axis_aclk_0 = 1'b0;
m00_axis_aresetn_0 = 1'b0;

M00_AXIS_0_tready = 1'b1;

S00_AXIS_0_tdata = 64'd0;
S00_AXIS_0_tlast = 1'b0;
S00_AXIS_0_tvalid = 1'b0;

scale_factor_0 = 32'h00000002;

ctr = 'd0;

#110
m00_axis_aresetn_0 = 1'b1;
S00_AXIS_0_tvalid = 1'b1;

//#80


//#400
//M00_AXIS_0_tready = 1'b0;

//#600
//M00_AXIS_0_tready = 1'b1;
end

always #10 m00_axis_aclk_0 = ~m00_axis_aclk_0;

always @(posedge m00_axis_aclk_0) begin

        if (m00_axis_aresetn_0) begin
            if (!M00_AXIS_0_tready)
                S00_AXIS_0_tdata = S00_AXIS_0_tdata;
                
            else if ((S00_AXIS_0_tdata < 1024 + 16)) begin
                S00_AXIS_0_tdata = S00_AXIS_0_tdata + 32'd1;
                
             end else begin
                S00_AXIS_0_tdata = 32'd0;
             end
                
            if (S00_AXIS_0_tvalid || ctr == 1024+16 )
                ctr = ctr + 'd1;
            
            if(ctr == 1024 + 16)
                S00_AXIS_0_tlast = 1'b1;
            else
                S00_AXIS_0_tlast = 1'b0;
    
            if (ctr == 1024+16)
               ctr = 'd0;
         end
            
end

   noise_generator noise_generator_i
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
        .scale_factor_0(scale_factor_0));
endmodule
