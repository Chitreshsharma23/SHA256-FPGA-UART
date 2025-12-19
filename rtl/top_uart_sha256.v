module top_uart_sha256(
    input clk_p,
    input clk_n,
    input rst,
    input rx_serial,
    output tx_serial
);
    parameter INPUT_WIDTH = 448;
    
    wire clk;
    // UART internal signals
    wire [7:0] rx_data;
    wire rx_ready;
    reg tx_start = 0;
    reg [7:0] tx_data = 0;
    wire tx_busy;

    // SHA-related signals
    reg [INPUT_WIDTH-1:0] raw_msg = 0;
    reg [5:0] byte_count = 0;
    reg start_sha = 0;
    wire [255:0] hash;
    wire complete;
    
    
    IBUFDS #(
    .DIFF_TERM("TRUE"),     // Differential termination
    .IBUF_LOW_PWR("FALSE")  // For better signal integrity
    )ibufds_clk (
        .I(clk_p),
        .IB(clk_n),
        .O(clk)
    );

    // UART Module Instance
    uart #(
        .CLK_FREQ(200_000_000),
        .BAUD_RATE(115200)
    ) uart_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_serial(tx_serial),
        .rx_serial(rx_serial),
        .rx_ready(rx_ready),
        .rx_data(rx_data)
    );
    


    // SHA Wrapper Module Instance
    top_sha_256 #(.INPUT_WIDTH(INPUT_WIDTH)) sha_inst (
        .clk(clk),
        .reset(rst),
        .start(start_sha),
        .raw_msg_in(raw_msg),
        .hash_out(hash),
        .complete(complete)
    );

    // FSM States
    reg [2:0] state = 0;
    localparam IDLE = 3'd0;
    localparam RECEIVE = 3'd1;
    localparam WAIT_HASH = 3'd2;
    localparam SEND_HASH = 3'd3;
    localparam DONE = 3'd4;

    reg [5:0] tx_byte_index = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            byte_count <= 0;
            raw_msg <= 0;
            start_sha <= 0;
            tx_start <= 0;
            tx_data <= 0;
            tx_byte_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    byte_count <= 0;
                    raw_msg <= 0;
                    tx_start <= 0;
                    if (rx_ready) state <= RECEIVE;
                end

                RECEIVE: begin
                    if (rx_ready) begin
                        raw_msg <= {raw_msg[INPUT_WIDTH-9:0], rx_data};
                        byte_count <= byte_count + 1;
                        if (byte_count == 55) begin
                            start_sha <= 1;
                            state <= WAIT_HASH;
                        end
                    end
                end

                WAIT_HASH: begin
                    start_sha <= 0;
                    if (complete) begin
                        tx_byte_index <= 0;
                        state <= SEND_HASH;
                    end
                end

                SEND_HASH: begin
                    if (!tx_busy && !tx_start) begin
                        tx_data <= hash[255 - tx_byte_index*8 -: 8];
                        tx_start <= 1;
                    end else if (tx_start) begin
                        tx_start <= 0;
                        tx_byte_index <= tx_byte_index + 1;
                        if (tx_byte_index == 31)
                            state <= DONE;
                    end
                end

                DONE: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule