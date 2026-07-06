// SPI Interface — connects DUT to testbench cleanly
interface spi_if (input logic clk, input logic rst_n);

    // Control signals
    logic                start;
    logic [1:0]          mode;
    logic [7:0]          mosi_data;
    logic [7:0]          miso_data;
    logic                done;
    logic                busy;

    // SPI pins
    logic                sclk;
    logic                cs_n;
    logic                mosi;
    logic                miso;

clocking driver_cb @(posedge clk);
    default input  #1 output #1;
    output start;
    output mode;
    output mosi_data;
    output miso;
    input  done;
    input  busy;
    input  miso_data;
    input  sclk;
    input  cs_n;
    input  mosi;
endclocking

    // Clocking block for monitor
    clocking monitor_cb @(posedge clk);
        default input #1;
        input start;
        input mode;
        input mosi_data;
        input miso_data;
        input done;
        input busy;
        input sclk;
        input cs_n;
        input mosi;
        input miso;
    endclocking

    modport driver_mp  (clocking driver_cb, input clk, input rst_n, input done, input busy);

    // Modport for monitor
    modport monitor_mp (clocking monitor_cb, input clk, input rst_n);

endinterface