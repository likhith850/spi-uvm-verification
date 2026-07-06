`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_monitor extends uvm_monitor;

    `uvm_component_utils(spi_monitor)

    virtual spi_if.monitor_mp vif;

    // Analysis port — sends transactions to scoreboard
    uvm_analysis_port #(spi_transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual spi_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Monitor: virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        spi_transaction txn;

        forever begin
            // Wait for start of transaction
            @(posedge vif.clk iff vif.monitor_cb.start);

            txn = spi_transaction::type_id::create("txn");

            // Capture transaction details
            txn.mosi_data = vif.monitor_cb.mosi_data;
            txn.mode      = vif.monitor_cb.mode;

            // Wait for completion
            @(posedge vif.clk iff vif.monitor_cb.done);
            txn.miso_data = vif.monitor_cb.miso_data;

            `uvm_info("MONITOR", $sformatf("Captured: %s", txn.convert2string()), UVM_MEDIUM)

            // Send to scoreboard
            ap.write(txn);
        end
    endtask

endclass