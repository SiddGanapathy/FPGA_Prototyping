`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Siddanth Ganpathy & Gagan M
// 
// Create Date: 12/16/2025 11:57:15 AM
// Design Name: TB_uart_bram_alu
// Module Name: tb_uart_bram_alu
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
module tb_uart_bram_alu;

  // ============================================================
  // Parameters
  // ============================================================
  localparam CLK_FREQ     = 100_000_000;
  localparam BAUD         = 115200;
  localparam CLKS_PER_BIT = CLK_FREQ / BAUD;   // 434 clocks

  // ============================================================
  // DUT Signals
  // ============================================================
  logic i_clk;
  logic i_rst_n;
  logic uart_rx;
  logic op_sel_sw;

  wire [6:0] seg;
  wire [3:0] an;

  // ============================================================
  // DUT Instance
  // ============================================================
  uart_alu_top dut (
      .i_clk     (i_clk),
      .i_rst_n   (i_rst_n),
      .uart_rx   (uart_rx),
      .op_sel_sw (op_sel_sw),
      .seg       (seg),
      .an        (an)
  );

  // ============================================================
  // Clock Generation (50 MHz)
  // ============================================================
  initial i_clk = 0;
  always #10 i_clk = ~i_clk;  // 20ns period

  // ============================================================
  // UART Byte Send Task (CLOCK SYNCHRONOUS)
  // ============================================================
  task send_uart_byte(input [7:0] data);
    integer i;
    begin
      // Start bit
      uart_rx = 0;
      repeat (CLKS_PER_BIT) @(posedge i_clk);

      // Data bits (LSB first)
      for (i = 0; i < 8; i++) begin
        uart_rx = data[i];
        repeat (CLKS_PER_BIT) @(posedge i_clk);
      end

      // Stop bit
      uart_rx = 1;
      repeat (CLKS_PER_BIT) @(posedge i_clk);

      // Gap
      repeat (CLKS_PER_BIT) @(posedge i_clk);
    end
  endtask

  // ============================================================
  // ===================== MONITORS =============================
  // ============================================================

  // UART FIFO pop monitor
  always @(posedge i_clk) begin
    if (dut.rx_req && !dut.fifo_empty) begin
      $display("[%0t] UART RX BYTE = %0d",
                $time, dut.rx_data);
    end
  end

  // BRAM WRITE monitor
  always @(posedge i_clk) begin
    if (dut.wstrb) begin
      $display("[%0t] BRAM WRITE  Addr=%0d Data=%0d",
                $time, dut.bram_addr, dut.data_in);
    end
  end

  // BRAM READ monitor
  always @(posedge i_clk) begin
    if (!dut.wstrb && dut.alu_start) begin
      $display("[%0t] BRAM READ   Addr=%0d Data=%0d",
                $time, dut.bram_addr, dut.bram_dout);
    end
  end

  // ALU monitor
  always @(posedge i_clk) begin
    if (dut.alu_start) begin
      $display("[%0t] ALU START   A=%0d B=%0d",
                $time, dut.a, dut.b);
    end

    if (dut.alu_done) begin
      $display("[%0t] ALU DONE    Result displayed on 7-seg",
                $time);
    end
  end

    // ============================================================
  // Switch Toggle During Operation
  // ============================================================
  initial begin
    // Wait until first ALU operation surely starts
    repeat (20000) @(posedge i_clk);

    $display("\n[%0t] >>> Changing op_sel_sw to 1 <<<\n", $time);
    op_sel_sw = 1;

    // Keep it for some time
    repeat (30000) @(posedge i_clk);

    $display("\n[%0t] >>> Changing op_sel_sw back to 0 <<<\n", $time);
    op_sel_sw = 0;
  end
  // ============================================================
  // Test Sequence
  // ============================================================  
  initial begin
    uart_rx   = 1;   // UART idle
    op_sel_sw = 0;

    // Reset
    i_rst_n = 0;
    repeat (20) @(posedge i_clk);
    i_rst_n = 1;

    // Wait for system to settle
    repeat (50) @(posedge i_clk);

    // Send 8 bytes: A0,B0,A1,B1,A2,B2,A3,B3
    send_uart_byte(8'd10);  // A0
    send_uart_byte(8'd5);   // B0

    send_uart_byte(8'd20);  // A1
    send_uart_byte(8'd4);   // B1
    
    send_uart_byte(8'd7);   // A2
    send_uart_byte(8'd3);   // B2
 
    send_uart_byte(8'd15);  // A3
    send_uart_byte(8'd2);   // B3

    // Allow time for BRAM read → ALU → display
    repeat (50000) @(posedge i_clk);

    $finish;
  end

endmodule
