`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2021 07:07:32 PM
// Design Name: 
// Module Name: fft_sim
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


module fft_sim();

wire [31:0] data_out_real;
wire [31:0] data_out_imag;

wire [63:0]data_out;
wire [15:0] data_out_user;
wire data_out_last, data_out_valid;
reg data_out_ready;

wire [7:0] status_data;
wire status_valid;
reg status_ready;

reg [63:0] data_complex[0:7];
reg [63:0] data_in;
reg data_in_last, data_in_valid;
wire data_in_ready;

reg [7:0] config_data;
reg config_valid;

reg clk;

wire event_data_in_channel_halt_0, event_data_out_channel_halt_0, event_frame_started_0, event_status_channel_halt_0;
wire event_tlast_missing_0, event_tlast_unexpected_0, s_axis_config_tready_0;

localparam S_START = 3'd0,
           S_SEND  = 3'd1,
           S_DONE  = 3'd2;

reg [2:0] c_state;
reg [7:0] ctr;

assign data_out_real = data_out[31:0];
assign data_out_imag = data_out[63:32];

initial begin

clk = 1'b0;
data_out_ready = 1'b1;
data_in_last = 1'b0;
data_in_valid = 1'b0;

config_valid = 1'b1;
config_data = 8'b0000_0000;

status_ready = 1'b1;

c_state = S_START;
ctr = 8'd0;

data_complex[0] = 64'h000000003f800000;
data_complex[1] = 64'hbf641901bee87171;
data_complex[2] = 64'h3f4f1bbdbf167918;
data_complex[3] = 64'h3e20305b3f7cd925;
data_complex[4] = 64'hbf737871be9e377a;
data_complex[5] = 64'h3f3504f3bf3504f3;
data_complex[6] = 64'h3e9e377a3f737871;
data_complex[7] = 64'hbf7cd925be20305b;
end

always #1 clk = ~clk;

always @ (posedge clk) begin
    
    case (c_state)
        
        S_START: begin
            if (data_in_ready && ctr == 8'd2) begin
                c_state = S_SEND;
                ctr = 8'd0;
            end else begin
                ctr = ctr + 8'd1;
            end
        end
        
        S_SEND: begin
            
            config_valid = 1'b0;
            if (ctr == 8'd8) begin
                c_state = S_DONE;
                data_in_valid = 1'b0;
            end else begin
                data_in_valid = 1'b1;
                //data_in[63: 32] = {24'd0, ctr} + 32'd1;
                //data_in[31: 0] = {24'd0, ctr} + 32'd1;
                data_in = data_complex[ctr];
                ctr = ctr + 8'b0001;
                if (ctr == 8'd8) begin
                    data_in_last = 1'b1;
                end
            end
            
        end
        
        S_DONE: begin
            if (ctr == 8'd100) begin
                ctr = 8'd0;
                data_in_last = 1'b0;
                c_state = S_START;
                config_valid = 1'b1;
            end else begin
                ctr = ctr + 8'd1;
                c_state = S_DONE;
            end
            //data_in_last = 1'b0;
        end
    endcase
end

fft_wrapper fft_wrapper_0
   (.M_AXIS_DATA_0_tdata(data_out),
    .M_AXIS_DATA_0_tlast(data_out_last),
    .M_AXIS_DATA_0_tready(data_out_ready),
    .M_AXIS_DATA_0_tvalid(data_out_valid),
    .M_AXIS_DATA_0_tuser(data_out_user),
    
    .M_AXIS_STATUS_0_tdata(status_data),
    .M_AXIS_STATUS_0_tready(status_ready),
    .M_AXIS_STATUS_0_tvalid(status_valid),
    
    .S_AXIS_DATA_0_tdata(data_in),
    .S_AXIS_DATA_0_tlast(data_in_last),
    .S_AXIS_DATA_0_tready(data_in_ready),
    .S_AXIS_DATA_0_tvalid(data_in_valid),
    
    .aclk_0(clk),
    
    .event_data_in_channel_halt_0(event_data_in_channel_halt_0),
    .event_data_out_channel_halt_0(event_data_out_channel_halt_0),
    .event_frame_started_0(event_frame_started_0),
    .event_status_channel_halt_0(event_status_channel_halt_0),
    .event_tlast_missing_0(event_tlast_missing_0),
    .event_tlast_unexpected_0(event_tlast_unexpected_0),
    
    .S_AXIS_CONFIG_0_tdata(config_data),
    .S_AXIS_CONFIG_0_tvalid(config_valid),
    .S_AXIS_CONFIG_0_tready(s_axis_config_tready_0));
    
endmodule
