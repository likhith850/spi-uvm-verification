`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_agent extends uvm_agent;

    `uvm_component_utils(spi_agent)

    spi_driver    drv;
    spi_monitor   mon;
    uvm_sequencer #(spi_transaction) seqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv  = spi_driver::type_id::create("drv",  this);
        mon  = spi_monitor::type_id::create("mon",  this);
        seqr = uvm_sequencer#(spi_transaction)::type_id::create("seqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction

endclass