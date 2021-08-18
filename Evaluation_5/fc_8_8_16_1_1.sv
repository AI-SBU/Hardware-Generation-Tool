`include "controlFSM.sv"
`include "datapath.sv"
`include "memory.sv"

module fc_8_8_16_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 8;
	parameter N = 8;
	parameter T = 16;
	parameter R = 1;
	localparam LOGSIZE_M = $clog2(M*N);
	localparam LOGSIZE_N = $clog2(N);

	input clk, reset, input_valid, output_ready;
	input signed [T-1 : 0] input_data;
	output signed [T-1 : 0] output_data;
	output output_valid, input_ready;

	logic unsigned[5 : 0] addr_w;
	logic unsigned[2 : 0] addr_x;
	logic signed [15 : 0] v_out, m_out;
	logic unsigned wr_en_x;
	logic unsigned clear_acc;
	logic unsigned en_acc;

	controlFSM #(8,8) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr_w), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid));

	datapath #(16, 1) datapathMod(.clk(clk), .reset(reset), .m_out(m_out), .v_out(v_out),
									.en_acc(en_acc), .output_data(output_data), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	memory #(16, 8 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	fc_8_8_16_1_1_W_rom  matrixRom(.clk(clk), .addr(addr_w), .z(m_out));

endmodule

module fc_8_8_16_1_1_W_rom(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd46;
        1: z <= 16'd121;
        2: z <= 16'd85;
        3: z <= -16'd4;
        4: z <= -16'd76;
        5: z <= -16'd111;
        6: z <= -16'd16;
        7: z <= -16'd80;
        8: z <= 16'd32;
        9: z <= -16'd68;
        10: z <= 16'd8;
        11: z <= -16'd102;
        12: z <= -16'd81;
        13: z <= 16'd105;
        14: z <= -16'd5;
        15: z <= -16'd66;
        16: z <= 16'd58;
        17: z <= 16'd103;
        18: z <= -16'd37;
        19: z <= 16'd66;
        20: z <= 16'd5;
        21: z <= 16'd103;
        22: z <= -16'd117;
        23: z <= -16'd52;
        24: z <= 16'd65;
        25: z <= 16'd30;
        26: z <= -16'd27;
        27: z <= -16'd95;
        28: z <= 16'd103;
        29: z <= -16'd37;
        30: z <= -16'd108;
        31: z <= 16'd21;
        32: z <= -16'd44;
        33: z <= 16'd105;
        34: z <= -16'd110;
        35: z <= 16'd9;
        36: z <= 16'd123;
        37: z <= 16'd2;
        38: z <= 16'd57;
        39: z <= 16'd27;
        40: z <= 16'd62;
        41: z <= -16'd63;
        42: z <= 16'd53;
        43: z <= 16'd109;
        44: z <= -16'd86;
        45: z <= -16'd80;
        46: z <= -16'd85;
        47: z <= 16'd101;
        48: z <= -16'd104;
        49: z <= 16'd7;
        50: z <= 16'd39;
        51: z <= 16'd29;
        52: z <= -16'd18;
        53: z <= 16'd50;
        54: z <= 16'd105;
        55: z <= -16'd81;
        56: z <= -16'd48;
        57: z <= -16'd49;
        58: z <= -16'd48;
        59: z <= -16'd73;
        60: z <= 16'd42;
        61: z <= -16'd28;
        62: z <= 16'd77;
        63: z <= 16'd126;
      endcase
   end
endmodule

