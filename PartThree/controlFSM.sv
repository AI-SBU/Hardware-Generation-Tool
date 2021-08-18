module controlFSM(clk, reset, input_valid, output_ready, addr_x, wr_en_x,addr_w,
                 clear_acc, en_acc, input_ready, output_valid, countToP);

    parameter M = 12;
    parameter N = 12;
    parameter P = 1;
    
    localparam LOGSIZE_M = $clog2(M*N); //# of bits required for addressing matrix
    localparam LOGSIZE_N = $clog2(N);
    localparam LOGSIZE_P = $clog2(P);
    localparam JUMP = N*(P-1) + 1; 

    input clk;
    input reset;
    input input_valid;
    input output_ready;

    output logic unsigned [LOGSIZE_N-1 : 0] addr_x; // connect to vector mod
    output logic unsigned [LOGSIZE_M-1 : 0] addr_w; // connect to vector mod
    output logic wr_en_x; // connect to vector mod

    output logic clear_acc;
    output logic en_acc;
    output logic input_ready;
    output logic output_valid;
    //output logic output_now; //asserted when output_valid && output_ready are 1
    
    logic unsigned [LOGSIZE_N : 0] countLoad; //counting the address index
    logic unsigned [LOGSIZE_M : 0] countComp; //Matrix * Vector computations, m*n
    logic unsigned [LOGSIZE_N - 1: 0] countVec;
    logic unsigned iterationDone;
    logic unsigned loadingDone;
    logic unsigned [LOGSIZE_M : 0] out_index_count; 
    logic unsigned temp;

     
    logic unsigned [LOGSIZE_N-1 : 0] countToN;
    output logic unsigned [LOGSIZE_P-1 : 0] countToP;
    

    typedef enum logic [1:0] {Loading, Compute} State;

    State currentState, nextState;

    //state register
    always_ff @(posedge clk) begin
        if(reset) begin
            currentState <= Loading;
            
        end
        else currentState <= nextState;
    end

    //next state logic
    always_comb begin
        case (currentState)
            Loading: begin
                if(countLoad == N) begin
                    loadingDone = 1;
                    nextState = Compute; //use count as a condition                    
                end 
                else begin
                    nextState = Loading;
                    loadingDone = 0;
                end
            end

            Compute: begin
                loadingDone = 0;
                if(out_index_count == M) nextState = Loading;
                else nextState = Compute;
            end

            default: begin
                nextState = Loading;
                loadingDone = 0;
            end
        endcase
    end


    //output logic
    always_comb begin
        if (currentState == Loading) begin
            addr_w = 0;

            if(countLoad < N) begin
                input_ready = 1;
                wr_en_x = 1;
            end
            else begin
                input_ready = 0;
                wr_en_x = 0;
            end

            if(input_valid && input_ready) begin
                if(countLoad < N) begin
                    wr_en_x = 1; 
                    addr_x = countLoad;
                end
                else begin
                    wr_en_x = 0;
                    addr_x = 0;
                end
            end

            else begin
                wr_en_x = 0;
                addr_x = 0;
            end
        end

        //compute state
        else if (currentState == Compute) begin
            wr_en_x = 0;
            input_ready = 0;
            addr_w = countComp;
            addr_x = countVec;
        end
        else begin
            input_ready = 0;
            wr_en_x = 0;
            addr_x = 0;
            addr_w = 0;
        end
    end

    always_ff @(posedge clk) begin
        if(currentState == Loading) begin
            if(reset) countLoad <= 0;
            countComp <= 0;
            countVec <= 0;
            countToN <= 0;
            countToP <= 0;
            en_acc <= 0;
            clear_acc <= 1; 
            output_valid <= 0;
            iterationDone <= 0;
            temp <= 0;
            out_index_count <= 0;
            if(loadingDone == 1)begin
                countLoad <= 0;
            end
            if(input_valid && input_ready)
                countLoad <= countLoad + 1; //cycle/address counter for Loading state
        end

        if(currentState == Compute)begin
            if(iterationDone) begin
                
                countVec <= 0;
                countToN <= 0;
                
                en_acc <= 0;
                output_valid <= 1;
                if(output_ready && output_valid)begin
                    countToP <= countToP + 1;                    

                    if(countToP == P-1) begin
                        clear_acc <= 1;
                        countToP <= 0;
                        output_valid <= 0;
                        iterationDone <= 0;
                    end
                    
                    temp <= 1;
                    out_index_count <= out_index_count + 1;
                    //out_index_count <= out_index_count + P; // 9 values, 
                end 
            end

            else begin
                clear_acc <= 0;
                if(countComp == 0 || temp || countVec != 0 ) begin //0, 1, 2, 3,4,5,6,7  

                    if(countToN == N-1) begin
                        countComp <= countComp + JUMP;
                    end
                    else begin
                        countToN <= countToN + 1;
                        countComp <= countComp + 1;
                    end
                    
                    if(countVec == N-1) countVec <= 0;
                    else countVec <= countVec + 1;

                    en_acc <= 1;
                    output_valid <= 0;
                    temp <= 0; 
                end        
                else begin
                    iterationDone <= 1;
                end
            end 
        end
    end
endmodule
