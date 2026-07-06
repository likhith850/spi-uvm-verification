`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_env extends uvm_env;

    `uvm_component_utils(spi_env)

    spi_agent      agent;
    spi_scoreboard scb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = spi_agent::type_id::create("agent", this);
        scb   = spi_scoreboard::type_id::create("scb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.mon.ap.connect(scb.analysis_export);
    endfunction

endclass