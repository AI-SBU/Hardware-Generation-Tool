`include "controlFSM.sv"
`include "datapath.sv"
`include "memory.sv"

module fc_8_6_16_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 8;
	parameter N = 6;
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

	controlFSM #(8,6) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr_w), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid));

	datapath #(16, 1) datapathMod(.clk(clk), .reset(reset), .m_out(m_out), .v_out(v_out),
									.en_acc(en_acc), .output_data(output_data), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	memory #(16, 6 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	fc_8_6_16_1_1_W_rom  matrixRom(.clk(clk), .addr(addr_w), .z(m_out));

endmodule

module fc_8_6_16_1_1_W_rom(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd87;
        1: z <= 16'd67;
        2: z <= -16'd79;
        3: z <= -16'd124;
        4: z <= 16'd31;
        5: z <= -16'd64;
        6: z <= 16'd31;
        7: z <= 16'd21;
        8: z <= -16'd107;
        9: z <= 16'd82;
        10: z <= -16'd6;
        11: z <= 16'd40;
        12: z <= -16'd85;
        13: z <= 16'd66;
        14: z <= -16'd106;
        15: z <= -16'd59;
        16: z <= 16'd65;
        17: z <= -16'd89;
        18: z <= -16'd95;
        19: z <= -16'd105;
        20: z <= -16'd43;
        21: z <= 16'd66;
        22: z <= 16'd94;
        23: z <= 16'd82;
        24: z <= -16'd34;
        25: z <= 16'd17;
        26: z <= 16'd123;
        27: z <= -16'd27;
        28: z <= -16'd74;
        29: z <= 16'd81;
        30: z <= 16'd126;
        31: z <= -16'd115;
        32: z <= 16'd21;
        33: z <= -16'd81;
        34: z <= -16'd111;
        35: z <= -16'd76;
        36: z <= -16'd17;
        37: z <= 16'd48;
        38: z <= 16'd73;
        39: z <= 16'd5;
        40: z <= 16'd3;
        41: z <= -16'd61;
        42: z <= -16'd83;
        43: z <= 16'd46;
        44: z <= -16'd122;
        45: z <= -16'd61;
        46: z <= 16'd115;
        47: z <= 16'd71;
      endcase
   end
endmodule

