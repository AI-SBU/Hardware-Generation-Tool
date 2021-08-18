module fc_5_2_9_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 5;
	parameter N = 2;
	parameter T = 9;
	parameter R = 1;
	localparam LOGSIZE_M = $clog2(M*N);
	localparam LOGSIZE_N = $clog2(N);

	input clk, reset, input_valid, output_ready;
	input signed [T-1 : 0] input_data;
	output signed [T-1 : 0] output_data;
	output output_valid, input_ready;

	logic unsigned[3 : 0] addr_w;
	logic unsigned[0 : 0] addr_x;
	logic signed [8 : 0] v_out, m_out;
	logic unsigned wr_en_x;
	logic unsigned clear_acc;
	logic unsigned en_acc;

	controlFSM #(5,2) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr_w), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid));

	datapath #(9, 1) datapathMod(.clk(clk), .reset(reset), .m_out(m_out), .v_out(v_out),
									.en_acc(en_acc), .output_data(output_data), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	memory #(9, 2 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	fc_5_2_9_1_1_W_rom  matrixRom(.clk(clk), .addr(addr_w), .z(m_out));

endmodule

module fc_5_2_9_1_1_W_rom(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [8:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -9'd3;
        1: z <= -9'd6;
        2: z <= 9'd1;
        3: z <= -9'd6;
        4: z <= 9'd3;
        5: z <= 9'd0;
        6: z <= -9'd1;
        7: z <= 9'd5;
        8: z <= -9'd8;
        9: z <= 9'd1;
      endcase
   end
endmodule

