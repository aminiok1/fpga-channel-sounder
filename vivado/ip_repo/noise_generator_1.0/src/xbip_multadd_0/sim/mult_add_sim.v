`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2021 05:11:35 PM
// Design Name: 
// Module Name: mult_add_sim
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


module mult_add_sim();
    reg CLK;
    reg [31:0] A, B, C;
    wire [63:0] P;
    
    reg valid;
    
    initial begin
    
        CLK = 1'b0;
        A = 'd0;
        B = 'd0;
        C = 'd0;
        
        valid = 1'b0;
        
        #70
        valid = 1'b1;
   end
   
   always #10 CLK = ~CLK;
   
   always @(posedge CLK) begin
   
        if (valid) begin
            B = 32'h00008000;
            A = A + 32'h00010000;
            C = C + 32'h00020000;
        end
   end
   
   
    
xbip_multadd_0 multadd (
  .CLK(CLK),            // input wire CLK
  .CE(1'b1),              // input wire CE
  .SCLR(1'b0),          // input wire SCLR
  .A(A),                // input wire [31 : 0] A
  .B(B),                // input wire [31 : 0] B
  .C(C),                // input wire [31 : 0] C
  .SUBTRACT(1'b0),  // input wire SUBTRACT
  .P(P),                // output wire [31 : 0] P
  .PCOUT()        // output wire [47 : 0] PCOUT
);

endmodule
