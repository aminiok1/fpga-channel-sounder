`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2021 03:53:35 PM
// Design Name: 
// Module Name: stream2bram_sim
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


module stream2bram_sim();

  reg [63:0]S00_AXIS_0_tdata;
  reg S00_AXIS_0_tlast;
  wire S00_AXIS_0_tready;
  reg S00_AXIS_0_tvalid;
  
  reg [11:0]addra_0;
  wire [31:0]douta_0;
  reg ena_0;
  
  reg s00_axis_aclk_0;
  reg s00_axis_aresetn_0;

  wire bram_w_enable_0;
  wire [10:0] bram_addr_0;
  
  initial begin
        s00_axis_aclk_0 = 1'b0;
        s00_axis_aresetn_0 = 1'b0;
        
        S00_AXIS_0_tvalid = 1'b0;
        S00_AXIS_0_tlast = 1'b0;
        S00_AXIS_0_tdata = 'd0;
        
        addra_0 = 'd0;
        ena_0 = 1'b0;
        
        #300
        s00_axis_aresetn_0 = 1'b1;
        
        #90
        S00_AXIS_0_tvalid = 1'b1;
        
        #60
        ena_0 = 1'b1;
        
  end
  
  always #10 s00_axis_aclk_0 = ~s00_axis_aclk_0;
  
  always @(posedge s00_axis_aclk_0) begin
    
        if (s00_axis_aresetn_0)
            S00_AXIS_0_tdata =  S00_AXIS_0_tdata + 1;
        
        if (S00_AXIS_0_tdata == 1024 + 32 + 5) begin 
            S00_AXIS_0_tvalid = 1'b0;
            S00_AXIS_0_tlast = 1'b1;
        end else begin
            S00_AXIS_0_tvalid = 1'b1;
            S00_AXIS_0_tlast = 1'b0;
        end
        
        if (S00_AXIS_0_tdata == 1024 + 32 + 5) 
            S00_AXIS_0_tdata = 'd0;
            
            
        if (ena_0)
            addra_0 = addra_0 + 'd1;
        
        if (addra_0 == 1024 + 32)
            addra_0 = 'd0;
            
            
  
  end

    stream2bram stream2bram_i
       (.S00_AXIS_0_tdata(S00_AXIS_0_tdata),
        .S00_AXIS_0_tlast(S00_AXIS_0_tlast),
        .S00_AXIS_0_tready(S00_AXIS_0_tready),
        .S00_AXIS_0_tstrb(),
        .bram_w_enable_0(bram_w_enable_0),
        .bram_addr_0(bram_addr_0),
        .S00_AXIS_0_tvalid(S00_AXIS_0_tvalid),
        .addra_0(addra_0),
        .douta_0(douta_0),
        .ena_0(ena_0),
        .s00_axis_aclk_0(s00_axis_aclk_0),
        .s00_axis_aresetn_0(s00_axis_aresetn_0));
  
/*
  reg [95:0]S00_AXIS_0_tdata;
  reg S00_AXIS_0_tlast;
  wire S00_AXIS_0_tready;
  reg S00_AXIS_0_tvalid;
  
  wire [9:0] A_addr;
  wire A_we;
  wire[63:0] A_data;
  
  reg [10:0]addrb_0;
  wire [31:0]doutb_0;
  reg enb_0;
  reg s00_axis_aclk_0;
  
  reg s00_axis_aresetn_0;
  
  reg [31:0] ctr1;
  reg [31:0] ctr2;
  
 
  initial begin
      s00_axis_aclk_0 = 0;
      s00_axis_aresetn_0 = 0;
      S00_AXIS_0_tdata = 0;
      
      enb_0 = 0;
      addrb_0 = 0;
      
      S00_AXIS_0_tvalid = 0;
      S00_AXIS_0_tlast = 0;
      
      ctr1 = 32'd0;
      ctr2 = 32'h0000_1000;
      
      #30
      s00_axis_aresetn_0 = 1;
      
      #60
      S00_AXIS_0_tvalid = 1;
      
      #100
      enb_0 = 1;
      
  end 
  
  always #10 s00_axis_aclk_0 = ~s00_axis_aclk_0;
  
  always @(posedge s00_axis_aclk_0) begin
         S00_AXIS_0_tdata[90:59] = ctr2; 
         S00_AXIS_0_tdata[42:11] = ctr1;
         
         if (S00_AXIS_0_tvalid) begin
            if (ctr1 < 1023) begin
                ctr1 = ctr1 + 1;
                ctr2 = ctr2 + 1;
                S00_AXIS_0_tlast = 0;
            end else begin
                ctr1 = 32'd0;
                ctr2 = 32'h0000_1000;
                S00_AXIS_0_tlast = 1;
            end
         end
         
         if (enb_0)
            addrb_0 = addrb_0 + 1;

  end
  
  stream2bram stream2bram_i
          (.S00_AXIS_0_tdata(S00_AXIS_0_tdata),
        .S00_AXIS_0_tlast(S00_AXIS_0_tlast),
        .S00_AXIS_0_tready(S00_AXIS_0_tready),
        .S00_AXIS_0_tstrb(),
        .S00_AXIS_0_tvalid(S00_AXIS_0_tvalid),
        .addr_0(A_addr),
        .addrb_0(addrb_0),
        .dataout_0(A_data),
        .doutb_0(doutb_0),
        .enb_0(enb_0),
        .s00_axis_aclk_0(s00_axis_aclk_0),
        .s00_axis_aresetn_0(s00_axis_aresetn_0),
        .wenable_0(A_we));
        
        */
endmodule
