module datapath(clk, reset, clear_acc, en_acc,
                output_data, output_ready, output_valid, m_out, v_out);
    
    parameter WIDTH = 12;
    parameter R = 0;

    input clk, reset;
    input unsigned clear_acc, en_acc;

    output logic signed [WIDTH-1 : 0] output_data;

    input logic output_ready;
    input logic output_valid;

    input logic signed [WIDTH - 1 : 0] v_out;
    input logic signed [WIDTH - 1 : 0] m_out;

    logic signed [WIDTH : 0] result;
    logic signed [WIDTH : 0] intermediate;
    
    /*
    NOTE:
        "<=" nonblocking assignment  and is used for sequential logic
        "=" blocking assignment and is used for combinational logic
    */

    // computation/accumulation
    always_comb begin
        if((v_out * m_out) > 2**(WIDTH-1) -1) intermediate = 2**(WIDTH-1) -1;
        else if((v_out * m_out) < -(2**(WIDTH-1))) intermediate = -(2**(WIDTH-1));
        else intermediate = (v_out * m_out); 
    end

    //output logic
    always_ff @(posedge clk) begin
        if(clear_acc) begin
        end
        else if (en_acc) begin
            if(result > 2**(WIDTH-1) -1) begin 
                output_data <= 2**(WIDTH-1) -1;
            end
            else if(result < -(2**(WIDTH-1))) begin
                if(R == 1) output_data <= 0;
                else begin                    
                    output_data <= -(2**(WIDTH-1));
                end
            end
            else begin

                if(R == 1 && result < 0)
                    output_data <= 0;
                else output_data <= result;                
            end
        end
    end
    always_ff @(posedge clk) begin
        if(clear_acc) begin
            result <= 0;
        end
        else if(en_acc) begin
            if((result + intermediate)  > 2**(WIDTH-1) -1) begin
                result <=  2**(WIDTH-1) -1;
            end
            else if ((result + intermediate) < -(2**(WIDTH-1))) begin
                result <= -(2**(WIDTH-1));
            end    
            else result <= intermediate + result;
        end
    end
endmodule
