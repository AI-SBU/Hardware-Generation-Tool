`include "controlFSM.sv"
`include "datapath.sv"
`include "memory.sv"

module fc_16_8_16_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

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

	logic unsigned [-1 : 0] sel;

	logic signed [T-1 : 0] parallel_out0;

	logic unsigned[2 : 0] addr_x;
	logic signed [15 : 0] v_out;
	logic unsigned wr_en_x;

	logic unsigned[6 : 0] addr;

	logic unsigned[6 : 0] addr_w0;
	logic signed [15 : 0] m_out0;

	logic unsigned clear_acc;
	logic unsigned en_acc;

	always_comb begin
		addr_w0 = addr + 0;
	end

	controlFSM #(16,8,1) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid), .countToP(sel));

	memory #(16, 8 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	mux #(16, 1) muxMod(.parallel_out0(parallel_out0), .sel(sel), .f(output_data));

	datapath #(16, 1) datapathMod0(.clk(clk), .reset(reset), .m_out(m_out0), .v_out(v_out),.en_acc(en_acc),
									.output_data(parallel_out0), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	fc_16_8_16_1_1_W_rom  matrixRom(.clk(clk),.addr0(addr_w0), .z0(m_out0));

endmodule

module mux(parallel_out0, sel, f);
	parameter T = 16;
	parameter P = 1;

	output signed [T-1 : 0] f;
	input logic unsigned [-1 : 0] sel;
	input signed [T-1 : 0] parallel_out0;
	logic unsigned [P*T-1 : 0] array;
	assign  array = {parallel_out0[15: 0]};

	assign f = 			(sel == 0) ? parallel_out0 : 16'bz;
endmodule

module fc_16_8_16_1_1_W_rom(clk, addr0, z0);
	input clk;
	input [6:0] addr0;
	output logic signed [15:0] z0;
	always_ff @(posedge clk) begin
		case(addr0)
		0: z0 <= -16'd102;
		1: z0 <= -16'd31;
		2: z0 <= 16'd53;
		3: z0 <= -16'd35;
		4: z0 <= 16'd31;
		5: z0 <= -16'd53;
		6: z0 <= -16'd3;
		7: z0 <= 16'd119;
		8: z0 <= 16'd30;
		9: z0 <= 16'd125;
		10: z0 <= -16'd49;
		11: z0 <= -16'd85;
		12: z0 <= -16'd20;
		13: z0 <= -16'd81;
		14: z0 <= -16'd70;
		15: z0 <= 16'd93;
		16: z0 <= -16'd79;
		17: z0 <= -16'd59;
		18: z0 <= -16'd85;
		19: z0 <= 16'd53;
		20: z0 <= -16'd119;
		21: z0 <= 16'd117;
		22: z0 <= 16'd14;
		23: z0 <= -16'd122;
		24: z0 <= -16'd33;
		25: z0 <= 16'd69;
		26: z0 <= -16'd38;
		27: z0 <= 16'd6;
		28: z0 <= 16'd57;
		29: z0 <= 16'd49;
		30: z0 <= -16'd66;
		31: z0 <= 16'd84;
		32: z0 <= -16'd110;
		33: z0 <= 16'd115;
		34: z0 <= -16'd79;
		35: z0 <= 16'd49;
		36: z0 <= -16'd66;
		37: z0 <= 16'd47;
		38: z0 <= 16'd40;
		39: z0 <= 16'd93;
		40: z0 <= 16'd44;
		41: z0 <= 16'd119;
		42: z0 <= -16'd120;
		43: z0 <= -16'd104;
		44: z0 <= -16'd90;
		45: z0 <= -16'd62;
		46: z0 <= 16'd118;
		47: z0 <= -16'd40;
		48: z0 <= 16'd7;
		49: z0 <= -16'd95;
		50: z0 <= -16'd115;
		51: z0 <= 16'd16;
		52: z0 <= -16'd106;
		53: z0 <= 16'd27;
		54: z0 <= 16'd22;
		55: z0 <= -16'd10;
		56: z0 <= -16'd32;
		57: z0 <= 16'd112;
		58: z0 <= 16'd124;
		59: z0 <= -16'd102;
		60: z0 <= 16'd34;
		61: z0 <= -16'd70;
		62: z0 <= 16'd110;
		63: z0 <= 16'd52;
		64: z0 <= -16'd82;
		65: z0 <= -16'd97;
		66: z0 <= -16'd26;
		67: z0 <= -16'd20;
		68: z0 <= 16'd78;
		69: z0 <= -16'd114;
		70: z0 <= -16'd55;
		71: z0 <= -16'd5;
		72: z0 <= -16'd122;
		73: z0 <= -16'd47;
		74: z0 <= 16'd19;
		75: z0 <= -16'd84;
		76: z0 <= 16'd19;
		77: z0 <= 16'd9;
		78: z0 <= 16'd4;
		79: z0 <= -16'd102;
		80: z0 <= 16'd42;
		81: z0 <= 16'd18;
		82: z0 <= 16'd42;
		83: z0 <= 16'd65;
		84: z0 <= -16'd83;
		85: z0 <= -16'd64;
		86: z0 <= -16'd73;
		87: z0 <= 16'd14;
		88: z0 <= -16'd79;
		89: z0 <= -16'd77;
		90: z0 <= 16'd40;
		91: z0 <= 16'd83;
		92: z0 <= -16'd19;
		93: z0 <= 16'd22;
		94: z0 <= 16'd7;
		95: z0 <= 16'd27;
		96: z0 <= 16'd53;
		97: z0 <= 16'd109;
		98: z0 <= -16'd120;
		99: z0 <= 16'd4;
		100: z0 <= 16'd124;
		101: z0 <= -16'd47;
		102: z0 <= 16'd127;
		103: z0 <= -16'd126;
		104: z0 <= 16'd35;
		105: z0 <= 16'd18;
		106: z0 <= -16'd82;
		107: z0 <= -16'd74;
		108: z0 <= -16'd100;
		109: z0 <= 16'd51;
		110: z0 <= -16'd47;
		111: z0 <= 16'd70;
		112: z0 <= -16'd59;
		113: z0 <= 16'd123;
		114: z0 <= 16'd7;
		115: z0 <= -16'd14;
		116: z0 <= -16'd68;
		117: z0 <= 16'd62;
		118: z0 <= -16'd128;
		119: z0 <= -16'd19;
		120: z0 <= 16'd113;
		121: z0 <= 16'd40;
		122: z0 <= -16'd64;
		123: z0 <= -16'd33;
		124: z0 <= -16'd66;
		125: z0 <= 16'd71;
		126: z0 <= 16'd122;
		127: z0 <= 16'd116;
		endcase
	end
endmodule

