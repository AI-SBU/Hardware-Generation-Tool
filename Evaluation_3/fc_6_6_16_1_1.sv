`include "controlFSM.sv"
`include "datapath.sv"
`include "memory.sv"

module fc_6_6_16_1_1(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);

	parameter M = 6;
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

	controlFSM #(6,6) controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready),
									.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr_w), .en_acc(en_acc), .clear_acc(clear_acc),
									.input_ready(input_ready), .output_valid(output_valid));

	datapath #(16, 1) datapathMod(.clk(clk), .reset(reset), .m_out(m_out), .v_out(v_out),
									.en_acc(en_acc), .output_data(output_data), .clear_acc(clear_acc), .output_valid(output_valid),
									.output_ready(output_ready));

	memory #(16, 6 )  vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));

	fc_6_6_16_1_1_W_rom  matrixRom(.clk(clk), .addr(addr_w), .z(m_out));

endmodule

module fc_6_6_16_1_1_W_rom(clk, addr, z);
   input clk;
   input [5:0] addr;
   output logic signed [15:0] z;
   always_ff @(posedge clk) begin
      case(addr)
        0: z <= 16'd113;
        1: z <= -16'd42;
        2: z <= -16'd14;
        3: z <= 16'd32;
        4: z <= -16'd15;
        5: z <= 16'd27;
        6: z <= 16'd62;
        7: z <= -16'd83;
        8: z <= 16'd50;
        9: z <= 16'd37;
        10: z <= 16'd46;
        11: z <= 16'd96;
        12: z <= -16'd123;
        13: z <= 16'd61;
        14: z <= 16'd44;
        15: z <= 16'd31;
        16: z <= -16'd21;
        17: z <= -16'd107;
        18: z <= -16'd108;
        19: z <= -16'd80;
        20: z <= -16'd12;
        21: z <= 16'd12;
        22: z <= -16'd61;
        23: z <= 16'd92;
        24: z <= 16'd10;
        25: z <= 16'd69;
        26: z <= 16'd47;
        27: z <= 16'd5;
        28: z <= 16'd53;
        29: z <= 16'd47;
        30: z <= -16'd81;
        31: z <= 16'd38;
        32: z <= -16'd123;
        33: z <= 16'd33;
        34: z <= -16'd58;
        35: z <= -16'd9;
      endcase
   end
endmodule

