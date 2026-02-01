# UART_Test (RTL)

This module implements a complete hardware data path starting from UART
reception up to ALU processing.

## Data Flow

UART RX → FIFO → BRAM (Write FSM) → BRAM (Read FSM) → ALU → Seven
Segment Display

## Modules Included

-   `uart_rx_fifo_wrapper` : Receives serial UART data and buffers into
    FIFO
-   `Write FSM` : Fetches bytes from FIFO and writes sequentially into
    BRAM
-   `blk_mem_gen` : Vivado BRAM IP used for data storage (8 depth × 8
    width)
-   `Read FSM` : Reads A/B pairs from BRAM and triggers ALU
-   `alu_wrapper` : Performs arithmetic operation and drives seven
    segment display
-   `uart_alu_top` : Top level integration of all modules

## Design Highlights

-   Proper FIFO handshake using `rx_req`
-   BRAM read latency handling
-   Alternating A/B data pattern from memory
-   Coordination between write and read operations using busy flags
