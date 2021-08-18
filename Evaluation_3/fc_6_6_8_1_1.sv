`include "controlFSM.sv"
`include "datapath.sv"
`include "memory.sv"

module fc_6_6_8_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 6;
	parameter N = 6;
	parameter T = 8;
	parameter R = 1;
	localparam LOGSIZE_M = $clog2(M*N);
	localparam LOGSIZE_N = $clog2(N);

	input clk, reset, input_valid, output_ready;
	input signed [T-1 : 0] input_data;
	output signed [T-1 : 0] output_data;
	output output_valid, input_ready;

	logic unsigned[5 : 0] addr_w;
	logic unsigned[2 : 0] addr_x;
	logic signed [7 : 0] v_out, m_out;
	logic unsigned wr_en_x;
	logic unsigned clear_acc;
	logic unsigned en_acc;

	controlFSM #(6,6) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr_w), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid));

	datapath #(8, 1) datapathMod(.clk(clk), .reset(reset), .m_out(m_out), .v_out(v_out),
									.en_acc(en_acc), .output_data(output_data), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	memory #(8, 6 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	fc_6_6_8_1_1_W_rom  matrixRom(.clk(clk), .addr(addr_w), .z(m_out));

endmodule

module fc_6_6_8_1_1_W_rom(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [7:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 8'd5;
        1: z <= 8'd6;
        2: z <= -8'd5;
        3: z <= -8'd7;
        4: z <= 8'd6;
        5: z <= -8'd1;
        6: z <= 8'd1;
        7: z <= -8'd3;
        8: z <= -8'd4;
        9: z <= -8'd5;
        10: z <= -8'd8;
        11: z <= -8'd1;
        12: z <= 8'd0;
        13: z <= -8'd4;
        14: z <= 8'd0;
        15: z <= 8'd7;
        16: z <= -8'd2;
        17: z <= 8'd4;
        18: z <= -8'd6;
        19: z <= 8'd6;
        20: z <= 8'd7;
        21: z <= 8'd4;
        22: z <= 8'd5;
        23: z <= -8'd2;
        24: z <= 8'd1;
        25: z <= -8'd1;
        26: z <= 8'd7;
        27: z <= 8'd1;
        28: z <= -8'd4;
        29: z <= 8'd5;
        30: z <= 8'd3;
        31: z <= -8'd7;
        32: z <= 8'd4;
        33: z <= 8'd6;
        34: z <= -8'd5;
        35: z <= 8'd2;
      endcase
   end
endmodule

