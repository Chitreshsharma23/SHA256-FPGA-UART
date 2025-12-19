module pading_new # (
    parameter INPUT_WIDTH = 448
    )(
      input wire clk,
      input wire rst,
      input wire start,
      input wire [INPUT_WIDTH - 1 : 0] raw_msg_in,
      output reg [511:0] padded_msg,
      output reg done = 0
      );
    
    // state machine
    reg [3:0] state;
    localparam IDLE =3'd0;
    localparam ALIGN =3'd1;
    localparam PAD =3'd2;
    localparam DONE_1 =3'd3;
    
    //Internal signals
    reg [INPUT_WIDTH - 1:0] msg_aligned = 0;
    reg [63:0]msg_len_bits = 0;
    reg [8:0] bit_index = 0;
    integer i;
    reg [8:0] shift_amount = 0;
    reg found = 0;
    reg [6:0] byte_len = 0;
    
    always @(posedge clk) begin
        if(rst)begin
            padded_msg <= 512'd0;
            done <= 1'b0;
            state <= IDLE;
        end else begin 
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state <= ALIGN;
                    end
                end
                ALIGN: begin
                    shift_amount = 0;
                    msg_len_bits = 0;
                    msg_aligned = 0;
                    found = 0;
                    for (i = 55; i >= 0; i = i - 1) begin
                        if(!found && (raw_msg_in [i*8 +: 8] != 8'b0)) begin
                            found = 1'b1;
                            byte_len = i + 1;
                        end
                    end
                    msg_len_bits = byte_len * 8;
                    shift_amount = INPUT_WIDTH - msg_len_bits;
                    msg_aligned = raw_msg_in << shift_amount;
                    state = PAD;
                end
                PAD: begin
                    padded_msg <= 512'd0;
                    padded_msg [511:512 - INPUT_WIDTH] <= msg_aligned;
                    bit_index = 512 - msg_len_bits - 1;
                    if ( bit_index >= 64 && bit_index < 512)
                        padded_msg [bit_index] <= 1'b1;
                    padded_msg [63:0] <= msg_len_bits;
                    state = DONE_1;
                end
                
                DONE_1 : begin
                    done <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule