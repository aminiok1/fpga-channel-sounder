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


module adder_sim();

//wire [31:0] S;
wire [63:0] P;
reg [31:0] A, B;
reg CLK;

initial begin
A = 'd0;
B = 'd0;
valid = 1'b0;

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
  .A(A),      // input wire [31 : 0] A
  .B(B),      // input wire [31 : 0] B
  .P(P)      // output wire [63 : 0] P
);

/*c_addsub_0 adder(
  .A(A),      // input wire [31 : 0] A
  .B(B),      // input wire [31 : 0] B
  .CLK(CLK),  // input wire CLK
  .CE(CE),    // input wire CE
  .S(S)      // output wire [31 : 0] S
); */
endmodule
