`include "controlFSM.sv"
`include "datapath.sv"
`include "memory.sv"

module fc_8_10_16_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 8;
	parameter N = 10;
	parameter T = 16;
	parameter R = 1;
	localparam LOGSIZE_M = $clog2(M*N);
	localparam LOGSIZE_N = $clog2(N);

	input clk, reset, input_valid, output_ready;
	input signed [T-1 : 0] input_data;
	output signed [T-1 : 0] output_data;
	output output_valid, input_ready;

	logic unsigned[6 : 0] addr_w;
	logic unsigned[3 : 0] addr_x;
	logic signed [15 : 0] v_out, m_out;
	logic unsigned wr_en_x;
	logic unsigned clear_acc;
	logic unsigned en_acc;

	controlFSM #(8,10) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr_w), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid));

	datapath #(16, 1) datapathMod(.clk(clk), .reset(reset), .m_out(m_out), .v_out(v_out),
									.en_acc(en_acc), .output_data(output_data), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	memory #(16, 10 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	fc_8_10_16_1_1_W_rom  matrixRom(.clk(clk), .addr(addr_w), .z(m_out));

endmodule

module fc_8_10_16_1_1_W_rom(clk, addr, z);
   input clk;
   input [6:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd122;
        1: z <= 16'd66;
        2: z <= -16'd50;
        3: z <= 16'd71;
        4: z <= -16'd112;
        5: z <= 16'd55;
        6: z <= 16'd9;
        7: z <= -16'd57;
        8: z <= 16'd104;
        9: z <= 16'd4;
        10: z <= 16'd39;
        11: z <= -16'd5;
        12: z <= 16'd48;
        13: z <= 16'd73;
        14: z <= 16'd110;
        15: z <= 16'd124;
        16: z <= -16'd86;
        17: z <= 16'd83;
        18: z <= 16'd72;
        19: z <= 16'd65;
        20: z <= -16'd80;
        21: z <= 16'd88;
        22: z <= 16'd46;
        23: z <= -16'd45;
        24: z <= -16'd93;
        25: z <= 16'd119;
        26: z <= -16'd16;
        27: z <= -16'd84;
        28: z <= -16'd96;
        29: z <= 16'd75;
        30: z <= 16'd82;
        31: z <= -16'd102;
        32: z <= 16'd13;
        33: z <= -16'd96;
        34: z <= 16'd98;
        35: z <= 16'd29;
        36: z <= 16'd88;
        37: z <= -16'd21;
        38: z <= 16'd100;
        39: z <= 16'd64;
        40: z <= 16'd111;
        41: z <= 16'd12;
        42: z <= -16'd69;
        43: z <= 16'd32;
        44: z <= -16'd43;
        45: z <= -16'd87;
        46: z <= 16'd28;
        47: z <= -16'd1;
        48: z <= 16'd125;
        49: z <= -16'd28;
        50: z <= -16'd63;
        51: z <= -16'd83;
        52: z <= -16'd68;
        53: z <= 16'd111;
        54: z <= 16'd0;
        55: z <= -16'd33;
        56: z <= 16'd103;
        57: z <= 16'd112;
        58: z <= 16'd12;
        59: z <= -16'd121;
        60: z <= 16'd59;
        61: z <= -16'd34;
        62: z <= -16'd95;
        63: z <= -16'd56;
        64: z <= -16'd1;
        65: z <= -16'd125;
        66: z <= 16'd102;
        67: z <= -16'd41;
        68: z <= -16'd17;
        69: z <= 16'd74;
        70: z <= -16'd105;
        71: z <= -16'd34;
        72: z <= -16'd42;
        73: z <= -16'd45;
        74: z <= 16'd126;
        75: z <= 16'd43;
        76: z <= -16'd4;
        77: z <= 16'd27;
        78: z <= -16'd85;
        79: z <= -16'd7;
      endcase
   end
endmodule

