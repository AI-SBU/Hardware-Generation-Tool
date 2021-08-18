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
    logic signed [WIDTH - 1 : 0] m_data_out_y;
    
    /*
    NOTE:
        "<=" nonblocking assignment  and is used for sequential logic
        "=" blocking assignment and is used for combinational logic
    */

    // computation/accumulation
    always_comb begin
        intermediate = (v_out * m_out); //2 computations 
    end

    //output logic
    always_ff @(posedge clk) begin
        if(clear_acc) begin
            //m_data_out_y <= 0;
        end
        else if (en_acc) begin
            if(result > 2**(WIDTH-1) -1) begin 
                //$display($time, "result saturate high");
                //$display("%d", result);
                //m_data_out_y <= 2**(WIDTH-1) -1;
                output_data <= 2**(WIDTH-1) -1;
            end
            else if(result < -(2**(WIDTH-1))) begin
                //$display($time, "result saturate low");
                if(R == 1) output_data <= 0;
                else begin                    
                    //m_data_out_y <= -(2**(WIDTH-1));
                    output_data <= -(2**(WIDTH-1));
                end
            end
            else begin
                //$display("m_data_out_y <= result");
                //m_data_out_y <= result; 
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
