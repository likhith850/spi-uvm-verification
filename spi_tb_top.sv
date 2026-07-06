`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

// Import all UVM classes
`include "spi_transaction.sv"
`include "spi_driver.sv"
`include "spi_monitor.sv"
`include "spi_scoreboard.sv"
`include "spi_agent.sv"
`include "spi_sequences.sv"
`include "spi_env.sv"
`include "spi_test.sv"

module spi_tb_top;

    // Clock and reset
    logic clk;
    logic rst_n;

    // Clock generation — 100MHz
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset generation
    initial begin
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
    end

    // Interface instantiation
    spi_if dut_if(.clk(clk), .rst_n(rst_n));

    // DUT instantiation
    spi_master #(
        .DATA_WIDTH(8),
        .CLK_DIV(4)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .start     (dut_if.start),
        .mode      (dut_if.mode),
        .mosi_data (dut_if.mosi_data),
        .miso_data (dut_if.miso_data),
        .done      (dut_if.done),
        .busy      (dut_if.busy),
        .sclk      (dut_if.sclk),
        .cs_n      (dut_if.cs_n),
        .mosi      (dut_if.mosi),
        .miso      (dut_if.miso)
    );

initial begin
    uvm_config_db #(virtual spi_if)::set(
        null, "uvm_test_top.*", "vif", dut_if);
    #50ns; // wait for reset to complete
    run_test("spi_base_test");
end

// Timeout watchdog
initial begin
    #100us;
    $display("TIMEOUT - simulation ended");
    $finish;
end

endmodule
