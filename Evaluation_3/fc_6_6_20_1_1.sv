`include "controlFSM.sv"
`include "datapath.sv"
`include "memory.sv"

module fc_6_6_20_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 6;
	parameter N = 6;
	parameter T = 20;
	parameter R = 1;
	localparam LOGSIZE_M = $clog2(M*N);
	localparam LOGSIZE_N = $clog2(N);

	input clk, reset, input_valid, output_ready;
	input signed [T-1 : 0] input_data;
	output signed [T-1 : 0] output_data;
	output output_valid, input_ready;

	logic unsigned[5 : 0] addr_w;
	logic unsigned[2 : 0] addr_x;
	logic signed [19 : 0] v_out, m_out;
	logic unsigned wr_en_x;
	logic unsigned clear_acc;
	logic unsigned en_acc;

	controlFSM #(6,6) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr_w), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid));

	datapath #(20, 1) datapathMod(.clk(clk), .reset(reset), .m_out(m_out), .v_out(v_out),
									.en_acc(en_acc), .output_data(output_data), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	memory #(20, 6 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	fc_6_6_20_1_1_W_rom  matrixRom(.clk(clk), .addr(addr_w), .z(m_out));

endmodule

module fc_6_6_20_1_1_W_rom(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [19:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 20'd163;
        1: z <= -20'd103;
        2: z <= -20'd329;
        3: z <= 20'd75;
        4: z <= 20'd364;
        5: z <= -20'd10;
        6: z <= -20'd142;
        7: z <= 20'd184;
        8: z <= -20'd67;
        9: z <= -20'd178;
        10: z <= 20'd221;
        11: z <= -20'd6;
        12: z <= 20'd258;
        13: z <= -20'd15;
        14: z <= -20'd179;
        15: z <= -20'd140;
        16: z <= -20'd39;
        17: z <= 20'd365;
        18: z <= -20'd413;
        19: z <= 20'd183;
        20: z <= 20'd201;
        21: z <= 20'd346;
        22: z <= -20'd319;
        23: z <= 20'd27;
        24: z <= -20'd427;
        25: z <= -20'd255;
        26: z <= -20'd193;
        27: z <= 20'd176;
        28: z <= -20'd443;
        29: z <= 20'd473;
        30: z <= -20'd151;
        31: z <= 20'd232;
        32: z <= -20'd142;
        33: z <= 20'd32;
        34: z <= -20'd205;
        35: z <= -20'd289;
      endcase
   end
endmodule

