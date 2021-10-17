
`timescale 1 ns / 1 ps

	module noise_generator_v1_0_M00_AXIS #
	(
	    parameter integer BRAM_DEPTH_BITS =  11,
		parameter integer C_M_AXIS_TDATA_WIDTH	= 64
	)
	(
	    // Upstream module (FIR) Axi stream signals
        input wire FIR_AXIS_TVALID,
        input wire FIR_AXIS_TLAST,
        input wire [(C_M_AXIS_TDATA_WIDTH)-1 : 0] FIR_AXIS_TDATA,
        
        // BRAM signals
        output wire [BRAM_DEPTH_BITS-1:0] BRAM_ADDR,
        input wire [(C_M_AXIS_TDATA_WIDTH)-1 : 0] BRAM_DATAIN,
    
        input wire [31:0] SCALE_FACTOR,

		// AXI signals
		input wire  M_AXIS_ACLK,
		input wire  M_AXIS_ARESETN,
		
		output wire  M_AXIS_TVALID,
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		output wire  M_AXIS_TLAST,
		input wire  M_AXIS_TREADY
	);
                                              
	localparam NUMBER_OF_OUTPUT_WORDS = 1024;
	// FIR filter outputs 16 values to flush out the filter, we don't use these values
	localparam NUMBER_OF_INVALID_DATA = 16;                                              
	
	localparam ADD_MULT_DELAY = 8; // ADD = 2, MULT = 6                                                                        
    
    integer i;
               
	function integer clogb2 (input integer bit_depth);                                   
	  begin                                                                              
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
	      bit_depth = bit_depth >> 1;                                                    
	  end                                                                                
	endfunction                                                                          
                                
	localparam integer RECEIVED_BITS = clogb2(NUMBER_OF_INVALID_DATA + NUMBER_OF_OUTPUT_WORDS);                      
                               

	parameter [1:0] IDLE = 2'b00,
	                WAIT_VALID  = 2'b01,  
	                ADD   = 2'b10,
	                FLUSH = 2'b11;
	
	reg  [1:0] c_state , r_state;
	
	reg [BRAM_DEPTH_BITS-1 : 0] c_read_ptr, r_read_ptr;
	reg [BRAM_DEPTH_BITS-1 : 0] c_noise_bram_offset, r_noise_bram_offset;
	reg [RECEIVED_BITS : 0] c_received_ctr, r_received_ctr;
	
	
	//(* dont_touch = "true" *) reg [C_M_AXIS_TDATA_WIDTH-1 : 0] r_fir_axis_tdata , r_fir_axis_tdata_delay;
	(* dont_touch = "true" *) reg [C_M_AXIS_TDATA_WIDTH-1 : 0] r_fir_axis_tdata_delay [0:7];
	//reg r_fir_axis_tvalid;
    (* dont_touch = "true" *) reg r_fir_axis_tvalid_delay;
    (* dont_touch = "true" *) reg [(C_M_AXIS_TDATA_WIDTH)-1 : 0] bram_datain_delay;
    
    reg r_axis_tready;
    
    wire tx_en;
  
    // adders signals
	wire [(C_M_AXIS_TDATA_WIDTH/2)-1 : 0] add_result_low, add_result_high;
	wire [(C_M_AXIS_TDATA_WIDTH/2)-1 : 0] add_input_low, add_input_high;
	
	// multipliers singals
	wire [63:0] mult_result_low, mult_result_high;
	
	// utility signals
	wire ctr_start, ctr_end, ctr_last;
	reg ctr_start_delay, ctr_end_delay, ctr_last_delay;
	
	assign ctr_start = (r_received_ctr >=  ADD_MULT_DELAY + 1);
	assign ctr_end = (r_received_ctr <= NUMBER_OF_OUTPUT_WORDS + ADD_MULT_DELAY);
	assign ctr_last = (r_received_ctr == NUMBER_OF_OUTPUT_WORDS + ADD_MULT_DELAY);
	
	// multiplier's result is 64 bits (40 bits fraction, 24 bit integer), we slice it to a 32-bit value (24 bits f, 8 bit I)
	assign add_input_low = mult_result_low[47:16];
	assign add_input_high = mult_result_high[47:16];
	
	assign M_AXIS_TDATA = {add_result_high, add_result_low};
	assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
	assign M_AXIS_TLAST = ctr_last_delay;
	assign M_AXIS_TVALID = (ctr_start_delay & ctr_end_delay );
	
	assign BRAM_ADDR = r_read_ptr;
	
	assign tx_en = r_axis_tready && r_fir_axis_tvalid_delay;
	
	always @(*) begin

		c_state  = r_state;
		
		c_read_ptr = r_read_ptr;
		c_received_ctr = r_received_ctr;
		
		c_noise_bram_offset = r_noise_bram_offset;
		
		case (r_state)
		
		IDLE: begin
			c_state = ADD;
		
		end
	
		ADD: begin
		      
		    if (c_received_ctr == NUMBER_OF_INVALID_DATA + NUMBER_OF_OUTPUT_WORDS) begin
		      c_received_ctr = 'd0;
		      c_noise_bram_offset = r_noise_bram_offset + 'd1;

		    end
		      
		    if (r_fir_axis_tvalid_delay)
		      c_received_ctr = c_received_ctr + 'd1;
		    
		    if (tx_en) begin
		    
		        if (c_received_ctr == NUMBER_OF_INVALID_DATA + NUMBER_OF_OUTPUT_WORDS - 1)
		            c_read_ptr = r_noise_bram_offset + 'd1;
		        else
		         if (c_received_ctr  <= NUMBER_OF_OUTPUT_WORDS) begin
		            c_read_ptr = r_read_ptr + 'd1;
		          //  if (c_read_ptr == 'd1025)
		          //      c_read_ptr = 'd0;
		         
		         end
		            
            end
            
            c_state = ADD;
			
		end
	
		default: begin 
			c_state = IDLE ; 
			
		end 
		endcase
	end
	
	
	always @(posedge M_AXIS_ACLK) begin
	
		r_state  <= (!M_AXIS_ARESETN) ?  'd0 : c_state;
		
		//r_fir_axis_tdata <= (!M_AXIS_ARESETN) ? 'd0 : FIR_AXIS_TDATA;
		//r_fir_axis_tdata_delay <= (!M_AXIS_ARESETN) ? 'd0 : r_fir_axis_tdata;
		
		r_axis_tready  <= (!M_AXIS_ARESETN) ? 'd0 : M_AXIS_TREADY;
		
		r_read_ptr  <= (!M_AXIS_ARESETN) ?  'd0 : c_read_ptr;
		r_received_ctr <= (!M_AXIS_ARESETN) ?  'd0 : c_received_ctr;
		
		r_noise_bram_offset  <= (!M_AXIS_ARESETN) ?  'd0 : c_noise_bram_offset;
		
		r_fir_axis_tvalid_delay <= (!M_AXIS_ARESETN) ? 'd0 : FIR_AXIS_TVALID;
		
		bram_datain_delay <= (!M_AXIS_ARESETN) ? 'd0 : BRAM_DATAIN;
		
		ctr_start_delay <= (!M_AXIS_ARESETN) ? 'd0 : ctr_start;
		ctr_end_delay <= (!M_AXIS_ARESETN) ? 'd0 : ctr_end;
		ctr_last_delay  <= (!M_AXIS_ARESETN) ? 'd0 : ctr_last;
		
	end
	
	always @(posedge M_AXIS_ACLK) begin
	
	   r_fir_axis_tdata_delay[0] <= (!M_AXIS_ARESETN) ? 'd0 : FIR_AXIS_TDATA;
	   
	   for (i = 1; i <= ADD_MULT_DELAY - 1; i = i+1)
	       r_fir_axis_tdata_delay[i] <= r_fir_axis_tdata_delay[i - 1];
	
	end
	
	
	//FIXME: in the clock cycle that M_AXIS_TREADY goes low, the adder sends one valid result and after that stops
	//If we use the original TREADY and not the delayed version, then the adder misses one valid input from the previous
	//cycle
	c_addsub_0 adder_low (
	  .A(r_fir_axis_tdata_delay[7][31:0]),
	  .B(add_input_low),
	  .CLK(M_AXIS_ACLK),
	  .S(add_result_low)
	);

	c_addsub_0 adder_high (
	  .A(r_fir_axis_tdata_delay[7][63:32]),
	  .B(add_input_high),
	  .CLK(M_AXIS_ACLK),
	  .S(add_result_high)
	);
	
    mult_gen_0 mult_low (
      .CLK(M_AXIS_ACLK),  // input wire CLK
      .A(bram_datain_delay[31:0]),      // input wire [31 : 0] A
      .B(SCALE_FACTOR),      // input wire [31 : 0] B
      .P(mult_result_low)      // output wire [63 : 0] P
    );
    
    mult_gen_0 mult_high (
      .CLK(M_AXIS_ACLK),  // input wire CLK
      .A(bram_datain_delay[63:32]),      // input wire [31 : 0] A
      .B(SCALE_FACTOR),      // input wire [31 : 0] B
      .P(mult_result_high)      // output wire [63 : 0] P
    );
	endmodule
