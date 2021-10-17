`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2021 04:52:54 PM
// Design Name: 
// Module Name: adder_sim
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


module mult_sim();

//wire [31:0] S;
reg [31:0] saxi, bram, scale;

wire [63:0] mult_res;
wire[31:0] add_res, mult_res_sliced;

reg CLK;

assign mult_res_sliced = mult_res[55:24];

initial begin
bram = 32'h00001229;
saxi = 32'h0002bffc;
scale = 32'h96000000;

CLK = 1'b0;

end


always #10 CLK = ~CLK;


always @(posedge CLK) begin
    
    //if(CE) begin
        A = A + 'd1;
        B = B + 'd1;
    //end
end

mult_gen_0 mult (
  .CLK(CLK),  // input wire CLK
  .A(bram),      // input wire [31 : 0] A
  .B(scale),      // input wire [31 : 0] B
  .P(mult_res)      // output wire [63 : 0] P
);

c_addsub_0 adder(
  .A(mult_res_sliced),      // input wire [31 : 0] A
  .B(saxi),      // input wire [31 : 0] B
  .CLK(CLK),  // input wire CLK
  .S(add_res)      // output wire [31 : 0] S
); 
endmodule
