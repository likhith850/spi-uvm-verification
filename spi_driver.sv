`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_driver extends uvm_driver #(spi_transaction);

    `uvm_component_utils(spi_driver)

    virtual spi_if.driver_mp vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual spi_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Driver: virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        spi_transaction txn;

        // Initialize signals
        vif.driver_cb.start     <= 1'b0;
        vif.driver_cb.mosi_data <= '0;
        vif.driver_cb.mode      <= '0;
        vif.driver_cb.miso      <= 1'b0;

        forever begin
            // Get next transaction from sequencer
            seq_item_port.get_next_item(txn);

            // Drive the transaction
            drive_transaction(txn);

            // Signal done to sequencer
            seq_item_port.item_done();
        end
    endtask

    task drive_transaction(spi_transaction txn);
        // Load data and mode
        @(vif.driver_cb);
        vif.driver_cb.mosi_data <= txn.mosi_data;
        vif.driver_cb.mode      <= txn.mode;
        vif.driver_cb.miso      <= $random; // simulate slave response

        // Pulse start
        @(vif.driver_cb);
        vif.driver_cb.start <= 1'b1;
        @(vif.driver_cb);
        vif.driver_cb.start <= 1'b0;

        // Wait for transfer to complete
        @(posedge vif.clk iff vif.done);
        @(vif.driver_cb);

        `uvm_info("DRIVER", $sformatf("Drove: %s", txn.convert2string()), UVM_MEDIUM)
    endtask

endclass