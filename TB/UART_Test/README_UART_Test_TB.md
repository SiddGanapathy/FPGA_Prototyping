# UART_Test (Testbench)

This testbench verifies the complete RTL data path by sending UART
stimulus directly to the top module.

## Verification Flow

1.  UART bytes are transmitted at 115200 baud synchronized to a 50 MHz
    clock
2.  Data is received into FIFO and written into BRAM
3.  Read FSM fetches A/B pairs and starts the ALU
4.  Console monitors display BRAM writes, BRAM reads, and ALU activity

## Observability Added

-   UART byte monitor when FIFO is popped
-   BRAM write address and data logging
-   BRAM read address and data logging
-   ALU start and completion logs

## Purpose

This is a directed testbench intended to debug system-level integration
issues such as:

-   UART timing problems
-   FIFO handshake errors
-   BRAM read latency mistakes
-   FSM sequencing issues
