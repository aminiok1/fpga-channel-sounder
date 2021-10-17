`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2021 12:21:12 AM
// Design Name: 
// Module Name: bit_shift
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


    module bit_shift #
    (
            parameter integer IN_WIDTH = 13,
            parameter integer OUT_WIDTH = 11
    )
    (
            input wire [IN_WIDTH:0] data_in,
            output wire [OUT_WIDTH:0] data_out
    );
        
        wire [IN_WIDTH:0] shift_temp;
    
        assign shift_temp = data_in >> 2;
        assign data_out = shift_temp[OUT_WIDTH:0]; 

endmodule
