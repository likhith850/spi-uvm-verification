`include "uvm_macros.svh"
import uvm_pkg::*;

// Base sequence
class spi_base_seq extends uvm_sequence #(spi_transaction);
    `uvm_object_utils(spi_base_seq)
    function new(string name = "spi_base_seq");
        super.new(name);
    endfunction
endclass

// Random transfer sequence — basic random test
class spi_random_seq extends spi_base_seq;
    `uvm_object_utils(spi_random_seq)

    int unsigned num_transfers = 10;

    function new(string name = "spi_random_seq");
        super.new(name);
    endfunction

    task body();
        spi_transaction txn;
        repeat(num_transfers) begin
            txn = spi_transaction::type_id::create("txn");
            start_item(txn);
            if (!txn.randomize())
                `uvm_fatal("SEQ", "Randomization failed")
            finish_item(txn);
        end
    endtask
endclass

// Corner case sequence — all zeros, all ones, alternating
class spi_corner_seq extends spi_base_seq;
    `uvm_object_utils(spi_corner_seq)

    function new(string name = "spi_corner_seq");
        super.new(name);
    endfunction

    task body();
        spi_transaction txn;

        // Test all zeros
        txn = spi_transaction::type_id::create("txn");
        start_item(txn);
        txn.mosi_data = 8'h00;
        txn.mode      = 2'b00;
        finish_item(txn);

        // Test all ones
        txn = spi_transaction::type_id::create("txn");
        start_item(txn);
        txn.mosi_data = 8'hFF;
        txn.mode      = 2'b00;
        finish_item(txn);

        // Test alternating bits
        txn = spi_transaction::type_id::create("txn");
        start_item(txn);
        txn.mosi_data = 8'hAA;
        txn.mode      = 2'b01;
        finish_item(txn);

        // Back to back transfers — all 4 modes
        foreach (txn.mode[i]) begin
            txn = spi_transaction::type_id::create("txn");
            start_item(txn);
            txn.mosi_data = $urandom;
            txn.mode      = i[1:0];
            finish_item(txn);
        end
    endtask
endclass

// Mode sweep sequence — covers all 4 SPI modes
class spi_mode_sweep_seq extends spi_base_seq;
    `uvm_object_utils(spi_mode_sweep_seq)

    function new(string name = "spi_mode_sweep_seq");
        super.new(name);
    endfunction

    task body();
        spi_transaction txn;
        for (int m = 0; m < 4; m++) begin
            repeat(5) begin
                txn = spi_transaction::type_id::create("txn");
                start_item(txn);
                if (!txn.randomize() with {mode == m[1:0];})
                    `uvm_fatal("SEQ", "Randomization failed")
                finish_item(txn);
            end
        end
    endtask
endclass