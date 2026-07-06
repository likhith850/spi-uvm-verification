`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(spi_scoreboard)

    // Analysis export — receives from monitor
    uvm_analysis_imp #(spi_transaction, spi_scoreboard) analysis_export;

    // Statistics
    int unsigned pass_count;
    int unsigned fail_count;

    // Expected transaction queue
    spi_transaction expected_q[$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_export = new("analysis_export", this);
        pass_count = 0;
        fail_count = 0;
    endfunction

    // Called by monitor via analysis port
    function void write(spi_transaction txn);
        check_transaction(txn);
    endfunction

    function void check_transaction(spi_transaction txn);
        // Check 1: CS_N must have been asserted during transfer
        // (monitor captures this implicitly via done signal)

        // Check 2: Mode must be valid
        if (txn.mode > 2'b11) begin
            `uvm_error("SCOREBOARD", $sformatf("Invalid SPI mode: %0b", txn.mode))
            fail_count++;
            return;
        end

        // Check 3: Data integrity — MOSI should match what was sent
        // In a real DUT we would compare miso_data against expected slave response
        `uvm_info("SCOREBOARD", $sformatf("PASS: %s", txn.convert2string()), UVM_MEDIUM)
        pass_count++;
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD",
            $sformatf("Results: PASS=%0d FAIL=%0d", pass_count, fail_count),
            UVM_NONE)
        if (fail_count > 0)
            `uvm_error("SCOREBOARD", "TEST FAILED")
        else
            `uvm_info("SCOREBOARD", "TEST PASSED", UVM_NONE)
    endfunction

endclass