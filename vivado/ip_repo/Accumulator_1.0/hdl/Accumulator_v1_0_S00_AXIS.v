`timescale 1 ns / 1 ps

	module Accumulator_v1_0_S00_AXIS #
	(
		parameter integer BRAM_DEPTH = 10,
        parameter integer ACC_BRAM_DATA_WIDTH = 128,
        parameter integer RES_BRAM_DATA_WIDTH = 64,
        
        parameter integer ADDER_DATA_WIDTH = 48,
		// AXI4Stream sink: Data Width
		parameter integer C_S_AXIS_TDATA_WIDTH	= 96
	)
	(
	    // scratchpad BRAM used to store intermidiate results of accumulator
		output wire [BRAM_DEPTH-1 : 0] ACC_BRAM_ADDR_READ,
		output wire [BRAM_DEPTH-1 : 0] ACC_BRAM_ADDR_WRITE,
		output wire [ACC_BRAM_DATA_WIDTH-1 : 0] ACC_BRAM_DATAOUT,
		input wire [ACC_BRAM_DATA_WIDTH-1 : 0] ACC_BRAM_DATAIN,
		output wire ACC_BRAM_WENABLE,
		
		input wire [15:0] ACCUMULATE_COUNT,
		
		// result BRAM stores the results after every 128 accumulation
		output wire [BRAM_DEPTH-1 : 0] RESULT_BRAM_ADDR_WRITE,
		output wire [RES_BRAM_DATA_WIDTH-1 : 0] RESULT_BRAM_DATAOUT,
		output wire RESULT_BRAM_WENABLE,

		// AXI4Stream sink: Clock
		input wire  S_AXIS_ACLK,
		// AXI4Stream sink: Reset
		input wire  S_AXIS_ARESETN,
		// Ready to accept data in
		output wire  S_AXIS_TREADY,
		// Data in
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
		// Byte qualifier
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
		// Indicates boundary of last packet
		input wire  S_AXIS_TLAST,
		// Data is in valid
		input wire  S_AXIS_TVALID
	);

    localparam ADDER_DELAY = 4;
    localparam NUMBER_OF_INPUT_WORDS = 1024;
    
    parameter [1:0] IDLE = 2'b00,
	                RECEIVE_STREAM   = 2'b01;
    integer i;
    
	reg [3:0] sha;
    reg  [1:0] c_state , r_state;
    
    // when this counter reaches ACCUMULATE_COUNT, results are divided by ACCUMULATE_COUNT and written to the result bram
    reg [11:0] c_acc_ctr, r_acc_ctr;
    
    // this counter is used to multiplex the adder input by choosing 0 or accumulator BRAM data
    reg [11:0] c_read_ctr, r_read_ctr;
    
    reg [15:0] r_accumulate_count;
    
    wire ctr_is_zero;
    reg  ctr_is_zero_delay; 
     
    // BRAM registers
    reg [BRAM_DEPTH-1 : 0] r_acc_read_pointer, c_acc_read_pointer;
    reg [BRAM_DEPTH-1 : 0] r_acc_write_pointer, c_acc_write_pointer;    
    
    // adders signals
	wire [ADDER_DATA_WIDTH-1 : 0] adder_h_in_a, adder_h_in_b;
	wire [ADDER_DATA_WIDTH-1 : 0] adder_l_in_a, adder_l_in_b;
	wire [ADDER_DATA_WIDTH-1 : 0] adder_h_result, adder_l_result;
	wire [ADDER_DATA_WIDTH-1 : 0] adder_h_result_shifted, adder_l_result_shifted; 
	wire add_sub_enable;
	
    // AXI Stream delay signals
    (* dont_touch = "true" *) reg [C_S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata , s_axis_tdata_delay;
    (* dont_touch = "true" *) reg [ADDER_DELAY-1 : 0] axis_tvalid_delay;
          
     assign S_AXIS_TREADY = 1'b1;
     
     assign ctr_is_zero = (r_read_ctr == 'd0);
      
     // Adder signlas
     assign add_sub_enable = axis_tvalid_delay[0];
     // shift by 10 since iFFT does not divide the results by nFFT value
     assign adder_h_in_a = {5'b00000, ($signed(s_axis_tdata_delay[90:48]) >>> 10)};
     assign adder_l_in_a = {5'b00000, $signed(s_axis_tdata_delay[42:0]) >>> 10};
     assign adder_h_in_b = (ctr_is_zero_delay || r_accumulate_count[0]) ? {ADDER_DATA_WIDTH{1'b0}} : ACC_BRAM_DATAIN[111:64];
     assign adder_l_in_b = (ctr_is_zero_delay || r_accumulate_count[0]) ? {ADDER_DATA_WIDTH{1'b0}} : ACC_BRAM_DATAIN[47:0];
     
     assign adder_h_result_shifted = ($signed(adder_h_result) >>> sha);
     assign adder_l_result_shifted = ($signed(adder_l_result) >>> sha);
    
     // Accumulator BRAM signals
     assign ACC_BRAM_WENABLE = axis_tvalid_delay[ADDER_DELAY-1];
     assign ACC_BRAM_DATAOUT = {16'd0, adder_h_result, 16'd0, adder_l_result};
     assign ACC_BRAM_ADDR_READ = r_acc_read_pointer;
     assign ACC_BRAM_ADDR_WRITE = r_acc_write_pointer;
     
     // Result BRAM signals
     assign RESULT_BRAM_WENABLE = (axis_tvalid_delay[ADDER_DELAY-1] & (c_acc_ctr == r_accumulate_count));
     assign RESULT_BRAM_DATAOUT = {adder_h_result_shifted[31:0], adder_l_result_shifted[31:0]}; 
     assign RESULT_BRAM_ADDR_WRITE = r_acc_write_pointer;
     
     always @(*) begin

		c_state  = r_state;
		
		c_acc_ctr = r_acc_ctr;
		c_read_ctr = r_read_ctr;
		
		c_acc_write_pointer = r_acc_write_pointer;
		c_acc_read_pointer = r_acc_read_pointer;
		
		case (r_state)
		
		IDLE: begin
					
			c_state = RECEIVE_STREAM;
		
		end
		
		RECEIVE_STREAM: begin

			if (add_sub_enable) begin
				
				if(r_acc_read_pointer == NUMBER_OF_INPUT_WORDS - 1) begin
					c_acc_read_pointer = 'd0;
					
					if (r_read_ctr == r_accumulate_count - 1)
					   c_read_ctr = 'd0;
					else
					   c_read_ctr = r_read_ctr + 'd1;
					   
				end else begin
					c_acc_read_pointer = r_acc_read_pointer + 'd1;
			    end
			end
			
			if (axis_tvalid_delay[ADDER_DELAY-1]) begin
			
			    if(r_acc_write_pointer == 0) begin	
					if (r_acc_ctr == r_accumulate_count)
					   c_acc_ctr = 'd1;
					else
					   c_acc_ctr = r_acc_ctr + 'd1;
			    end
			    	
				if(r_acc_write_pointer == NUMBER_OF_INPUT_WORDS - 1) begin
					c_acc_write_pointer = 'd0;
				end else begin
					c_acc_write_pointer = r_acc_write_pointer + 'd1;
			    end
			end
		end
		
		default: begin 
			c_state = IDLE ; 
		end 
		endcase
	end
	
     
    always @(posedge S_AXIS_ACLK) begin
	
		r_state  <= (!S_AXIS_ARESETN) ? 'd0 : c_state;
		
		r_acc_ctr <= (!S_AXIS_ARESETN) ? 'd0 : c_acc_ctr;
		r_read_ctr <= (!S_AXIS_ARESETN) ? 'd0 : c_read_ctr;
		
	    s_axis_tdata <= (!S_AXIS_ARESETN) ? 'd0 : S_AXIS_TDATA;
	    s_axis_tdata_delay <= (!S_AXIS_ARESETN) ? 'd0 : s_axis_tdata;
	    
	    r_acc_write_pointer <= (!S_AXIS_ARESETN) ? 'd0 : c_acc_write_pointer; 
	    r_acc_read_pointer <= (!S_AXIS_ARESETN) ? 'd0 : c_acc_read_pointer;	
	    
	    ctr_is_zero_delay  <= (!S_AXIS_ARESETN) ? 'd0 : ctr_is_zero;
	    
	    r_accumulate_count  <= (!S_AXIS_ARESETN) ? 'd0 : ACCUMULATE_COUNT;
		
	end
	
	always @(posedge S_AXIS_ACLK) begin
	   
	   axis_tvalid_delay <= (!S_AXIS_ARESETN) ? 'd0 : {axis_tvalid_delay[ADDER_DELAY-2 : 0], S_AXIS_TVALID};
	   
	end
	
	// log computation for shift amount
	always @(r_accumulate_count) begin
	    case (r_accumulate_count)
            16'd0 : sha = 4'd0;
            16'd1 : sha = 4'd0;
            16'd2 : sha = 4'd1;
            16'd4 : sha = 4'd2;
            16'd8 : sha = 4'd3;
            16'd16 : sha = 4'd4;
            16'd32 : sha = 4'd5;
            16'd64 : sha = 4'd6;
            16'd128 : sha = 4'd7;
            16'd256 : sha = 4'd8;
            16'd512 : sha = 4'd9;
            16'd1024 : sha = 4'd10;
            16'd2048 : sha = 4'd11;
            default: sha = 4'd0;
	    
	    endcase
	end
	
	
    c_addsub_0 adder_high (
      .A(adder_h_in_a),      // input wire [47 : 0] A coming from AXI Stream
      .B(adder_h_in_b),      // input wire [47 : 0] B coming from scratchpad BRAM
      .CLK(S_AXIS_ACLK),  // input wire CLK
      .S(adder_h_result)      // output wire [47 : 0] S
    );

     c_addsub_0 adder_low (
          .A(adder_l_in_a),      // input wire [47 : 0] A coming from AXI Stream
          .B(adder_l_in_b),      // input wire [47 : 0] B coming from scratchpad BRAM
          .CLK(S_AXIS_ACLK),  // input wire CLK
          .S(adder_l_result)      // output wire [47 : 0] S
        );
	endmodule
