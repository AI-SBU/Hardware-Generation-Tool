`include "controlFSM.sv"
`include "datapath.sv"
`include "memory.sv"

module fc_8_4_16_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

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

	logic unsigned[4 : 0] addr_w;
	logic unsigned[1 : 0] addr_x;
	logic signed [15 : 0] v_out, m_out;
	logic unsigned wr_en_x;
	logic unsigned clear_acc;
	logic unsigned en_acc;

	controlFSM #(8,4) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr_w), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid));

	datapath #(16, 1) datapathMod(.clk(clk), .reset(reset), .m_out(m_out), .v_out(v_out),
									.en_acc(en_acc), .output_data(output_data), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	memory #(16, 4 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	fc_8_4_16_1_1_W_rom  matrixRom(.clk(clk), .addr(addr_w), .z(m_out));

endmodule

module fc_8_4_16_1_1_W_rom(clk, addr, z);
   input clk;
   input [4:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd3;
        1: z <= 16'd118;
        2: z <= -16'd123;
        3: z <= -16'd114;
        4: z <= 16'd119;
        5: z <= 16'd86;
        6: z <= -16'd101;
        7: z <= 16'd107;
        8: z <= -16'd114;
        9: z <= 16'd53;
        10: z <= 16'd55;
        11: z <= -16'd65;
        12: z <= 16'd124;
        13: z <= 16'd67;
        14: z <= 16'd2;
        15: z <= -16'd80;
        16: z <= -16'd76;
        17: z <= 16'd117;
        18: z <= 16'd78;
        19: z <= -16'd15;
        20: z <= -16'd51;
        21: z <= 16'd65;
        22: z <= 16'd67;
        23: z <= 16'd23;
        24: z <= -16'd21;
        25: z <= -16'd58;
        26: z <= -16'd121;
        27: z <= 16'd85;
        28: z <= -16'd54;
        29: z <= 16'd30;
        30: z <= 16'd9;
        31: z <= 16'd77;
      endcase
   end
endmodule

