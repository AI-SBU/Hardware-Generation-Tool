`include "controlFSM.sv"
`include "datapath.sv"
`include "memory.sv"

module fc_6_8_16_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 6;
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

	controlFSM #(6,8) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr_w), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid));

	datapath #(16, 1) datapathMod(.clk(clk), .reset(reset), .m_out(m_out), .v_out(v_out),
									.en_acc(en_acc), .output_data(output_data), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	memory #(16, 8 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	fc_6_8_16_1_1_W_rom  matrixRom(.clk(clk), .addr(addr_w), .z(m_out));

endmodule

module fc_6_8_16_1_1_W_rom(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd127;
        1: z <= -16'd57;
        2: z <= 16'd116;
        3: z <= 16'd96;
        4: z <= -16'd93;
        5: z <= -16'd10;
        6: z <= -16'd73;
        7: z <= 16'd87;
        8: z <= -16'd3;
        9: z <= 16'd57;
        10: z <= 16'd73;
        11: z <= 16'd88;
        12: z <= 16'd80;
        13: z <= 16'd105;
        14: z <= 16'd95;
        15: z <= -16'd34;
        16: z <= -16'd8;
        17: z <= 16'd105;
        18: z <= 16'd123;
        19: z <= -16'd105;
        20: z <= 16'd4;
        21: z <= -16'd82;
        22: z <= 16'd81;
        23: z <= -16'd112;
        24: z <= 16'd123;
        25: z <= -16'd15;
        26: z <= 16'd91;
        27: z <= 16'd10;
        28: z <= 16'd15;
        29: z <= -16'd115;
        30: z <= -16'd108;
        31: z <= 16'd17;
        32: z <= -16'd44;
        33: z <= -16'd120;
        34: z <= -16'd15;
        35: z <= -16'd9;
        36: z <= -16'd2;
        37: z <= 16'd41;
        38: z <= -16'd50;
        39: z <= 16'd124;
        40: z <= -16'd30;
        41: z <= -16'd104;
        42: z <= 16'd84;
        43: z <= -16'd78;
        44: z <= -16'd127;
        45: z <= 16'd52;
        46: z <= 16'd16;
        47: z <= -16'd7;
      endcase
   end
endmodule

