`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Tanish Shet & Siddanth Ganpathy
// 
// Create Date: 12/16/2025 11:57:15 AM
// Design Name: TB_uart_rx_only
// Module Name: tb_uart_rx_only
// Project Name: UART_Test
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision: 01/02/2026
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module tb_uart_rx_only;
  localparam CLK_FREQ = 50_000_000;
  localparam BAUD     = 115200;
  localparam BIT_TIME = 1_000_000_000 / BAUD; // ns
  
  logic clk;
  logic rst_n;
  logic uart_rx;
  logic [7:0] rx_data;
  logic [7:0] exp_;
  logic rx_req;
  logic fifo_empty;
  logic fifo_full;
  logic rx_error;
  logic rts;
  
  /* DUT */
  uart_rx_fifo_wrapper #(
    .SystemClockFreq(CLK_FREQ),
    .BaudRate(BAUD)
  ) dut (
    .i_clk        (clk),
    .i_rst_n      (rst_n),
    .i_rx         (uart_rx),
    .i_rx_req     (rx_req),
    .o_rx_data    (rx_data),
    .o_fifo_empty (fifo_empty),
    .o_fifo_full  (fifo_full),
    .o_rx_error   (rx_error),
    .o_rts        (rts)
  );
  
  /* Clock: 50 MHz */
  initial clk = 0;
  always #10 clk = ~clk;
  
  /* Test sequence */
  initial begin
    rst_n   = 0;
    uart_rx = 1; // idle
    rx_req  = 0;
    #200;
    rst_n = 1;
    
    // ---- Test cases ----
    exp_ = 8'hBC;
    send_byte(exp_);
    exp_ = 8'h00;
    send_byte(exp_);
    exp_ = 8'h10;
    send_byte(exp_);
    exp_ = 8'h01;
    send_byte(exp_);
    exp_ = 8'hFF;
    send_byte(exp_);
    exp_ = 8'h0F;
    send_byte(exp_);
    exp_ = 8'hF0;
    send_byte(exp_);
    exp_ = 8'hAA;
    send_byte(exp_);
    
    check(8'hBC);
    check(8'h00);
    check(8'h10);
    check(8'h01);
    check(8'hFF);
    check(8'h0F);
    check(8'hF0);
    check(8'hAA);
    
    #500;
    $display("ALL TESTS PASSED");
    $finish;
  end
  
  /* Send one byte and verify FIFO output */
/*  task send_and_check(input logic [7:0] exp);
    begin
      send_byte(exp);
      // wait until RX FIFO has data
      wait (~fifo_empty);
      // read FIFO (SYNC READ!)
      rx_req = 1;
      if (rx_data !== exp) begin
        $error("RX MISMATCH: expected 0x%02X, got 0x%02X", exp, rx_data);
        $finish;
      end else begin
        $display("RX OK: 0x%02X", rx_data);
      end
      @(posedge clk);      // <-- REQUIRED
      rx_req = 0;
      @(posedge clk);      // allow data to settle
      
      // gap between frames
      #(BIT_TIME * 3);
    end
  endtask */
  
  task check(input logic [7:0] exp);
    begin
      // wait until RX FIFO has data
      wait (!fifo_empty);
      // read FIFO (SYNC READ!)
      rx_req = 1;
      @(posedge clk);      // <-- REQUIRED
      if (rx_data !== exp) begin
        $error("RX MISMATCH: expected 0x%02X, got 0x%02X", exp, rx_data);
        $finish;
      end else begin
        $display("RX OK: 0x%02X", rx_data);
      end
      
      rx_req = 0;
      @(posedge clk);      // allow data to settle
      
      // gap between frames
   //   #(BIT_TIME * 3);
    end
  endtask
  
  /* UART serial byte sender */
  task send_byte(input logic [7:0] data);
    integer i;
    begin
      // start bit
      uart_rx = 0;
      #(BIT_TIME);
      // data bits LSB first
      for (i = 0; i < 8; i++) begin
        uart_rx = data[i];
        #(BIT_TIME);
      end
      // stop bit
      uart_rx = 1;
      #(BIT_TIME);
    end
  endtask
endmodule