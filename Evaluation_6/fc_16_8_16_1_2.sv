`include "controlFSM.sv"
`include "datapath.sv"
`include "memory.sv"

module fc_16_8_16_1_2(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 16;
	parameter N = 8;
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

	logic unsigned[2 : 0] addr_x;
	logic signed [15 : 0] v_out;
	logic unsigned wr_en_x;

	logic unsigned[6 : 0] addr;

	logic unsigned[6 : 0] addr_w0;
	logic signed [15 : 0] m_out0;

	logic unsigned[6 : 0] addr_w1;
	logic signed [15 : 0] m_out1;

	logic unsigned clear_acc;
	logic unsigned en_acc;

	always_comb begin
		addr_w0 = addr + 0;
		addr_w1 = addr + 8;
	end

	controlFSM #(16,8,2) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid), .countToP(sel));

	memory #(16, 8 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	mux #(16, 2) muxMod(.parallel_out0(parallel_out0), .parallel_out1(parallel_out1), .sel(sel), .f(output_data));

	datapath #(16, 1) datapathMod0(.clk(clk), .reset(reset), .m_out(m_out0), .v_out(v_out),.en_acc(en_acc),
									.output_data(parallel_out0), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	datapath #(16, 1) datapathMod1(.clk(clk), .reset(reset), .m_out(m_out1), .v_out(v_out),.en_acc(en_acc),
									.output_data(parallel_out1), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	fc_16_8_16_1_2_W_rom  matrixRom(.clk(clk),.addr0(addr_w0), .addr1(addr_w1), .z0(m_out0), .z1(m_out1));

endmodule

module mux(parallel_out0, parallel_out1, sel, f);
	parameter T = 16;
	parameter P = 2;

	output signed [T-1 : 0] f;
	input logic unsigned [0 : 0] sel;
	input signed [T-1 : 0] parallel_out0;
	input signed [T-1 : 0] parallel_out1;
	logic unsigned [P*T-1 : 0] array;
	assign  array = {parallel_out0[15 : 0], parallel_out1[15: 0]};

	assign f = (sel == 0) ? parallel_out0 : 
			(sel == 1) ? parallel_out1 : 16'bz;
endmodule

module fc_16_8_16_1_2_W_rom(clk, addr0, addr1, z0, z1);
	input clk;
	input [6:0] addr0;
	input [6:0] addr1;
	output logic signed [15:0] z0;
	output logic signed [15:0] z1;
	always_ff @(posedge clk) begin
		case(addr0)
		0: z0 <= -16'd124;
		1: z0 <= 16'd98;
		2: z0 <= -16'd115;
		3: z0 <= 16'd26;
		4: z0 <= 16'd32;
		5: z0 <= -16'd73;
		6: z0 <= 16'd107;
		7: z0 <= 16'd39;
		8: z0 <= -16'd77;
		9: z0 <= -16'd79;
		10: z0 <= 16'd44;
		11: z0 <= -16'd116;
		12: z0 <= 16'd108;
		13: z0 <= 16'd28;
		14: z0 <= 16'd83;
		15: z0 <= 16'd106;
		16: z0 <= -16'd31;
		17: z0 <= -16'd28;
		18: z0 <= 16'd116;
		19: z0 <= -16'd45;
		20: z0 <= 16'd88;
		21: z0 <= 16'd25;
		22: z0 <= -16'd68;
		23: z0 <= 16'd22;
		24: z0 <= 16'd101;
		25: z0 <= -16'd91;
		26: z0 <= -16'd4;
		27: z0 <= -16'd22;
		28: z0 <= -16'd41;
		29: z0 <= 16'd118;
		30: z0 <= 16'd117;
		31: z0 <= -16'd37;
		32: z0 <= 16'd88;
		33: z0 <= -16'd126;
		34: z0 <= 16'd117;
		35: z0 <= -16'd8;
		36: z0 <= -16'd71;
		37: z0 <= 16'd96;
		38: z0 <= -16'd97;
		39: z0 <= -16'd19;
		40: z0 <= -16'd110;
		41: z0 <= 16'd75;
		42: z0 <= -16'd7;
		43: z0 <= 16'd126;
		44: z0 <= -16'd25;
		45: z0 <= -16'd51;
		46: z0 <= 16'd104;
		47: z0 <= 16'd72;
		48: z0 <= 16'd49;
		49: z0 <= 16'd93;
		50: z0 <= -16'd100;
		51: z0 <= 16'd9;
		52: z0 <= -16'd10;
		53: z0 <= -16'd40;
		54: z0 <= -16'd96;
		55: z0 <= -16'd36;
		56: z0 <= -16'd2;
		57: z0 <= 16'd28;
		58: z0 <= 16'd70;
		59: z0 <= 16'd85;
		60: z0 <= 16'd18;
		61: z0 <= 16'd59;
		62: z0 <= -16'd79;
		63: z0 <= -16'd22;
		64: z0 <= 16'd62;
		65: z0 <= -16'd90;
		66: z0 <= 16'd98;
		67: z0 <= 16'd119;
		68: z0 <= -16'd121;
		69: z0 <= -16'd127;
		70: z0 <= -16'd28;
		71: z0 <= -16'd103;
		72: z0 <= 16'd76;
		73: z0 <= 16'd94;
		74: z0 <= -16'd105;
		75: z0 <= -16'd77;
		76: z0 <= -16'd85;
		77: z0 <= 16'd127;
		78: z0 <= 16'd124;
		79: z0 <= 16'd92;
		80: z0 <= 16'd92;
		81: z0 <= -16'd104;
		82: z0 <= -16'd26;
		83: z0 <= -16'd45;
		84: z0 <= -16'd16;
		85: z0 <= 16'd6;
		86: z0 <= 16'd47;
		87: z0 <= 16'd110;
		88: z0 <= -16'd94;
		89: z0 <= -16'd11;
		90: z0 <= 16'd68;
		91: z0 <= 16'd53;
		92: z0 <= -16'd79;
		93: z0 <= 16'd117;
		94: z0 <= -16'd97;
		95: z0 <= 16'd111;
		96: z0 <= -16'd101;
		97: z0 <= -16'd126;
		98: z0 <= 16'd102;
		99: z0 <= -16'd94;
		100: z0 <= -16'd125;
		101: z0 <= -16'd53;
		102: z0 <= -16'd69;
		103: z0 <= 16'd80;
		104: z0 <= -16'd87;
		105: z0 <= -16'd46;
		106: z0 <= -16'd125;
		107: z0 <= -16'd44;
		108: z0 <= -16'd46;
		109: z0 <= 16'd127;
		110: z0 <= -16'd80;
		111: z0 <= -16'd82;
		112: z0 <= -16'd105;
		113: z0 <= 16'd22;
		114: z0 <= 16'd1;
		115: z0 <= 16'd8;
		116: z0 <= -16'd100;
		117: z0 <= -16'd80;
		118: z0 <= -16'd10;
		119: z0 <= -16'd65;
		120: z0 <= 16'd38;
		121: z0 <= -16'd70;
		122: z0 <= 16'd116;
		123: z0 <= 16'd87;
		124: z0 <= -16'd81;
		125: z0 <= -16'd109;
		126: z0 <= 16'd70;
		127: z0 <= -16'd53;
		endcase
		case(addr1)
		0: z1 <= -16'd124;
		1: z1 <= 16'd98;
		2: z1 <= -16'd115;
		3: z1 <= 16'd26;
		4: z1 <= 16'd32;
		5: z1 <= -16'd73;
		6: z1 <= 16'd107;
		7: z1 <= 16'd39;
		8: z1 <= -16'd77;
		9: z1 <= -16'd79;
		10: z1 <= 16'd44;
		11: z1 <= -16'd116;
		12: z1 <= 16'd108;
		13: z1 <= 16'd28;
		14: z1 <= 16'd83;
		15: z1 <= 16'd106;
		16: z1 <= -16'd31;
		17: z1 <= -16'd28;
		18: z1 <= 16'd116;
		19: z1 <= -16'd45;
		20: z1 <= 16'd88;
		21: z1 <= 16'd25;
		22: z1 <= -16'd68;
		23: z1 <= 16'd22;
		24: z1 <= 16'd101;
		25: z1 <= -16'd91;
		26: z1 <= -16'd4;
		27: z1 <= -16'd22;
		28: z1 <= -16'd41;
		29: z1 <= 16'd118;
		30: z1 <= 16'd117;
		31: z1 <= -16'd37;
		32: z1 <= 16'd88;
		33: z1 <= -16'd126;
		34: z1 <= 16'd117;
		35: z1 <= -16'd8;
		36: z1 <= -16'd71;
		37: z1 <= 16'd96;
		38: z1 <= -16'd97;
		39: z1 <= -16'd19;
		40: z1 <= -16'd110;
		41: z1 <= 16'd75;
		42: z1 <= -16'd7;
		43: z1 <= 16'd126;
		44: z1 <= -16'd25;
		45: z1 <= -16'd51;
		46: z1 <= 16'd104;
		47: z1 <= 16'd72;
		48: z1 <= 16'd49;
		49: z1 <= 16'd93;
		50: z1 <= -16'd100;
		51: z1 <= 16'd9;
		52: z1 <= -16'd10;
		53: z1 <= -16'd40;
		54: z1 <= -16'd96;
		55: z1 <= -16'd36;
		56: z1 <= -16'd2;
		57: z1 <= 16'd28;
		58: z1 <= 16'd70;
		59: z1 <= 16'd85;
		60: z1 <= 16'd18;
		61: z1 <= 16'd59;
		62: z1 <= -16'd79;
		63: z1 <= -16'd22;
		64: z1 <= 16'd62;
		65: z1 <= -16'd90;
		66: z1 <= 16'd98;
		67: z1 <= 16'd119;
		68: z1 <= -16'd121;
		69: z1 <= -16'd127;
		70: z1 <= -16'd28;
		71: z1 <= -16'd103;
		72: z1 <= 16'd76;
		73: z1 <= 16'd94;
		74: z1 <= -16'd105;
		75: z1 <= -16'd77;
		76: z1 <= -16'd85;
		77: z1 <= 16'd127;
		78: z1 <= 16'd124;
		79: z1 <= 16'd92;
		80: z1 <= 16'd92;
		81: z1 <= -16'd104;
		82: z1 <= -16'd26;
		83: z1 <= -16'd45;
		84: z1 <= -16'd16;
		85: z1 <= 16'd6;
		86: z1 <= 16'd47;
		87: z1 <= 16'd110;
		88: z1 <= -16'd94;
		89: z1 <= -16'd11;
		90: z1 <= 16'd68;
		91: z1 <= 16'd53;
		92: z1 <= -16'd79;
		93: z1 <= 16'd117;
		94: z1 <= -16'd97;
		95: z1 <= 16'd111;
		96: z1 <= -16'd101;
		97: z1 <= -16'd126;
		98: z1 <= 16'd102;
		99: z1 <= -16'd94;
		100: z1 <= -16'd125;
		101: z1 <= -16'd53;
		102: z1 <= -16'd69;
		103: z1 <= 16'd80;
		104: z1 <= -16'd87;
		105: z1 <= -16'd46;
		106: z1 <= -16'd125;
		107: z1 <= -16'd44;
		108: z1 <= -16'd46;
		109: z1 <= 16'd127;
		110: z1 <= -16'd80;
		111: z1 <= -16'd82;
		112: z1 <= -16'd105;
		113: z1 <= 16'd22;
		114: z1 <= 16'd1;
		115: z1 <= 16'd8;
		116: z1 <= -16'd100;
		117: z1 <= -16'd80;
		118: z1 <= -16'd10;
		119: z1 <= -16'd65;
		120: z1 <= 16'd38;
		121: z1 <= -16'd70;
		122: z1 <= 16'd116;
		123: z1 <= 16'd87;
		124: z1 <= -16'd81;
		125: z1 <= -16'd109;
		126: z1 <= 16'd70;
		127: z1 <= -16'd53;
		endcase
	end
endmodule

