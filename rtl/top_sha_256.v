module top_sha_256 # (
    parameter INPUT_WIDTH = 448
)(
    input clk,
    input reset,
    input start,
    input [INPUT_WIDTH - 1:0] raw_msg_in,
    output reg [255:0] hash_out = 0,
    output reg complete = 0
    );
    
    wire [511:0] padded_msg;
    wire padding_done;
    reg start_hash = 0;
    wire [255:0] hash_internal;
    wire hash_done;
    
    pading_new #(.INPUT_WIDTH(INPUT_WIDTH)) padding_inst (
        .clk(clk),
        .rst(reset),
        .start(start),
        .raw_msg_in(raw_msg_in),
        .padded_msg(padded_msg),
        .done(padding_done)
    );
    
    sha hash_core_inst(
        .clk(clk),
        .reset(reset),
        .start(start_hash),
        .data_block(padded_msg),
        .hash(hash_internal),
        .complete(hash_done)
    );
    
    reg [1:0] state;
    localparam IDLE = 2'd0;    
    localparam WAIT_PAD_1 = 2'd1;    
    localparam START_HASH_1 = 2'd2;    
    localparam WAIT_HASH_1 = 2'd3;  
    
    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            start_hash<= 0;
            complete <= 0;
            hash_out <= 256'd0;
        end else begin
            case (state)
                IDLE : begin
                    complete <= 0;
                    start_hash <= 0;
                    if (start)
                        state <= WAIT_PAD_1;
                end
                WAIT_PAD_1 : begin
                    if(padding_done)
                        state <= START_HASH_1;
                end
                START_HASH_1 : begin
                    start_hash <= 1;
                    state <= WAIT_HASH_1;
                end
                WAIT_HASH_1 : begin
                    start_hash <= 0;
                    if (hash_done) begin
                        hash_out <= hash_internal;
                        complete <= 1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end    
endmodule