`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_transaction extends uvm_sequence_item;

    // Randomizable fields
    rand logic [7:0] mosi_data;   // data to transmit
    rand logic [1:0] mode;        // SPI mode 0-3
    rand logic [7:0] miso_data;   // data received (driven by monitor)

    // Constraints
    constraint valid_mode_c {
        mode inside {2'b00, 2'b01, 2'b10, 2'b11};
    }

    constraint typical_data_c {
        mosi_data dist {
            8'h00       := 5,   // all zeros corner case
            8'hFF       := 5,   // all ones corner case
            [8'h01:8'hFE] := 90  // typical data
        };
    }

    // UVM factory registration
    `uvm_object_utils_begin(spi_transaction)
        `uvm_field_int(mosi_data, UVM_ALL_ON)
        `uvm_field_int(mode,      UVM_ALL_ON)
        `uvm_field_int(miso_data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "spi_transaction");
        super.new(name);
    endfunction

    // Convert to string for debug
    function string convert2string();
        return $sformatf("mode=%0b mosi=0x%0h miso=0x%0h",
                         mode, mosi_data, miso_data);
    endfunction

endclass