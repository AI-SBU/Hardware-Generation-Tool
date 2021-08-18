`include "controlFSM.sv"
`include "datapath.sv"
`include "memory.sv"

module net_4_8_12_16_16_1_10(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);
	input clk, reset, input_valid, output_ready;
	input signed [15 : 0] input_data;
	output signed [15 : 0] output_data;
	output output_valid, input_ready;

	logic signed [15 : 0] layer1_output_data;
	logic unsigned layer1_output_valid;
	logic unsigned layer2_input_ready;
	logic signed [15 : 0] layer2_output_data;
	logic unsigned layer2_output_valid;
	logic unsigned layer3_input_ready;
   // this module should instantiate three layers and wire them together
l1_fc_8_4_16_1_2	layer1(.clk(clk), .reset(reset), .input_valid(input_valid), 
					.input_data(input_data), .input_ready(input_ready), .output_data(layer1_output_data), 
					.output_valid(layer1_output_valid), .output_ready(layer2_input_ready));
l2_fc_12_8_16_1_3	layer2(.clk(clk), .reset(reset), .input_data(layer1_output_data), .input_valid(layer1_output_valid), 
					 .input_ready(layer2_input_ready), .output_data(layer2_output_data), .output_valid(layer2_output_valid), .output_ready(layer3_input_ready));
l3_fc3_16_12_16_1_4	layer3(.clk(clk), .reset(reset), .input_data(layer2_output_data), .input_valid(layer2_output_valid), 
					 .input_ready(layer3_input_ready), .output_data(output_data), .output_valid(output_valid), .output_ready(output_ready));
endmodule

module l1_fc_8_4_16_1_2(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 8;
	parameter N = 4;
	parameter T = 16;
	parameter R = 1;
	localparam LOGSIZE_M = $clog2(M*N);
	localparam LOGSIZE_N = $clog2(N);

	input clk, reset, input_valid, output_ready;
	input signed [T-1 : 0] input_data;
	output signed [T-1 : 0] output_data;
	output output_valid, input_ready;

	logic unsigned [0 : 0] sel;

	logic signed [T-1 : 0] parallel_out0;
	logic signed [T-1 : 0] parallel_out1;

	logic unsigned[1 : 0] addr_x;
	logic signed [15 : 0] v_out;
	logic unsigned wr_en_x;

	logic unsigned[4 : 0] addr;

	logic unsigned[4 : 0] addr_w0;
	logic signed [15 : 0] m_out0;

	logic unsigned[4 : 0] addr_w1;
	logic signed [15 : 0] m_out1;

	logic unsigned clear_acc;
	logic unsigned en_acc;

	always_comb begin
		addr_w0 = addr + 0;
		addr_w1 = addr + 4;
	end

	controlFSM #(8,4,2) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid), .countToP(sel));

	memory #(16, 4 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	l1_fc_8_4_16_1_2_mux #(16, 2) muxMod(.parallel_out0(parallel_out0), .parallel_out1(parallel_out1), .sel(sel), .f(output_data));

	datapath #(16, 1) datapathMod0(.clk(clk), .reset(reset), .m_out(m_out0), .v_out(v_out),.en_acc(en_acc),
									.output_data(parallel_out0), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	datapath #(16, 1) datapathMod1(.clk(clk), .reset(reset), .m_out(m_out1), .v_out(v_out),.en_acc(en_acc),
									.output_data(parallel_out1), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	l1_fc_8_4_16_1_2_W_rom  matrixRom(.clk(clk),.addr0(addr_w0), .addr1(addr_w1), .z0(m_out0), .z1(m_out1));

endmodule

module l1_fc_8_4_16_1_2_mux(parallel_out0, parallel_out1, sel, f);
	parameter T = 16;
	parameter P = 2;

	output signed [T-1 : 0] f;
	input logic unsigned [0 : 0] sel;
	input signed [T-1 : 0] parallel_out0;
	input signed [T-1 : 0] parallel_out1;
	logic unsigned [P*T-1 : 0] array;
	assign  array = {parallel_out0[15 : 0], parallel_out1[15: 0]};

	assign f = (sel == 0) ? parallel_out0 : 
			(sel == 1) ? parallel_out1 : 16'b0;
endmodule

module l1_fc_8_4_16_1_2_W_rom(clk, addr0, addr1, z0, z1);
	input clk;
	input [4:0] addr0;
	input [4:0] addr1;
	output logic signed [15:0] z0;
	output logic signed [15:0] z1;
	always_ff @(posedge clk) begin
		case(addr0)
		0: z0 <= -16'd6;
		1: z0 <= -16'd3;
		2: z0 <= 16'd6;
		3: z0 <= 16'd2;
		4: z0 <= -16'd1;
		5: z0 <= 16'd3;
		6: z0 <= 16'd4;
		7: z0 <= -16'd3;
		8: z0 <= -16'd1;
		9: z0 <= 16'd0;
		10: z0 <= 16'd1;
		11: z0 <= -16'd7;
		12: z0 <= -16'd1;
		13: z0 <= 16'd3;
		14: z0 <= 16'd3;
		15: z0 <= -16'd7;
		16: z0 <= 16'd3;
		17: z0 <= 16'd6;
		18: z0 <= -16'd1;
		19: z0 <= -16'd8;
		20: z0 <= -16'd5;
		21: z0 <= -16'd4;
		22: z0 <= 16'd3;
		23: z0 <= 16'd5;
		24: z0 <= 16'd5;
		25: z0 <= -16'd1;
		26: z0 <= 16'd7;
		27: z0 <= -16'd7;
		28: z0 <= -16'd5;
		29: z0 <= -16'd4;
		30: z0 <= 16'd6;
		31: z0 <= -16'd2;
		endcase
		case(addr1)
		0: z1 <= -16'd6;
		1: z1 <= -16'd3;
		2: z1 <= 16'd6;
		3: z1 <= 16'd2;
		4: z1 <= -16'd1;
		5: z1 <= 16'd3;
		6: z1 <= 16'd4;
		7: z1 <= -16'd3;
		8: z1 <= -16'd1;
		9: z1 <= 16'd0;
		10: z1 <= 16'd1;
		11: z1 <= -16'd7;
		12: z1 <= -16'd1;
		13: z1 <= 16'd3;
		14: z1 <= 16'd3;
		15: z1 <= -16'd7;
		16: z1 <= 16'd3;
		17: z1 <= 16'd6;
		18: z1 <= -16'd1;
		19: z1 <= -16'd8;
		20: z1 <= -16'd5;
		21: z1 <= -16'd4;
		22: z1 <= 16'd3;
		23: z1 <= 16'd5;
		24: z1 <= 16'd5;
		25: z1 <= -16'd1;
		26: z1 <= 16'd7;
		27: z1 <= -16'd7;
		28: z1 <= -16'd5;
		29: z1 <= -16'd4;
		30: z1 <= 16'd6;
		31: z1 <= -16'd2;
		endcase
	end
endmodule

module l2_fc_12_8_16_1_3(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 12;
	parameter N = 8;
	parameter T = 16;
	parameter R = 1;
	localparam LOGSIZE_M = $clog2(M*N);
	localparam LOGSIZE_N = $clog2(N);

	input clk, reset, input_valid, output_ready;
	input signed [T-1 : 0] input_data;
	output signed [T-1 : 0] output_data;
	output output_valid, input_ready;

	logic unsigned [1 : 0] sel;

	logic signed [T-1 : 0] parallel_out0;
	logic signed [T-1 : 0] parallel_out1;
	logic signed [T-1 : 0] parallel_out2;

	logic unsigned[2 : 0] addr_x;
	logic signed [15 : 0] v_out;
	logic unsigned wr_en_x;

	logic unsigned[6 : 0] addr;

	logic unsigned[6 : 0] addr_w0;
	logic signed [15 : 0] m_out0;

	logic unsigned[6 : 0] addr_w1;
	logic signed [15 : 0] m_out1;

	logic unsigned[6 : 0] addr_w2;
	logic signed [15 : 0] m_out2;

	logic unsigned clear_acc;
	logic unsigned en_acc;

	always_comb begin
		addr_w0 = addr + 0;
		addr_w1 = addr + 8;
		addr_w2 = addr + 16;
	end

	controlFSM #(12,8,3) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid), .countToP(sel));

	memory #(16, 8 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	l2_fc_12_8_16_1_3_mux #(16, 3) muxMod(.parallel_out0(parallel_out0), .parallel_out1(parallel_out1), .parallel_out2(parallel_out2), .sel(sel), .f(output_data));

	datapath #(16, 1) datapathMod0(.clk(clk), .reset(reset), .m_out(m_out0), .v_out(v_out),.en_acc(en_acc),
									.output_data(parallel_out0), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	datapath #(16, 1) datapathMod1(.clk(clk), .reset(reset), .m_out(m_out1), .v_out(v_out),.en_acc(en_acc),
									.output_data(parallel_out1), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	datapath #(16, 1) datapathMod2(.clk(clk), .reset(reset), .m_out(m_out2), .v_out(v_out),.en_acc(en_acc),
									.output_data(parallel_out2), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	l2_fc_12_8_16_1_3_W_rom  matrixRom(.clk(clk),.addr0(addr_w0), .addr1(addr_w1), .addr2(addr_w2), .z0(m_out0), .z1(m_out1), .z2(m_out2));

endmodule

module l2_fc_12_8_16_1_3_mux(parallel_out0, parallel_out1, parallel_out2, sel, f);
	parameter T = 16;
	parameter P = 3;

	output signed [T-1 : 0] f;
	input logic unsigned [1 : 0] sel;
	input signed [T-1 : 0] parallel_out0;
	input signed [T-1 : 0] parallel_out1;
	input signed [T-1 : 0] parallel_out2;
	logic unsigned [P*T-1 : 0] array;
	assign  array = {parallel_out0[15 : 0], parallel_out1[15 : 0], parallel_out2[15: 0]};

	assign f = (sel == 0) ? parallel_out0 : 
			(sel == 1) ? parallel_out1 : 
			(sel == 2) ? parallel_out2 : 16'b0;
endmodule

module l2_fc_12_8_16_1_3_W_rom(clk, addr0, addr1, addr2, z0, z1, z2);
	input clk;
	input [6:0] addr0;
	input [6:0] addr1;
	input [6:0] addr2;
	output logic signed [15:0] z0;
	output logic signed [15:0] z1;
	output logic signed [15:0] z2;
	always_ff @(posedge clk) begin
		case(addr0)
		0: z0 <= 16'd1;
		1: z0 <= 16'd4;
		2: z0 <= -16'd8;
		3: z0 <= -16'd8;
		4: z0 <= 16'd0;
		5: z0 <= 16'd4;
		6: z0 <= -16'd3;
		7: z0 <= 16'd7;
		8: z0 <= -16'd3;
		9: z0 <= 16'd7;
		10: z0 <= -16'd8;
		11: z0 <= 16'd4;
		12: z0 <= 16'd2;
		13: z0 <= 16'd3;
		14: z0 <= 16'd5;
		15: z0 <= -16'd2;
		16: z0 <= 16'd1;
		17: z0 <= -16'd4;
		18: z0 <= -16'd2;
		19: z0 <= 16'd5;
		20: z0 <= 16'd0;
		21: z0 <= -16'd7;
		22: z0 <= 16'd2;
		23: z0 <= -16'd2;
		24: z0 <= 16'd1;
		25: z0 <= 16'd1;
		26: z0 <= -16'd1;
		27: z0 <= 16'd4;
		28: z0 <= 16'd5;
		29: z0 <= -16'd3;
		30: z0 <= -16'd6;
		31: z0 <= -16'd2;
		32: z0 <= -16'd7;
		33: z0 <= -16'd5;
		34: z0 <= -16'd1;
		35: z0 <= 16'd1;
		36: z0 <= 16'd7;
		37: z0 <= 16'd4;
		38: z0 <= 16'd1;
		39: z0 <= -16'd4;
		40: z0 <= 16'd3;
		41: z0 <= 16'd1;
		42: z0 <= -16'd8;
		43: z0 <= -16'd2;
		44: z0 <= -16'd3;
		45: z0 <= 16'd6;
		46: z0 <= 16'd4;
		47: z0 <= 16'd6;
		48: z0 <= -16'd6;
		49: z0 <= -16'd6;
		50: z0 <= 16'd3;
		51: z0 <= 16'd3;
		52: z0 <= -16'd4;
		53: z0 <= -16'd3;
		54: z0 <= -16'd7;
		55: z0 <= 16'd5;
		56: z0 <= 16'd7;
		57: z0 <= 16'd0;
		58: z0 <= 16'd1;
		59: z0 <= 16'd4;
		60: z0 <= 16'd5;
		61: z0 <= 16'd4;
		62: z0 <= -16'd5;
		63: z0 <= 16'd6;
		64: z0 <= 16'd7;
		65: z0 <= 16'd2;
		66: z0 <= 16'd0;
		67: z0 <= 16'd6;
		68: z0 <= -16'd2;
		69: z0 <= -16'd7;
		70: z0 <= -16'd5;
		71: z0 <= -16'd6;
		72: z0 <= 16'd2;
		73: z0 <= -16'd5;
		74: z0 <= 16'd0;
		75: z0 <= 16'd7;
		76: z0 <= -16'd7;
		77: z0 <= -16'd4;
		78: z0 <= 16'd6;
		79: z0 <= -16'd4;
		80: z0 <= -16'd2;
		81: z0 <= 16'd1;
		82: z0 <= 16'd7;
		83: z0 <= 16'd2;
		84: z0 <= 16'd7;
		85: z0 <= -16'd8;
		86: z0 <= -16'd1;
		87: z0 <= 16'd6;
		88: z0 <= 16'd0;
		89: z0 <= -16'd7;
		90: z0 <= 16'd2;
		91: z0 <= -16'd3;
		92: z0 <= 16'd5;
		93: z0 <= 16'd5;
		94: z0 <= -16'd5;
		95: z0 <= 16'd4;
		endcase
		case(addr1)
		0: z1 <= 16'd1;
		1: z1 <= 16'd4;
		2: z1 <= -16'd8;
		3: z1 <= -16'd8;
		4: z1 <= 16'd0;
		5: z1 <= 16'd4;
		6: z1 <= -16'd3;
		7: z1 <= 16'd7;
		8: z1 <= -16'd3;
		9: z1 <= 16'd7;
		10: z1 <= -16'd8;
		11: z1 <= 16'd4;
		12: z1 <= 16'd2;
		13: z1 <= 16'd3;
		14: z1 <= 16'd5;
		15: z1 <= -16'd2;
		16: z1 <= 16'd1;
		17: z1 <= -16'd4;
		18: z1 <= -16'd2;
		19: z1 <= 16'd5;
		20: z1 <= 16'd0;
		21: z1 <= -16'd7;
		22: z1 <= 16'd2;
		23: z1 <= -16'd2;
		24: z1 <= 16'd1;
		25: z1 <= 16'd1;
		26: z1 <= -16'd1;
		27: z1 <= 16'd4;
		28: z1 <= 16'd5;
		29: z1 <= -16'd3;
		30: z1 <= -16'd6;
		31: z1 <= -16'd2;
		32: z1 <= -16'd7;
		33: z1 <= -16'd5;
		34: z1 <= -16'd1;
		35: z1 <= 16'd1;
		36: z1 <= 16'd7;
		37: z1 <= 16'd4;
		38: z1 <= 16'd1;
		39: z1 <= -16'd4;
		40: z1 <= 16'd3;
		41: z1 <= 16'd1;
		42: z1 <= -16'd8;
		43: z1 <= -16'd2;
		44: z1 <= -16'd3;
		45: z1 <= 16'd6;
		46: z1 <= 16'd4;
		47: z1 <= 16'd6;
		48: z1 <= -16'd6;
		49: z1 <= -16'd6;
		50: z1 <= 16'd3;
		51: z1 <= 16'd3;
		52: z1 <= -16'd4;
		53: z1 <= -16'd3;
		54: z1 <= -16'd7;
		55: z1 <= 16'd5;
		56: z1 <= 16'd7;
		57: z1 <= 16'd0;
		58: z1 <= 16'd1;
		59: z1 <= 16'd4;
		60: z1 <= 16'd5;
		61: z1 <= 16'd4;
		62: z1 <= -16'd5;
		63: z1 <= 16'd6;
		64: z1 <= 16'd7;
		65: z1 <= 16'd2;
		66: z1 <= 16'd0;
		67: z1 <= 16'd6;
		68: z1 <= -16'd2;
		69: z1 <= -16'd7;
		70: z1 <= -16'd5;
		71: z1 <= -16'd6;
		72: z1 <= 16'd2;
		73: z1 <= -16'd5;
		74: z1 <= 16'd0;
		75: z1 <= 16'd7;
		76: z1 <= -16'd7;
		77: z1 <= -16'd4;
		78: z1 <= 16'd6;
		79: z1 <= -16'd4;
		80: z1 <= -16'd2;
		81: z1 <= 16'd1;
		82: z1 <= 16'd7;
		83: z1 <= 16'd2;
		84: z1 <= 16'd7;
		85: z1 <= -16'd8;
		86: z1 <= -16'd1;
		87: z1 <= 16'd6;
		88: z1 <= 16'd0;
		89: z1 <= -16'd7;
		90: z1 <= 16'd2;
		91: z1 <= -16'd3;
		92: z1 <= 16'd5;
		93: z1 <= 16'd5;
		94: z1 <= -16'd5;
		95: z1 <= 16'd4;
		endcase
		case(addr2)
		0: z2 <= 16'd1;
		1: z2 <= 16'd4;
		2: z2 <= -16'd8;
		3: z2 <= -16'd8;
		4: z2 <= 16'd0;
		5: z2 <= 16'd4;
		6: z2 <= -16'd3;
		7: z2 <= 16'd7;
		8: z2 <= -16'd3;
		9: z2 <= 16'd7;
		10: z2 <= -16'd8;
		11: z2 <= 16'd4;
		12: z2 <= 16'd2;
		13: z2 <= 16'd3;
		14: z2 <= 16'd5;
		15: z2 <= -16'd2;
		16: z2 <= 16'd1;
		17: z2 <= -16'd4;
		18: z2 <= -16'd2;
		19: z2 <= 16'd5;
		20: z2 <= 16'd0;
		21: z2 <= -16'd7;
		22: z2 <= 16'd2;
		23: z2 <= -16'd2;
		24: z2 <= 16'd1;
		25: z2 <= 16'd1;
		26: z2 <= -16'd1;
		27: z2 <= 16'd4;
		28: z2 <= 16'd5;
		29: z2 <= -16'd3;
		30: z2 <= -16'd6;
		31: z2 <= -16'd2;
		32: z2 <= -16'd7;
		33: z2 <= -16'd5;
		34: z2 <= -16'd1;
		35: z2 <= 16'd1;
		36: z2 <= 16'd7;
		37: z2 <= 16'd4;
		38: z2 <= 16'd1;
		39: z2 <= -16'd4;
		40: z2 <= 16'd3;
		41: z2 <= 16'd1;
		42: z2 <= -16'd8;
		43: z2 <= -16'd2;
		44: z2 <= -16'd3;
		45: z2 <= 16'd6;
		46: z2 <= 16'd4;
		47: z2 <= 16'd6;
		48: z2 <= -16'd6;
		49: z2 <= -16'd6;
		50: z2 <= 16'd3;
		51: z2 <= 16'd3;
		52: z2 <= -16'd4;
		53: z2 <= -16'd3;
		54: z2 <= -16'd7;
		55: z2 <= 16'd5;
		56: z2 <= 16'd7;
		57: z2 <= 16'd0;
		58: z2 <= 16'd1;
		59: z2 <= 16'd4;
		60: z2 <= 16'd5;
		61: z2 <= 16'd4;
		62: z2 <= -16'd5;
		63: z2 <= 16'd6;
		64: z2 <= 16'd7;
		65: z2 <= 16'd2;
		66: z2 <= 16'd0;
		67: z2 <= 16'd6;
		68: z2 <= -16'd2;
		69: z2 <= -16'd7;
		70: z2 <= -16'd5;
		71: z2 <= -16'd6;
		72: z2 <= 16'd2;
		73: z2 <= -16'd5;
		74: z2 <= 16'd0;
		75: z2 <= 16'd7;
		76: z2 <= -16'd7;
		77: z2 <= -16'd4;
		78: z2 <= 16'd6;
		79: z2 <= -16'd4;
		80: z2 <= -16'd2;
		81: z2 <= 16'd1;
		82: z2 <= 16'd7;
		83: z2 <= 16'd2;
		84: z2 <= 16'd7;
		85: z2 <= -16'd8;
		86: z2 <= -16'd1;
		87: z2 <= 16'd6;
		88: z2 <= 16'd0;
		89: z2 <= -16'd7;
		90: z2 <= 16'd2;
		91: z2 <= -16'd3;
		92: z2 <= 16'd5;
		93: z2 <= 16'd5;
		94: z2 <= -16'd5;
		95: z2 <= 16'd4;
		endcase
	end
endmodule

module l3_fc3_16_12_16_1_4(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 16;
	parameter N = 12;
	parameter T = 16;
	parameter R = 1;
	localparam LOGSIZE_M = $clog2(M*N);
	localparam LOGSIZE_N = $clog2(N);

	input clk, reset, input_valid, output_ready;
	input signed [T-1 : 0] input_data;
	output signed [T-1 : 0] output_data;
	output output_valid, input_ready;

	logic unsigned [1 : 0] sel;

	logic signed [T-1 : 0] parallel_out0;
	logic signed [T-1 : 0] parallel_out1;
	logic signed [T-1 : 0] parallel_out2;
	logic signed [T-1 : 0] parallel_out3;

	logic unsigned[3 : 0] addr_x;
	logic signed [15 : 0] v_out;
	logic unsigned wr_en_x;

	logic unsigned[7 : 0] addr;

	logic unsigned[7 : 0] addr_w0;
	logic signed [15 : 0] m_out0;

	logic unsigned[7 : 0] addr_w1;
	logic signed [15 : 0] m_out1;

	logic unsigned[7 : 0] addr_w2;
	logic signed [15 : 0] m_out2;

	logic unsigned[7 : 0] addr_w3;
	logic signed [15 : 0] m_out3;

	logic unsigned clear_acc;
	logic unsigned en_acc;

	always_comb begin
		addr_w0 = addr + 0;
		addr_w1 = addr + 12;
		addr_w2 = addr + 24;
		addr_w3 = addr + 36;
	end

	controlFSM #(16,12,4) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid), .countToP(sel));

	memory #(16, 12 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	l3_fc3_16_12_16_1_4_mux #(16, 4) muxMod(.parallel_out0(parallel_out0), .parallel_out1(parallel_out1), .parallel_out2(parallel_out2), .parallel_out3(parallel_out3), .sel(sel), .f(output_data));

	datapath #(16, 1) datapathMod0(.clk(clk), .reset(reset), .m_out(m_out0), .v_out(v_out),.en_acc(en_acc),
									.output_data(parallel_out0), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	datapath #(16, 1) datapathMod1(.clk(clk), .reset(reset), .m_out(m_out1), .v_out(v_out),.en_acc(en_acc),
									.output_data(parallel_out1), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	datapath #(16, 1) datapathMod2(.clk(clk), .reset(reset), .m_out(m_out2), .v_out(v_out),.en_acc(en_acc),
									.output_data(parallel_out2), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	datapath #(16, 1) datapathMod3(.clk(clk), .reset(reset), .m_out(m_out3), .v_out(v_out),.en_acc(en_acc),
									.output_data(parallel_out3), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	l3_fc3_16_12_16_1_4_W_rom  matrixRom(.clk(clk),.addr0(addr_w0), .addr1(addr_w1), .addr2(addr_w2), .addr3(addr_w3), .z0(m_out0), .z1(m_out1), .z2(m_out2), .z3(m_out3));

endmodule

module l3_fc3_16_12_16_1_4_mux(parallel_out0, parallel_out1, parallel_out2, parallel_out3, sel, f);
	parameter T = 16;
	parameter P = 4;

	output signed [T-1 : 0] f;
	input logic unsigned [1 : 0] sel;
	input signed [T-1 : 0] parallel_out0;
	input signed [T-1 : 0] parallel_out1;
	input signed [T-1 : 0] parallel_out2;
	input signed [T-1 : 0] parallel_out3;
	logic unsigned [P*T-1 : 0] array;
	assign  array = {parallel_out0[15 : 0], parallel_out1[15 : 0], parallel_out2[15 : 0], parallel_out3[15: 0]};

	assign f = (sel == 0) ? parallel_out0 : 
			(sel == 1) ? parallel_out1 : 
			(sel == 2) ? parallel_out2 : 
			(sel == 3) ? parallel_out3 : 16'b0;
endmodule

module l3_fc3_16_12_16_1_4_W_rom(clk, addr0, addr1, addr2, addr3, z0, z1, z2, z3);
	input clk;
	input [7:0] addr0;
	input [7:0] addr1;
	input [7:0] addr2;
	input [7:0] addr3;
	output logic signed [15:0] z0;
	output logic signed [15:0] z1;
	output logic signed [15:0] z2;
	output logic signed [15:0] z3;
	always_ff @(posedge clk) begin
		case(addr0)
		0: z0 <= -16'd1;
		1: z0 <= 16'd3;
		2: z0 <= 16'd2;
		3: z0 <= 16'd6;
		4: z0 <= 16'd4;
		5: z0 <= 16'd5;
		6: z0 <= -16'd8;
		7: z0 <= -16'd1;
		8: z0 <= -16'd7;
		9: z0 <= 16'd0;
		10: z0 <= -16'd2;
		11: z0 <= -16'd6;
		12: z0 <= 16'd4;
		13: z0 <= -16'd4;
		14: z0 <= -16'd2;
		15: z0 <= -16'd6;
		16: z0 <= 16'd6;
		17: z0 <= -16'd3;
		18: z0 <= 16'd5;
		19: z0 <= 16'd5;
		20: z0 <= -16'd3;
		21: z0 <= -16'd4;
		22: z0 <= 16'd3;
		23: z0 <= 16'd5;
		24: z0 <= -16'd3;
		25: z0 <= -16'd3;
		26: z0 <= -16'd6;
		27: z0 <= -16'd6;
		28: z0 <= -16'd5;
		29: z0 <= -16'd2;
		30: z0 <= 16'd6;
		31: z0 <= 16'd2;
		32: z0 <= -16'd7;
		33: z0 <= 16'd1;
		34: z0 <= 16'd0;
		35: z0 <= 16'd6;
		36: z0 <= -16'd2;
		37: z0 <= 16'd0;
		38: z0 <= -16'd3;
		39: z0 <= -16'd1;
		40: z0 <= -16'd8;
		41: z0 <= 16'd3;
		42: z0 <= 16'd2;
		43: z0 <= 16'd4;
		44: z0 <= -16'd8;
		45: z0 <= -16'd8;
		46: z0 <= 16'd7;
		47: z0 <= 16'd6;
		48: z0 <= -16'd2;
		49: z0 <= 16'd4;
		50: z0 <= 16'd3;
		51: z0 <= 16'd3;
		52: z0 <= -16'd8;
		53: z0 <= -16'd2;
		54: z0 <= 16'd1;
		55: z0 <= -16'd2;
		56: z0 <= 16'd3;
		57: z0 <= 16'd3;
		58: z0 <= 16'd0;
		59: z0 <= 16'd6;
		60: z0 <= -16'd7;
		61: z0 <= -16'd1;
		62: z0 <= 16'd1;
		63: z0 <= -16'd5;
		64: z0 <= -16'd8;
		65: z0 <= -16'd7;
		66: z0 <= -16'd7;
		67: z0 <= -16'd2;
		68: z0 <= 16'd2;
		69: z0 <= -16'd2;
		70: z0 <= 16'd6;
		71: z0 <= 16'd2;
		72: z0 <= -16'd7;
		73: z0 <= 16'd0;
		74: z0 <= -16'd1;
		75: z0 <= -16'd7;
		76: z0 <= 16'd0;
		77: z0 <= -16'd2;
		78: z0 <= 16'd7;
		79: z0 <= 16'd6;
		80: z0 <= -16'd6;
		81: z0 <= 16'd2;
		82: z0 <= 16'd2;
		83: z0 <= -16'd6;
		84: z0 <= -16'd8;
		85: z0 <= -16'd5;
		86: z0 <= 16'd0;
		87: z0 <= 16'd4;
		88: z0 <= 16'd6;
		89: z0 <= -16'd7;
		90: z0 <= 16'd2;
		91: z0 <= -16'd8;
		92: z0 <= 16'd0;
		93: z0 <= -16'd5;
		94: z0 <= -16'd5;
		95: z0 <= 16'd0;
		96: z0 <= -16'd3;
		97: z0 <= -16'd4;
		98: z0 <= 16'd6;
		99: z0 <= 16'd7;
		100: z0 <= 16'd2;
		101: z0 <= 16'd4;
		102: z0 <= 16'd1;
		103: z0 <= 16'd3;
		104: z0 <= -16'd4;
		105: z0 <= -16'd8;
		106: z0 <= 16'd5;
		107: z0 <= 16'd5;
		108: z0 <= -16'd2;
		109: z0 <= 16'd4;
		110: z0 <= 16'd3;
		111: z0 <= 16'd0;
		112: z0 <= -16'd1;
		113: z0 <= -16'd3;
		114: z0 <= 16'd3;
		115: z0 <= -16'd1;
		116: z0 <= 16'd0;
		117: z0 <= -16'd5;
		118: z0 <= -16'd5;
		119: z0 <= -16'd1;
		120: z0 <= -16'd4;
		121: z0 <= 16'd6;
		122: z0 <= -16'd1;
		123: z0 <= 16'd4;
		124: z0 <= -16'd7;
		125: z0 <= 16'd2;
		126: z0 <= -16'd4;
		127: z0 <= -16'd2;
		128: z0 <= 16'd6;
		129: z0 <= -16'd5;
		130: z0 <= -16'd3;
		131: z0 <= 16'd0;
		132: z0 <= 16'd7;
		133: z0 <= 16'd7;
		134: z0 <= -16'd5;
		135: z0 <= -16'd4;
		136: z0 <= 16'd7;
		137: z0 <= -16'd8;
		138: z0 <= -16'd7;
		139: z0 <= -16'd2;
		140: z0 <= 16'd5;
		141: z0 <= 16'd4;
		142: z0 <= 16'd6;
		143: z0 <= -16'd4;
		144: z0 <= -16'd6;
		145: z0 <= 16'd1;
		146: z0 <= 16'd3;
		147: z0 <= 16'd2;
		148: z0 <= 16'd5;
		149: z0 <= 16'd7;
		150: z0 <= -16'd7;
		151: z0 <= -16'd7;
		152: z0 <= 16'd5;
		153: z0 <= 16'd0;
		154: z0 <= 16'd6;
		155: z0 <= 16'd6;
		156: z0 <= -16'd6;
		157: z0 <= -16'd6;
		158: z0 <= -16'd3;
		159: z0 <= -16'd8;
		160: z0 <= -16'd3;
		161: z0 <= 16'd2;
		162: z0 <= 16'd0;
		163: z0 <= -16'd3;
		164: z0 <= 16'd1;
		165: z0 <= 16'd4;
		166: z0 <= 16'd1;
		167: z0 <= 16'd1;
		168: z0 <= 16'd4;
		169: z0 <= 16'd2;
		170: z0 <= 16'd7;
		171: z0 <= 16'd1;
		172: z0 <= -16'd2;
		173: z0 <= 16'd5;
		174: z0 <= 16'd5;
		175: z0 <= 16'd0;
		176: z0 <= -16'd1;
		177: z0 <= 16'd1;
		178: z0 <= -16'd5;
		179: z0 <= -16'd4;
		180: z0 <= 16'd0;
		181: z0 <= -16'd4;
		182: z0 <= -16'd3;
		183: z0 <= -16'd3;
		184: z0 <= 16'd5;
		185: z0 <= -16'd5;
		186: z0 <= -16'd5;
		187: z0 <= 16'd7;
		188: z0 <= -16'd2;
		189: z0 <= 16'd0;
		190: z0 <= -16'd8;
		191: z0 <= 16'd3;
		endcase
		case(addr1)
		0: z1 <= -16'd1;
		1: z1 <= 16'd3;
		2: z1 <= 16'd2;
		3: z1 <= 16'd6;
		4: z1 <= 16'd4;
		5: z1 <= 16'd5;
		6: z1 <= -16'd8;
		7: z1 <= -16'd1;
		8: z1 <= -16'd7;
		9: z1 <= 16'd0;
		10: z1 <= -16'd2;
		11: z1 <= -16'd6;
		12: z1 <= 16'd4;
		13: z1 <= -16'd4;
		14: z1 <= -16'd2;
		15: z1 <= -16'd6;
		16: z1 <= 16'd6;
		17: z1 <= -16'd3;
		18: z1 <= 16'd5;
		19: z1 <= 16'd5;
		20: z1 <= -16'd3;
		21: z1 <= -16'd4;
		22: z1 <= 16'd3;
		23: z1 <= 16'd5;
		24: z1 <= -16'd3;
		25: z1 <= -16'd3;
		26: z1 <= -16'd6;
		27: z1 <= -16'd6;
		28: z1 <= -16'd5;
		29: z1 <= -16'd2;
		30: z1 <= 16'd6;
		31: z1 <= 16'd2;
		32: z1 <= -16'd7;
		33: z1 <= 16'd1;
		34: z1 <= 16'd0;
		35: z1 <= 16'd6;
		36: z1 <= -16'd2;
		37: z1 <= 16'd0;
		38: z1 <= -16'd3;
		39: z1 <= -16'd1;
		40: z1 <= -16'd8;
		41: z1 <= 16'd3;
		42: z1 <= 16'd2;
		43: z1 <= 16'd4;
		44: z1 <= -16'd8;
		45: z1 <= -16'd8;
		46: z1 <= 16'd7;
		47: z1 <= 16'd6;
		48: z1 <= -16'd2;
		49: z1 <= 16'd4;
		50: z1 <= 16'd3;
		51: z1 <= 16'd3;
		52: z1 <= -16'd8;
		53: z1 <= -16'd2;
		54: z1 <= 16'd1;
		55: z1 <= -16'd2;
		56: z1 <= 16'd3;
		57: z1 <= 16'd3;
		58: z1 <= 16'd0;
		59: z1 <= 16'd6;
		60: z1 <= -16'd7;
		61: z1 <= -16'd1;
		62: z1 <= 16'd1;
		63: z1 <= -16'd5;
		64: z1 <= -16'd8;
		65: z1 <= -16'd7;
		66: z1 <= -16'd7;
		67: z1 <= -16'd2;
		68: z1 <= 16'd2;
		69: z1 <= -16'd2;
		70: z1 <= 16'd6;
		71: z1 <= 16'd2;
		72: z1 <= -16'd7;
		73: z1 <= 16'd0;
		74: z1 <= -16'd1;
		75: z1 <= -16'd7;
		76: z1 <= 16'd0;
		77: z1 <= -16'd2;
		78: z1 <= 16'd7;
		79: z1 <= 16'd6;
		80: z1 <= -16'd6;
		81: z1 <= 16'd2;
		82: z1 <= 16'd2;
		83: z1 <= -16'd6;
		84: z1 <= -16'd8;
		85: z1 <= -16'd5;
		86: z1 <= 16'd0;
		87: z1 <= 16'd4;
		88: z1 <= 16'd6;
		89: z1 <= -16'd7;
		90: z1 <= 16'd2;
		91: z1 <= -16'd8;
		92: z1 <= 16'd0;
		93: z1 <= -16'd5;
		94: z1 <= -16'd5;
		95: z1 <= 16'd0;
		96: z1 <= -16'd3;
		97: z1 <= -16'd4;
		98: z1 <= 16'd6;
		99: z1 <= 16'd7;
		100: z1 <= 16'd2;
		101: z1 <= 16'd4;
		102: z1 <= 16'd1;
		103: z1 <= 16'd3;
		104: z1 <= -16'd4;
		105: z1 <= -16'd8;
		106: z1 <= 16'd5;
		107: z1 <= 16'd5;
		108: z1 <= -16'd2;
		109: z1 <= 16'd4;
		110: z1 <= 16'd3;
		111: z1 <= 16'd0;
		112: z1 <= -16'd1;
		113: z1 <= -16'd3;
		114: z1 <= 16'd3;
		115: z1 <= -16'd1;
		116: z1 <= 16'd0;
		117: z1 <= -16'd5;
		118: z1 <= -16'd5;
		119: z1 <= -16'd1;
		120: z1 <= -16'd4;
		121: z1 <= 16'd6;
		122: z1 <= -16'd1;
		123: z1 <= 16'd4;
		124: z1 <= -16'd7;
		125: z1 <= 16'd2;
		126: z1 <= -16'd4;
		127: z1 <= -16'd2;
		128: z1 <= 16'd6;
		129: z1 <= -16'd5;
		130: z1 <= -16'd3;
		131: z1 <= 16'd0;
		132: z1 <= 16'd7;
		133: z1 <= 16'd7;
		134: z1 <= -16'd5;
		135: z1 <= -16'd4;
		136: z1 <= 16'd7;
		137: z1 <= -16'd8;
		138: z1 <= -16'd7;
		139: z1 <= -16'd2;
		140: z1 <= 16'd5;
		141: z1 <= 16'd4;
		142: z1 <= 16'd6;
		143: z1 <= -16'd4;
		144: z1 <= -16'd6;
		145: z1 <= 16'd1;
		146: z1 <= 16'd3;
		147: z1 <= 16'd2;
		148: z1 <= 16'd5;
		149: z1 <= 16'd7;
		150: z1 <= -16'd7;
		151: z1 <= -16'd7;
		152: z1 <= 16'd5;
		153: z1 <= 16'd0;
		154: z1 <= 16'd6;
		155: z1 <= 16'd6;
		156: z1 <= -16'd6;
		157: z1 <= -16'd6;
		158: z1 <= -16'd3;
		159: z1 <= -16'd8;
		160: z1 <= -16'd3;
		161: z1 <= 16'd2;
		162: z1 <= 16'd0;
		163: z1 <= -16'd3;
		164: z1 <= 16'd1;
		165: z1 <= 16'd4;
		166: z1 <= 16'd1;
		167: z1 <= 16'd1;
		168: z1 <= 16'd4;
		169: z1 <= 16'd2;
		170: z1 <= 16'd7;
		171: z1 <= 16'd1;
		172: z1 <= -16'd2;
		173: z1 <= 16'd5;
		174: z1 <= 16'd5;
		175: z1 <= 16'd0;
		176: z1 <= -16'd1;
		177: z1 <= 16'd1;
		178: z1 <= -16'd5;
		179: z1 <= -16'd4;
		180: z1 <= 16'd0;
		181: z1 <= -16'd4;
		182: z1 <= -16'd3;
		183: z1 <= -16'd3;
		184: z1 <= 16'd5;
		185: z1 <= -16'd5;
		186: z1 <= -16'd5;
		187: z1 <= 16'd7;
		188: z1 <= -16'd2;
		189: z1 <= 16'd0;
		190: z1 <= -16'd8;
		191: z1 <= 16'd3;
		endcase
		case(addr2)
		0: z2 <= -16'd1;
		1: z2 <= 16'd3;
		2: z2 <= 16'd2;
		3: z2 <= 16'd6;
		4: z2 <= 16'd4;
		5: z2 <= 16'd5;
		6: z2 <= -16'd8;
		7: z2 <= -16'd1;
		8: z2 <= -16'd7;
		9: z2 <= 16'd0;
		10: z2 <= -16'd2;
		11: z2 <= -16'd6;
		12: z2 <= 16'd4;
		13: z2 <= -16'd4;
		14: z2 <= -16'd2;
		15: z2 <= -16'd6;
		16: z2 <= 16'd6;
		17: z2 <= -16'd3;
		18: z2 <= 16'd5;
		19: z2 <= 16'd5;
		20: z2 <= -16'd3;
		21: z2 <= -16'd4;
		22: z2 <= 16'd3;
		23: z2 <= 16'd5;
		24: z2 <= -16'd3;
		25: z2 <= -16'd3;
		26: z2 <= -16'd6;
		27: z2 <= -16'd6;
		28: z2 <= -16'd5;
		29: z2 <= -16'd2;
		30: z2 <= 16'd6;
		31: z2 <= 16'd2;
		32: z2 <= -16'd7;
		33: z2 <= 16'd1;
		34: z2 <= 16'd0;
		35: z2 <= 16'd6;
		36: z2 <= -16'd2;
		37: z2 <= 16'd0;
		38: z2 <= -16'd3;
		39: z2 <= -16'd1;
		40: z2 <= -16'd8;
		41: z2 <= 16'd3;
		42: z2 <= 16'd2;
		43: z2 <= 16'd4;
		44: z2 <= -16'd8;
		45: z2 <= -16'd8;
		46: z2 <= 16'd7;
		47: z2 <= 16'd6;
		48: z2 <= -16'd2;
		49: z2 <= 16'd4;
		50: z2 <= 16'd3;
		51: z2 <= 16'd3;
		52: z2 <= -16'd8;
		53: z2 <= -16'd2;
		54: z2 <= 16'd1;
		55: z2 <= -16'd2;
		56: z2 <= 16'd3;
		57: z2 <= 16'd3;
		58: z2 <= 16'd0;
		59: z2 <= 16'd6;
		60: z2 <= -16'd7;
		61: z2 <= -16'd1;
		62: z2 <= 16'd1;
		63: z2 <= -16'd5;
		64: z2 <= -16'd8;
		65: z2 <= -16'd7;
		66: z2 <= -16'd7;
		67: z2 <= -16'd2;
		68: z2 <= 16'd2;
		69: z2 <= -16'd2;
		70: z2 <= 16'd6;
		71: z2 <= 16'd2;
		72: z2 <= -16'd7;
		73: z2 <= 16'd0;
		74: z2 <= -16'd1;
		75: z2 <= -16'd7;
		76: z2 <= 16'd0;
		77: z2 <= -16'd2;
		78: z2 <= 16'd7;
		79: z2 <= 16'd6;
		80: z2 <= -16'd6;
		81: z2 <= 16'd2;
		82: z2 <= 16'd2;
		83: z2 <= -16'd6;
		84: z2 <= -16'd8;
		85: z2 <= -16'd5;
		86: z2 <= 16'd0;
		87: z2 <= 16'd4;
		88: z2 <= 16'd6;
		89: z2 <= -16'd7;
		90: z2 <= 16'd2;
		91: z2 <= -16'd8;
		92: z2 <= 16'd0;
		93: z2 <= -16'd5;
		94: z2 <= -16'd5;
		95: z2 <= 16'd0;
		96: z2 <= -16'd3;
		97: z2 <= -16'd4;
		98: z2 <= 16'd6;
		99: z2 <= 16'd7;
		100: z2 <= 16'd2;
		101: z2 <= 16'd4;
		102: z2 <= 16'd1;
		103: z2 <= 16'd3;
		104: z2 <= -16'd4;
		105: z2 <= -16'd8;
		106: z2 <= 16'd5;
		107: z2 <= 16'd5;
		108: z2 <= -16'd2;
		109: z2 <= 16'd4;
		110: z2 <= 16'd3;
		111: z2 <= 16'd0;
		112: z2 <= -16'd1;
		113: z2 <= -16'd3;
		114: z2 <= 16'd3;
		115: z2 <= -16'd1;
		116: z2 <= 16'd0;
		117: z2 <= -16'd5;
		118: z2 <= -16'd5;
		119: z2 <= -16'd1;
		120: z2 <= -16'd4;
		121: z2 <= 16'd6;
		122: z2 <= -16'd1;
		123: z2 <= 16'd4;
		124: z2 <= -16'd7;
		125: z2 <= 16'd2;
		126: z2 <= -16'd4;
		127: z2 <= -16'd2;
		128: z2 <= 16'd6;
		129: z2 <= -16'd5;
		130: z2 <= -16'd3;
		131: z2 <= 16'd0;
		132: z2 <= 16'd7;
		133: z2 <= 16'd7;
		134: z2 <= -16'd5;
		135: z2 <= -16'd4;
		136: z2 <= 16'd7;
		137: z2 <= -16'd8;
		138: z2 <= -16'd7;
		139: z2 <= -16'd2;
		140: z2 <= 16'd5;
		141: z2 <= 16'd4;
		142: z2 <= 16'd6;
		143: z2 <= -16'd4;
		144: z2 <= -16'd6;
		145: z2 <= 16'd1;
		146: z2 <= 16'd3;
		147: z2 <= 16'd2;
		148: z2 <= 16'd5;
		149: z2 <= 16'd7;
		150: z2 <= -16'd7;
		151: z2 <= -16'd7;
		152: z2 <= 16'd5;
		153: z2 <= 16'd0;
		154: z2 <= 16'd6;
		155: z2 <= 16'd6;
		156: z2 <= -16'd6;
		157: z2 <= -16'd6;
		158: z2 <= -16'd3;
		159: z2 <= -16'd8;
		160: z2 <= -16'd3;
		161: z2 <= 16'd2;
		162: z2 <= 16'd0;
		163: z2 <= -16'd3;
		164: z2 <= 16'd1;
		165: z2 <= 16'd4;
		166: z2 <= 16'd1;
		167: z2 <= 16'd1;
		168: z2 <= 16'd4;
		169: z2 <= 16'd2;
		170: z2 <= 16'd7;
		171: z2 <= 16'd1;
		172: z2 <= -16'd2;
		173: z2 <= 16'd5;
		174: z2 <= 16'd5;
		175: z2 <= 16'd0;
		176: z2 <= -16'd1;
		177: z2 <= 16'd1;
		178: z2 <= -16'd5;
		179: z2 <= -16'd4;
		180: z2 <= 16'd0;
		181: z2 <= -16'd4;
		182: z2 <= -16'd3;
		183: z2 <= -16'd3;
		184: z2 <= 16'd5;
		185: z2 <= -16'd5;
		186: z2 <= -16'd5;
		187: z2 <= 16'd7;
		188: z2 <= -16'd2;
		189: z2 <= 16'd0;
		190: z2 <= -16'd8;
		191: z2 <= 16'd3;
		endcase
		case(addr3)
		0: z3 <= -16'd1;
		1: z3 <= 16'd3;
		2: z3 <= 16'd2;
		3: z3 <= 16'd6;
		4: z3 <= 16'd4;
		5: z3 <= 16'd5;
		6: z3 <= -16'd8;
		7: z3 <= -16'd1;
		8: z3 <= -16'd7;
		9: z3 <= 16'd0;
		10: z3 <= -16'd2;
		11: z3 <= -16'd6;
		12: z3 <= 16'd4;
		13: z3 <= -16'd4;
		14: z3 <= -16'd2;
		15: z3 <= -16'd6;
		16: z3 <= 16'd6;
		17: z3 <= -16'd3;
		18: z3 <= 16'd5;
		19: z3 <= 16'd5;
		20: z3 <= -16'd3;
		21: z3 <= -16'd4;
		22: z3 <= 16'd3;
		23: z3 <= 16'd5;
		24: z3 <= -16'd3;
		25: z3 <= -16'd3;
		26: z3 <= -16'd6;
		27: z3 <= -16'd6;
		28: z3 <= -16'd5;
		29: z3 <= -16'd2;
		30: z3 <= 16'd6;
		31: z3 <= 16'd2;
		32: z3 <= -16'd7;
		33: z3 <= 16'd1;
		34: z3 <= 16'd0;
		35: z3 <= 16'd6;
		36: z3 <= -16'd2;
		37: z3 <= 16'd0;
		38: z3 <= -16'd3;
		39: z3 <= -16'd1;
		40: z3 <= -16'd8;
		41: z3 <= 16'd3;
		42: z3 <= 16'd2;
		43: z3 <= 16'd4;
		44: z3 <= -16'd8;
		45: z3 <= -16'd8;
		46: z3 <= 16'd7;
		47: z3 <= 16'd6;
		48: z3 <= -16'd2;
		49: z3 <= 16'd4;
		50: z3 <= 16'd3;
		51: z3 <= 16'd3;
		52: z3 <= -16'd8;
		53: z3 <= -16'd2;
		54: z3 <= 16'd1;
		55: z3 <= -16'd2;
		56: z3 <= 16'd3;
		57: z3 <= 16'd3;
		58: z3 <= 16'd0;
		59: z3 <= 16'd6;
		60: z3 <= -16'd7;
		61: z3 <= -16'd1;
		62: z3 <= 16'd1;
		63: z3 <= -16'd5;
		64: z3 <= -16'd8;
		65: z3 <= -16'd7;
		66: z3 <= -16'd7;
		67: z3 <= -16'd2;
		68: z3 <= 16'd2;
		69: z3 <= -16'd2;
		70: z3 <= 16'd6;
		71: z3 <= 16'd2;
		72: z3 <= -16'd7;
		73: z3 <= 16'd0;
		74: z3 <= -16'd1;
		75: z3 <= -16'd7;
		76: z3 <= 16'd0;
		77: z3 <= -16'd2;
		78: z3 <= 16'd7;
		79: z3 <= 16'd6;
		80: z3 <= -16'd6;
		81: z3 <= 16'd2;
		82: z3 <= 16'd2;
		83: z3 <= -16'd6;
		84: z3 <= -16'd8;
		85: z3 <= -16'd5;
		86: z3 <= 16'd0;
		87: z3 <= 16'd4;
		88: z3 <= 16'd6;
		89: z3 <= -16'd7;
		90: z3 <= 16'd2;
		91: z3 <= -16'd8;
		92: z3 <= 16'd0;
		93: z3 <= -16'd5;
		94: z3 <= -16'd5;
		95: z3 <= 16'd0;
		96: z3 <= -16'd3;
		97: z3 <= -16'd4;
		98: z3 <= 16'd6;
		99: z3 <= 16'd7;
		100: z3 <= 16'd2;
		101: z3 <= 16'd4;
		102: z3 <= 16'd1;
		103: z3 <= 16'd3;
		104: z3 <= -16'd4;
		105: z3 <= -16'd8;
		106: z3 <= 16'd5;
		107: z3 <= 16'd5;
		108: z3 <= -16'd2;
		109: z3 <= 16'd4;
		110: z3 <= 16'd3;
		111: z3 <= 16'd0;
		112: z3 <= -16'd1;
		113: z3 <= -16'd3;
		114: z3 <= 16'd3;
		115: z3 <= -16'd1;
		116: z3 <= 16'd0;
		117: z3 <= -16'd5;
		118: z3 <= -16'd5;
		119: z3 <= -16'd1;
		120: z3 <= -16'd4;
		121: z3 <= 16'd6;
		122: z3 <= -16'd1;
		123: z3 <= 16'd4;
		124: z3 <= -16'd7;
		125: z3 <= 16'd2;
		126: z3 <= -16'd4;
		127: z3 <= -16'd2;
		128: z3 <= 16'd6;
		129: z3 <= -16'd5;
		130: z3 <= -16'd3;
		131: z3 <= 16'd0;
		132: z3 <= 16'd7;
		133: z3 <= 16'd7;
		134: z3 <= -16'd5;
		135: z3 <= -16'd4;
		136: z3 <= 16'd7;
		137: z3 <= -16'd8;
		138: z3 <= -16'd7;
		139: z3 <= -16'd2;
		140: z3 <= 16'd5;
		141: z3 <= 16'd4;
		142: z3 <= 16'd6;
		143: z3 <= -16'd4;
		144: z3 <= -16'd6;
		145: z3 <= 16'd1;
		146: z3 <= 16'd3;
		147: z3 <= 16'd2;
		148: z3 <= 16'd5;
		149: z3 <= 16'd7;
		150: z3 <= -16'd7;
		151: z3 <= -16'd7;
		152: z3 <= 16'd5;
		153: z3 <= 16'd0;
		154: z3 <= 16'd6;
		155: z3 <= 16'd6;
		156: z3 <= -16'd6;
		157: z3 <= -16'd6;
		158: z3 <= -16'd3;
		159: z3 <= -16'd8;
		160: z3 <= -16'd3;
		161: z3 <= 16'd2;
		162: z3 <= 16'd0;
		163: z3 <= -16'd3;
		164: z3 <= 16'd1;
		165: z3 <= 16'd4;
		166: z3 <= 16'd1;
		167: z3 <= 16'd1;
		168: z3 <= 16'd4;
		169: z3 <= 16'd2;
		170: z3 <= 16'd7;
		171: z3 <= 16'd1;
		172: z3 <= -16'd2;
		173: z3 <= 16'd5;
		174: z3 <= 16'd5;
		175: z3 <= 16'd0;
		176: z3 <= -16'd1;
		177: z3 <= 16'd1;
		178: z3 <= -16'd5;
		179: z3 <= -16'd4;
		180: z3 <= 16'd0;
		181: z3 <= -16'd4;
		182: z3 <= -16'd3;
		183: z3 <= -16'd3;
		184: z3 <= 16'd5;
		185: z3 <= -16'd5;
		186: z3 <= -16'd5;
		187: z3 <= 16'd7;
		188: z3 <= -16'd2;
		189: z3 <= 16'd0;
		190: z3 <= -16'd8;
		191: z3 <= 16'd3;
		endcase
	end
endmodule

