module fc_4_4_16_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 4;
	parameter N = 4;
	parameter T = 16;
	parameter R = 1;
	localparam LOGSIZE_M = $clog2(M*N);
	localparam LOGSIZE_N = $clog2(N);

	input clk, reset, input_valid, output_ready;
	input signed [T-1 : 0] input_data;
	output signed [T-1 : 0] output_data;
	output output_valid, input_ready;

	logic unsigned[3 : 0] addr_w;
	logic unsigned[1 : 0] addr_x;
	logic signed [15 : 0] v_out, m_out;
	logic unsigned wr_en_x;
	logic unsigned clear_acc;
	logic unsigned en_acc;

	controlFSM #(4,4) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr_w), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid));

	datapath #(16, 1) datapathMod(.clk(clk), .reset(reset), .m_out(m_out), .v_out(v_out),
									.en_acc(en_acc), .output_data(output_data), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	memory #(16, 4 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	fc_4_4_16_1_1_W_rom  matrixRom(.clk(clk), .addr(addr_w), .z(m_out));

endmodule

module fc_4_4_16_1_1_W_rom(clk, addr, z);
   input clk;
   input [3:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= -16'd110;
        1: z <= 16'd69;
        2: z <= -16'd64;
        3: z <= 16'd76;
        4: z <= -16'd39;
        5: z <= 16'd103;
        6: z <= 16'd105;
        7: z <= 16'd44;
        8: z <= -16'd34;
        9: z <= -16'd73;
        10: z <= -16'd53;
        11: z <= 16'd68;
        12: z <= -16'd5;
        13: z <= 16'd116;
        14: z <= 16'd23;
        15: z <= -16'd78;
      endcase
   end
endmodule

