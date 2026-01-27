`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.01.2026 11:13:16
// Design Name: 
// Module Name: Uart_top_tb
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

module tb_uart_alu_top;

    // =========================================================
    // Parameters
    // =========================================================
    parameter CLK_PERIOD = 10;      // 100 MHz
    parameter BAUD_RATE  = 115200;
    parameter BIT_TIME   = 8680;    // ns (1/115200)

    // =========================================================
    // DUT signals
    // =========================================================
    reg         i_clk;
    reg         i_rst_n;
    reg         uart_rx;
    reg         op_sel_sw;
    wire [6:0]  seg;
    wire [3:0]  an;

    // =========================================================
    // DUT
    // =========================================================
    uart_alu_top dut (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .uart_rx   (uart_rx),
        .op_sel_sw (op_sel_sw),
        .seg       (seg),
        .an        (an)
    );

    // =========================================================
    // Clock
    // =========================================================
    always #(CLK_PERIOD/2) i_clk = ~i_clk;

    // =========================================================
    // UART send task (8-N-1)
    // =========================================================
    task uart_send_byte;
        input [7:0] data;
        integer i;
        begin
            // start bit
            uart_rx = 1'b0;
            #(BIT_TIME);

            // data bits
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                #(BIT_TIME);
            end

            // stop bit
            uart_rx = 1'b1;
            #(BIT_TIME);
        end
    endtask

    // =========================================================
    // Simple test task
    // =========================================================
    task alu_test;
        input op;
        input [7:0] a;
        input [7:0] b;
        begin
            op_sel_sw = op;

            uart_send_byte(a);
            #(2*BIT_TIME);

            uart_send_byte(b);
            #(20*CLK_PERIOD); // wait for ALU + display
        end
    endtask

    // =========================================================
    // Test sequence
    // =========================================================
    initial begin
        // init
        i_clk     = 0;
        uart_rx  = 1'b1;
        op_sel_sw = 0;
        i_rst_n  = 0;

        // reset
        #(50);
        i_rst_n = 1;

        // -----------------------------------------------------
        // ADD tests
        // -----------------------------------------------------
        alu_test(0, 8'h02, 8'h03);  // 2 + 3
        alu_test(0, 8'h0A, 8'h05);  // 10 + 5
        alu_test(0, 8'h00, 8'h00);  // 0 + 0
        alu_test(0, 8'hFF, 8'h01);  // overflow case

        // -----------------------------------------------------
        // SUB tests
        // -----------------------------------------------------
        alu_test(1, 8'h09, 8'h04);  // 9 - 4
        alu_test(1, 8'h05, 8'h05);  // zero result
        alu_test(1, 8'h00, 8'h01);  // underflow case

        // -----------------------------------------------------
        // Back-to-back operations
        // -----------------------------------------------------
        alu_test(0, 8'h03, 8'h03);
        alu_test(1, 8'h08, 8'h02);

        // -----------------------------------------------------
        // End
        // -----------------------------------------------------
        #(1000);
        $display("SIMULATION DONE");
        $finish;
    end

endmodule

