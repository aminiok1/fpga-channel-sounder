
`timescale 1 ns / 1 ps

	module complex_fir_v1_0_M00_AXIS #
	(
		// Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		parameter integer C_M_AXIS_TDATA_WIDTH	= 64

	)
	(
		
		// Global ports
		input wire  M_AXIS_ACLK,
		// 
		input wire  M_AXIS_ARESETN,
		// Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		output wire  M_AXIS_TVALID,
		// TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		// TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		// TLAST indicates the boundary of a packet.
		output wire  M_AXIS_TLAST,
		// TREADY indicates that the slave can accept a transfer in the current cycle.
		input wire  M_AXIS_TREADY,
		
		// Slave Stream ports
		input wire  S0_AXIS_ACLK,
		// AXI4Stream sink: Reset
		input wire  S0_AXIS_ARESETN,
		// Ready to accept data in
		output wire  S0_AXIS_TREADY,
		// Data in
		input wire [C_M_AXIS_TDATA_WIDTH-1 : 0] S0_AXIS_TDATA,
		// Byte qualifier
		input wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] S0_AXIS_TSTRB,
		// Indicates boundary of last packet
		input wire  S0_AXIS_TLAST,
		// Data is in valid
		input wire  S0_AXIS_TVALID,
		
		input wire  S1_AXIS_ACLK,
		// AXI4Stream sink: Reset
		input wire  S1_AXIS_ARESETN,
		// Ready to accept data in
		output wire  S1_AXIS_TREADY,
		// Data in
		input wire [C_M_AXIS_TDATA_WIDTH-1 : 0] S1_AXIS_TDATA,
		// Byte qualifier
		input wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] S1_AXIS_TSTRB,
		// Indicates boundary of last packet
		input wire  S1_AXIS_TLAST,
		// Data is in valid
		input wire  S1_AXIS_TVALID
	);
    localparam ADDER_DELAY = 4;                                                                        

    reg  [1:0] c_state , r_state;
	reg r_axis_tready;
	
	// adder/subtractor signals
	wire [(C_M_AXIS_TDATA_WIDTH/2)-1 : 0] adder_in_a, adder_in_b;
	wire [(C_M_AXIS_TDATA_WIDTH/2)-1 : 0] sub_in_a, sub_in_b;
	wire [(C_M_AXIS_TDATA_WIDTH/2)-1 : 0] adder_result, sub_result;
	wire add_sub_enable;
	
	(* dont_touch = "true" *) reg [C_M_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata , s00_axis_tdata_delay;
    (* dont_touch = "true" *) reg [C_M_AXIS_TDATA_WIDTH-1 : 0] s01_axis_tdata , s01_axis_tdata_delay;
	(* dont_touch = "true" *) reg [ADDER_DELAY-1 : 0] axis_tvalid_delay, axis_tlast_delay;
    
    // Adder input signals
    assign adder_in_a = s00_axis_tdata_delay[63: 32];
    assign adder_in_b = s01_axis_tdata_delay[31: 0];
    assign sub_in_a = s00_axis_tdata_delay[31: 0];
    assign sub_in_b = s01_axis_tdata_delay[63: 32];
    assign add_sub_enable = r_axis_tready & axis_tvalid_delay[0];
    
    
    // Slave stream signals
    assign S0_AXIS_TREADY = M_AXIS_TREADY;
    assign S1_AXIS_TREADY = M_AXIS_TREADY;
    
    // Master stream signals
    assign M_AXIS_TDATA = {adder_result, sub_result};
    assign M_AXIS_TVALID = axis_tvalid_delay[ADDER_DELAY-1];
    assign M_AXIS_TLAST = axis_tlast_delay[ADDER_DELAY-1];
    assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
   
	
	always @(posedge S0_AXIS_ACLK) begin
	
		r_state  <= (!S0_AXIS_ARESETN) ?  'd0 : c_state;
		
		r_axis_tready  <= (!M_AXIS_ARESETN) ? 'd0 : M_AXIS_TREADY;
		
	    s00_axis_tdata <= (!S0_AXIS_ARESETN) ?  'd0 : S0_AXIS_TDATA;
	    s00_axis_tdata_delay <= (!S0_AXIS_ARESETN) ?  'd0 : s00_axis_tdata;
	    
	    s01_axis_tdata <= (!S0_AXIS_ARESETN) ?  'd0 : S1_AXIS_TDATA;
	    s01_axis_tdata_delay <= (!S0_AXIS_ARESETN) ?  'd0 : s01_axis_tdata;

		
	end
	
	always @(posedge S0_AXIS_ACLK) begin
	   
	   axis_tvalid_delay <= (!S0_AXIS_ARESETN) ? 'd0 : {axis_tvalid_delay[ADDER_DELAY-2 : 0], S0_AXIS_TVALID};
	   axis_tlast_delay <= (!S0_AXIS_ARESETN) ? 'd0 : {axis_tlast_delay[ADDER_DELAY-2 : 0], S0_AXIS_TLAST};
	   
	end
    
    c_addsub_0 adder (
      .A(adder_in_a),      // input wire [31 : 0] A
      .B(adder_in_b),      // input wire [31 : 0] B
      .CLK(S0_AXIS_ACLK),  // input wire CLK
      .CE(add_sub_enable),    // input wire CE
      .S(adder_result)      // output wire [31 : 0] S
    );
    
    c_addsub_1 subtractor (
      .A(sub_in_a),      // input wire [31 : 0] A
      .B(sub_in_b),      // input wire [31 : 0] B
      .CLK(S0_AXIS_ACLK),  // input wire CLK
      .CE(add_sub_enable),    // input wire CE
      .S(sub_result)      // output wire [31 : 0] S
    );
	endmodule
