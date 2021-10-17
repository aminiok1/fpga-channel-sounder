`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2021 07:42:28 PM
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


  wire FIFO_READ_0_empty;
  wire [63:0]FIFO_READ_0_rd_data;
  reg [63:0] fifo_data;
  reg FIFO_READ_0_rd_en;
  
  wire FIFO_WRITE_0_full;
  reg [31:0]FIFO_WRITE_0_wr_data;
  reg FIFO_WRITE_0_wr_en;
  reg clk_0;

  initial begin
  clk_0 = 1'b0;
  FIFO_WRITE_0_wr_data = 32'd0;
  FIFO_WRITE_0_wr_en = 1'b0;
  
  fifo_data = 64'd0;
  #30
  FIFO_WRITE_0_wr_en = 1'b1;
  end
  
  always #10 clk_0 = ~clk_0;
  
  always @(posedge clk_0) begin
  
      fifo_data <= FIFO_READ_0_rd_data;
      FIFO_WRITE_0_wr_data = FIFO_WRITE_0_wr_data + 32'd1;
      if (FIFO_READ_0_empty == 1'b0)
            FIFO_READ_0_rd_en = 1'b1;
       else
            FIFO_READ_0_rd_en = 1'b0;
  end
  
  fifo fifo_1
       (.FIFO_READ_0_empty(FIFO_READ_0_empty),
        .FIFO_READ_0_rd_data(FIFO_READ_0_rd_data),
        .FIFO_READ_0_rd_en(FIFO_READ_0_rd_en),
        .FIFO_WRITE_0_full(FIFO_WRITE_0_full),
        .FIFO_WRITE_0_wr_data(FIFO_WRITE_0_wr_data),
        .FIFO_WRITE_0_wr_en(FIFO_WRITE_0_wr_en),
        .clk_0(clk_0));
endmodule
