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
        0: z <= 16'd91;
        1: z <= -16'd82;
        2: z <= -16'd6;
        3: z <= 16'd32;
        4: z <= -16'd5;
        5: z <= 16'd109;
        6: z <= 16'd73;
        7: z <= -16'd10;
        8: z <= -16'd28;
        9: z <= -16'd47;
        10: z <= -16'd23;
        11: z <= -16'd84;
        12: z <= 16'd15;
        13: z <= 16'd69;
        14: z <= 16'd85;
        15: z <= -16'd19;
        16: z <= 16'd49;
        17: z <= 16'd56;
        18: z <= -16'd64;
        19: z <= 16'd37;
        20: z <= -16'd54;
        21: z <= 16'd32;
        22: z <= -16'd23;
        23: z <= 16'd75;
        24: z <= 16'd16;
        25: z <= 16'd16;
        26: z <= -16'd35;
        27: z <= 16'd1;
        28: z <= 16'd3;
        29: z <= -16'd45;
        30: z <= 16'd118;
        31: z <= -16'd34;
        32: z <= 16'd1;
        33: z <= -16'd16;
        34: z <= 16'd126;
        35: z <= 16'd125;
        36: z <= -16'd34;
        37: z <= 16'd71;
        38: z <= -16'd13;
        39: z <= 16'd66;
        40: z <= -16'd103;
        41: z <= 16'd92;
        42: z <= 16'd110;
        43: z <= 16'd40;
        44: z <= 16'd34;
        45: z <= 16'd67;
        46: z <= -16'd106;
        47: z <= -16'd45;
        48: z <= -16'd5;
        49: z <= -16'd42;
        50: z <= 16'd121;
        51: z <= 16'd69;
        52: z <= 16'd118;
        53: z <= -16'd30;
        54: z <= 16'd16;
        55: z <= 16'd6;
        56: z <= 16'd115;
        57: z <= 16'd109;
        58: z <= -16'd121;
        59: z <= -16'd10;
        60: z <= -16'd64;
        61: z <= 16'd125;
        62: z <= 16'd84;
        63: z <= 16'd66;
      endcase
   end
endmodule

