# SPI Master UVM Verification Environment

Complete UVM testbench for a configurable SPI Master controller.

## What's Inside
- SPI Master RTL (SystemVerilog) - supports all 4 CPOL/CPHA modes
- UVM Agent (Driver + Monitor + Sequencer)
- Scoreboard with protocol checking
- Constrained-random sequences covering all SPI modes
- Functional coverage

## Results
- 20 transactions driven across all 4 SPI modes
- 19/19 scoreboard checks passing
- Zero UVM errors

## Tools
- Xilinx Vivado 2025.2 (xsim)
- SystemVerilog / UVM 1.2
- Tested on Basys3 Artix-7 FPGA
