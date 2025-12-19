module uart #(
    parameter CLK_FREQ = 200_000_000,  // System clock frequency
    parameter BAUD_RATE = 115200    // Desired baud rate
)(
    input wire clk,
    input wire rst,
    
    // Transmitter interface
    input wire tx_start,
    input wire [7:0] tx_data,
    output reg tx_busy,
    output reg tx_serial,
    
    // Receiver interface
    input wire rx_serial,
    output reg rx_ready = 0,
    output reg [7:0] rx_data
);

    // Calculate baud rate tick count
    localparam integer BAUD_TICK_COUNT = CLK_FREQ / BAUD_RATE;
    
    // Transmitter signals
    reg [15:0] tx_clk_count = 0;
    reg [3:0] tx_bit_index = 0;
    reg [9:0] tx_shift_reg = 10'b1111111111; // 1 start + 8 data + 1 stop
    
    // Receiver signals
    reg [15:0] rx_clk_count = 0;
    reg [3:0] rx_bit_index = 0;
    reg [9:0] rx_shift_reg = 0;
    reg rx_sampling = 0;
    reg rx_busy = 0;
    
    // ----------- TRANSMITTER -----------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_serial <= 1'b1; // Idle state is high
            tx_busy <= 0;
            tx_clk_count <= 0;
            tx_bit_index <= 0;
            tx_shift_reg <= 10'b1111111111;
        end else begin
            if (!tx_busy) begin
                if (tx_start) begin
                    // Load shift register: start bit (0), data bits, stop bit (1)
                    tx_shift_reg <= {1'b1, tx_data, 1'b0};
                    tx_busy <= 1;
                    tx_bit_index <= 0;
                    tx_clk_count <= 0;
                end else begin
                    tx_serial <= 1'b1; // Idle line high
                end
            end else begin
                if (tx_clk_count == BAUD_TICK_COUNT - 1) begin
                    tx_clk_count <= 0;
                    tx_serial <= tx_shift_reg[tx_bit_index];
                    tx_bit_index <= tx_bit_index + 1;
                    if (tx_bit_index == 9) begin
                        tx_busy <= 0; // Transmission done
                    end
                end else begin
                    tx_clk_count <= tx_clk_count + 1;
                end
            end
        end
    end

    // ----------- RECEIVER -----------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_ready <= 0;
            rx_data <= 8'b0;
            rx_clk_count <= 0;
            rx_bit_index <= 0;
            rx_busy <= 0;
            rx_sampling <= 0;
            rx_shift_reg <= 0;
        end else begin
//            rx_ready <= 0;  // Clear ready flag by default
            
            if (!rx_busy) begin
                // Wait for start bit (falling edge on rx_serial)
                if (rx_serial == 0) begin
                    rx_busy <= 1;
                    rx_clk_count <= BAUD_TICK_COUNT / 2; // Sample in the middle of bit
                    rx_bit_index <= 0;
                end
            end else begin
                if (rx_clk_count == BAUD_TICK_COUNT - 1) begin
                    rx_clk_count <= 0;
                    rx_bit_index <= rx_bit_index + 1;
                    rx_shift_reg <= {rx_serial, rx_shift_reg[9:1]};
                    if (rx_bit_index == 9) begin
                        rx_busy <= 0;
                        // Check stop bit and start bit
                        if (rx_shift_reg[0] == 0 && rx_serial == 1) begin
                            rx_data <= rx_shift_reg[8:1]; // Data bits
                            rx_ready <= 1; // Data received
                        end
                    end
                end else begin
                    rx_clk_count <= rx_clk_count + 1;
                    rx_ready <= 0;  // Clear ready flag by default
            
                end
            end
        end
    end

endmodule