`include "controlFSM.sv"
`include "datapath.sv"
`include "memory.sv"

module fc_6_6_12_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 6;
	parameter N = 6;
	parameter T = 12;
	parameter R = 1;
	localparam LOGSIZE_M = $clog2(M*N);
	localparam LOGSIZE_N = $clog2(N);

	input clk, reset, input_valid, output_ready;
	input signed [T-1 : 0] input_data;
	output signed [T-1 : 0] output_data;
	output output_valid, input_ready;

	logic unsigned[5 : 0] addr_w;
	logic unsigned[2 : 0] addr_x;
	logic signed [11 : 0] v_out, m_out;
	logic unsigned wr_en_x;
	logic unsigned clear_acc;
	logic unsigned en_acc;

	controlFSM #(6,6) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr_w), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid));

	datapath #(12, 1) datapathMod(.clk(clk), .reset(reset), .m_out(m_out), .v_out(v_out),
									.en_acc(en_acc), .output_data(output_data), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	memory #(12, 6 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	fc_6_6_12_1_1_W_rom  matrixRom(.clk(clk), .addr(addr_w), .z(m_out));

endmodule

module fc_6_6_12_1_1_W_rom(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [11:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -12'd6;
        1: z <= -12'd28;
        2: z <= 12'd22;
        3: z <= 12'd23;
        4: z <= 12'd3;
        5: z <= 12'd26;
        6: z <= 12'd29;
        7: z <= 12'd20;
        8: z <= 12'd30;
        9: z <= -12'd1;
        10: z <= -12'd12;
        11: z <= 12'd20;
        12: z <= 12'd27;
        13: z <= -12'd8;
        14: z <= 12'd14;
        15: z <= 12'd5;
        16: z <= -12'd6;
        17: z <= -12'd22;
        18: z <= 12'd16;
        19: z <= 12'd26;
        20: z <= 12'd0;
        21: z <= 12'd5;
        22: z <= -12'd28;
        23: z <= 12'd29;
        24: z <= -12'd4;
        25: z <= -12'd24;
        26: z <= -12'd10;
        27: z <= -12'd11;
        28: z <= 12'd15;
        29: z <= 12'd23;
        30: z <= -12'd14;
        31: z <= -12'd22;
        32: z <= 12'd27;
        33: z <= -12'd24;
        34: z <= -12'd31;
        35: z <= -12'd2;
      endcase
   end
endmodule

