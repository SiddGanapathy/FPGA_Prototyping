# FPGA Prototyping Repository

This repository contains RTL designs and SystemVerilog testbenches
created for FPGA-based system prototyping. The focus is on building
complete data paths that integrate communication interfaces, memory,
control FSMs, and processing units into a working hardware pipeline.

The designs are structured to reflect how real FPGA systems are built
and debugged --- starting from individual modules and gradually
integrating them into a complete top-level design verified through
simulation.

## Key Concepts Demonstrated

-   UART based data input into hardware
-   FIFO buffering and handshake design
-   BRAM based data storage using Vivado IP
-   Write and Read FSM coordination
-   ALU based data processing
-   Seven segment display output
-   Directed SystemVerilog testbenches for end‑to‑end verification

## Repository Structure

-   `rtl/` : Contains synthesizable RTL modules and top-level
    integrations
-   `tb/` : Contains SystemVerilog testbenches for simulation and
    verification

This project emphasizes understanding of real hardware timing,
handshakes, and memory behavior in FPGA systems.
