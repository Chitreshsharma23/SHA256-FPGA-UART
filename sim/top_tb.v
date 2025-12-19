`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.07.2025 06:19:27
// Design Name: 
// Module Name: top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_tb;


    // Differential clock signals
    reg clk_p = 0;
    reg clk_n = 1;
    wire clk = clk_p;

    // UART lines
    reg rx_serial = 1;  // Idle high
    wire tx_serial;

    // Reset
    reg rst;

    // Instantiate DUT
    top_uart_sha256 dut (
        .clk_p(clk_p),
        .clk_n(clk_n),
        .rst(rst),
        .rx_serial(rx_serial),
        .tx_serial(tx_serial)
    );

    // 200 MHz differential clock (5ns period)
    always begin
        #2.5 clk_p = ~clk_p;
        #2.5 clk_n = ~clk_n;
    end

    // 56-byte test message (exactly 448 bits)
//    reg [447:0] message = {
//        8'h61,8'h62,8'h63,8'h64,8'h65,8'h66,8'h67,8'h68,
//        8'h69,8'h6A,8'h6B,8'h6C,8'h6D,8'h6E,8'h6F,8'h70,
//        8'h71,8'h72,8'h73,8'h74,8'h75,8'h76,8'h77,8'h78,
//        8'h79,8'h7A,8'h41,8'h42,8'h43,8'h44,8'h45,8'h46,
//        8'h47,8'h48,8'h49,8'h4A,8'h4B,8'h4C,8'h4D,8'h4E,
//        8'h4F,8'h50,8'h51,8'h52,8'h53,8'h54,8'h55,8'h56,
//        8'h57,8'h58,8'h59,8'h5A,8'h30,8'h31,8'h32,8'h33
//    };
    reg [447:0] message = 448'h616263;
    integer i;
    reg [7:0] byte_to_send;

    initial begin
        // Initial setup
        rx_serial = 1;
        rst = 1;
        #100;
        rst = 0;

        // Send message via UART RX (LSB first)
        for (i = 55; i >= 0; i = i - 1) begin
            byte_to_send = message[i*8 +: 8];
            send_uart_byte(byte_to_send);
        end

        // Wait for hashing and UART TX of hash
//        wait(dut.sha_inst.complete == 1);  // wait for SHA done
        #200000;  // wait enough to see UART TX of full 256-bit hash
        #9000000;  // 9 milliseconds
        $finish;
    end

    // UART byte sender (115200 baud)
    task send_uart_byte(input [7:0] data);
        integer j;
        begin
            rx_serial = 0; // Start bit
            #(8680);
            for (j = 0; j < 8; j = j + 1) begin
                rx_serial = data[j];
                #(8680);
            end
            rx_serial = 1; // Stop bit
            #(8680);
        end
    endtask
    
endmodule


