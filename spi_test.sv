`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_base_test extends uvm_test;

    `uvm_component_utils(spi_base_test)

    spi_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = spi_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        spi_random_seq seq;
        phase.raise_objection(this);
        seq = spi_random_seq::type_id::create("seq");
        seq.num_transfers = 20;
        seq.start(env.agent.seqr);
        phase.drop_objection(this);
    endtask

endclass

class spi_corner_test extends spi_base_test;

    `uvm_component_utils(spi_corner_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        spi_corner_seq seq;
        phase.raise_objection(this);
        seq = spi_corner_seq::type_id::create("seq");
        seq.start(env.agent.seqr);
        phase.drop_objection(this);
    endtask

endclass

class spi_mode_sweep_test extends spi_base_test;

    `uvm_component_utils(spi_mode_sweep_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        spi_mode_sweep_seq seq;
        phase.raise_objection(this);
        seq = spi_mode_sweep_seq::type_id::create("seq");
        seq.start(env.agent.seqr);
        phase.drop_objection(this);
    endtask

endclass