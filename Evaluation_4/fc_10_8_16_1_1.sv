`include "controlFSM.sv"
`include "datapath.sv"
`include "memory.sv"

module fc_10_8_16_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 10;
	parameter N = 8;
	parameter T = 16;
	parameter R = 1;
	localparam LOGSIZE_M = $clog2(M*N);
	localparam LOGSIZE_N = $clog2(N);

	input clk, reset, input_valid, output_ready;
	input signed [T-1 : 0] input_data;
	output signed [T-1 : 0] output_data;
	output output_valid, input_ready;

	logic unsigned[6 : 0] addr_w;
	logic unsigned[2 : 0] addr_x;
	logic signed [15 : 0] v_out, m_out;
	logic unsigned wr_en_x;
	logic unsigned clear_acc;
	logic unsigned en_acc;

	controlFSM #(10,8) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr_w), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid));

	datapath #(16, 1) datapathMod(.clk(clk), .reset(reset), .m_out(m_out), .v_out(v_out),
									.en_acc(en_acc), .output_data(output_data), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	memory #(16, 8 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	fc_10_8_16_1_1_W_rom  matrixRom(.clk(clk), .addr(addr_w), .z(m_out));

endmodule

module fc_10_8_16_1_1_W_rom(clk, addr, z);
   input clk;
   input [6:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd28;
        1: z <= 16'd15;
        2: z <= -16'd20;
        3: z <= -16'd14;
        4: z <= -16'd7;
        5: z <= 16'd110;
        6: z <= 16'd125;
        7: z <= 16'd109;
        8: z <= -16'd21;
        9: z <= 16'd101;
        10: z <= -16'd30;
        11: z <= -16'd65;
        12: z <= 16'd114;
        13: z <= 16'd74;
        14: z <= 16'd5;
        15: z <= 16'd70;
        16: z <= 16'd51;
        17: z <= 16'd109;
        18: z <= 16'd5;
        19: z <= 16'd117;
        20: z <= -16'd38;
        21: z <= 16'd126;
        22: z <= -16'd71;
        23: z <= 16'd70;
        24: z <= -16'd77;
        25: z <= -16'd78;
        26: z <= -16'd17;
        27: z <= 16'd62;
        28: z <= -16'd75;
        29: z <= 16'd66;
        30: z <= 16'd123;
        31: z <= 16'd25;
        32: z <= -16'd47;
        33: z <= -16'd25;
        34: z <= -16'd117;
        35: z <= 16'd74;
        36: z <= -16'd42;
        37: z <= -16'd120;
        38: z <= 16'd56;
        39: z <= 16'd65;
        40: z <= 16'd110;
        41: z <= -16'd102;
        42: z <= -16'd128;
        43: z <= 16'd96;
        44: z <= 16'd100;
        45: z <= 16'd5;
        46: z <= 16'd38;
        47: z <= 16'd24;
        48: z <= -16'd13;
        49: z <= -16'd85;
        50: z <= 16'd13;
        51: z <= 16'd77;
        52: z <= -16'd87;
        53: z <= 16'd70;
        54: z <= 16'd19;
        55: z <= -16'd35;
        56: z <= 16'd120;
        57: z <= -16'd126;
        58: z <= -16'd101;
        59: z <= -16'd83;
        60: z <= 16'd68;
        61: z <= -16'd106;
        62: z <= 16'd70;
        63: z <= -16'd106;
        64: z <= -16'd2;
        65: z <= 16'd82;
        66: z <= 16'd96;
        67: z <= 16'd84;
        68: z <= 16'd90;
        69: z <= 16'd24;
        70: z <= 16'd21;
        71: z <= 16'd72;
        72: z <= 16'd51;
        73: z <= 16'd21;
        74: z <= 16'd40;
        75: z <= 16'd23;
        76: z <= -16'd102;
        77: z <= -16'd49;
        78: z <= -16'd81;
        79: z <= 16'd13;
      endcase
   end
endmodule

