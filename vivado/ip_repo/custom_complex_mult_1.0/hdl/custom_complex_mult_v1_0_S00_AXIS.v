
`timescale 1 ns / 1 ps

	module custom_complex_mult_v1_0_S00_AXIS #
	(
		parameter integer BRAM_DEPTH_BITS = 10,
		// AXI4Stream sink: Data Width
		parameter integer C_S_AXIS_TDATA_WIDTH	= 96,
		
		parameter integer C_M_AXIS_TDATA_WIDTH = 64
	)
	(
		
		// BRAM signals
        output wire [BRAM_DEPTH_BITS-1:0] BRAM_ADDR,
        input wire [(C_M_AXIS_TDATA_WIDTH)-1 : 0] BRAM_DATAIN,
        
        // M AXI signals
        input wire MAXI_CLK,
        input wire MAXI_RST,
        
        output wire MAXI_VALID,
        output wire MAXI_LAST,
        input wire MAXI_READY,
        output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] MAXI_DATA,
        output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0]MAXI_TSTRB,

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
        
	
	parameter [1:0] IDLE = 2'b00,
	                MULT = 2'b11;
    
    reg  [1:0] c_state , r_state;
    reg [BRAM_DEPTH_BITS-1 : 0] c_read_ptr, r_read_ptr;

    // multiplier signals
    wire [127:0] complex_mult_result;
    wire [63:0] input_a_data;
    wire input_a_valid, input_a_ready, input_a_last;
    wire [63:0] input_b_data;
    wire input_b_valid, input_b_ready, input_b_last;
    
    // delay signals
    (* dont_touch = "true" *) reg s_axis_tvalid_delay, s_axis_tlast_delay, s_axis_tvalid_delay_2, s_axis_tlast_delay_2;
    (* dont_touch = "true" *) reg [C_S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata_delay, s_axis_tdata_delay_2;
    
    
    assign BRAM_ADDR = r_read_ptr;
    
    assign MAXI_TSTRB = {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
    assign MAXI_DATA =  {complex_mult_result[118:87], complex_mult_result[54:23]};// {complex_mult_result[114:83], complex_mult_result[50:19]};
    
    // Input A of multiplier coming from SAXI (FFT)
    assign input_a_data = {s_axis_tdata_delay_2[79:48], s_axis_tdata_delay_2[31:0]};
    assign input_a_valid = s_axis_tvalid_delay_2;
    assign input_a_last = s_axis_tlast_delay_2;
    // ready to receive input when both ready signals are high
    assign S_AXIS_TREADY = input_a_ready & input_b_ready;
    
    // Input B of multiplier coming from BRAM
    assign input_b_data = BRAM_DATAIN;
    // both inputs are valid at the same time, same thing for tlast signal
    assign input_b_valid = s_axis_tvalid_delay_2;
    assign input_b_last = s_axis_tlast_delay_2;
    
    always @(*) begin

		c_state  = r_state;
		
		c_read_ptr = r_read_ptr;
		
		case (r_state)
		
		IDLE: begin
		
			c_state = MULT;
		
		end
		
		
		MULT: begin
		
		    if (/*S_AXIS_TVALID*/s_axis_tvalid_delay) begin

                    c_read_ptr = r_read_ptr + 'd1;
            end
            
            c_state = MULT;
			
		end
		
		default: begin 
			c_state = IDLE ; 
			
		end 
		endcase
	end
	
	
	always @(posedge S_AXIS_ACLK) begin
	
		r_state  <= (!S_AXIS_ARESETN) ?  'd0 : c_state;

		r_read_ptr  <= (!S_AXIS_ARESETN) ?  'd0 : c_read_ptr;
		
		s_axis_tvalid_delay <= (!S_AXIS_ARESETN) ?  'd0 : S_AXIS_TVALID;
		s_axis_tlast_delay <= (!S_AXIS_ARESETN) ?  'd0 : S_AXIS_TLAST;
		s_axis_tvalid_delay_2 <= (!S_AXIS_ARESETN) ?  'd0 : s_axis_tvalid_delay;
		s_axis_tlast_delay_2 <= (!S_AXIS_ARESETN) ?  'd0 : s_axis_tlast_delay;
		
		s_axis_tdata_delay <= (!S_AXIS_ARESETN) ?  'd0 : S_AXIS_TDATA;
		s_axis_tdata_delay_2 <= (!S_AXIS_ARESETN) ?  'd0 : s_axis_tdata_delay;
	end
	
	
    cmpy_0 cmult (
      .aclk(S_AXIS_ACLK),                              // input wire aclk
      
      .s_axis_a_tvalid(input_a_valid),        // input wire s_axis_a_tvalid
      .s_axis_a_tready(input_a_ready),        // output wire s_axis_a_tready
      .s_axis_a_tlast(input_a_last),          // input wire s_axis_a_tlast
      .s_axis_a_tdata(input_a_data),          // input wire [63 : 0] s_axis_a_tdata
      
      .s_axis_b_tvalid(input_b_valid),        // input wire s_axis_b_tvalid
      .s_axis_b_tready(input_b_ready),        // output wire s_axis_b_tready
      .s_axis_b_tlast(input_b_last),          // input wire s_axis_b_tlast
      .s_axis_b_tdata(input_b_data),          // input wire [63 : 0] s_axis_b_tdata
      
      .m_axis_dout_tvalid(MAXI_VALID),  // output wire m_axis_dout_tvalid
      .m_axis_dout_tready(MAXI_READY),  // input wire m_axis_dout_tready
      .m_axis_dout_tlast(MAXI_LAST),    // output wire m_axis_dout_tlast
      .m_axis_dout_tdata(complex_mult_result)    // output wire [127 : 0] m_axis_dout_tdata
    );

	endmodule
