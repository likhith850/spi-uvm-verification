// SPI Master Controller
// Supports CPOL=0, CPHA=0 (Mode 0) and Mode 1,2,3
// Parameterizable data width

module spi_master #(
    parameter DATA_WIDTH = 8,
    parameter CLK_DIV    = 4    // SCLK = clk / (2 * CLK_DIV)
)(
    input  logic                  clk,
    input  logic                  rst_n,

    // Control interface
    input  logic                  start,       // pulse to start transfer
    input  logic [1:0]            mode,        // CPOL/CPHA: 00,01,10,11
    input  logic [DATA_WIDTH-1:0] mosi_data,   // data to send
    output logic [DATA_WIDTH-1:0] miso_data,   // data received
    output logic                  done,        // pulse when transfer complete
    output logic                  busy,        // high during transfer

    // SPI pins
    output logic                  sclk,
    output logic                  cs_n,        // chip select, active low
    output logic                  mosi,
    input  logic                  miso
);

    // Internal signals
    logic [7:0]            clk_cnt;
    logic [DATA_WIDTH-1:0] shift_reg;
    logic [DATA_WIDTH-1:0] recv_reg;
    logic [4:0]            bit_cnt;
    logic                  sclk_r;
    logic                  cpol, cpha;

    assign cpol = mode[1];
    assign cpha = mode[0];

    // FSM states
    typedef enum logic [1:0] {
        IDLE     = 2'b00,
        ASSERT_CS = 2'b01,
        TRANSFER = 2'b10,
        DEASSERT = 2'b11
    } state_t;

    state_t curr_state, next_state;

    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) curr_state <= IDLE;
        else        curr_state <= next_state;
    end

    // Clock divider for SCLK generation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt <= '0;
            sclk_r  <= 1'b0;
        end else if (curr_state == TRANSFER) begin
            if (clk_cnt == CLK_DIV - 1) begin
                clk_cnt <= '0;
                sclk_r  <= ~sclk_r;
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end else begin
            clk_cnt <= '0;
            sclk_r  <= cpol; // idle state depends on CPOL
        end
    end

    assign sclk = sclk_r ^ cpol; // adjust for CPOL

    // Next state logic
    always_comb begin
        next_state = curr_state;
        case (curr_state)
            IDLE:      if (start)               next_state = ASSERT_CS;
            ASSERT_CS:                           next_state = TRANSFER;
            TRANSFER:  if (bit_cnt == DATA_WIDTH) next_state = DEASSERT;
            DEASSERT:                            next_state = IDLE;
            default:                             next_state = IDLE;
        endcase
    end

    // Shift register — load on start, shift on SCLK edge
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= '0;
            recv_reg  <= '0;
            bit_cnt   <= '0;
            miso_data <= '0;
        end else begin
            case (curr_state)
                IDLE: begin
                    bit_cnt   <= '0;
                    shift_reg <= mosi_data;
                end
                TRANSFER: begin
                    // Sample on appropriate SCLK edge based on CPHA
                    if (clk_cnt == CLK_DIV - 1) begin
                        if (!sclk_r) begin // rising edge of SCLK
                            if (!cpha) begin
                                recv_reg  <= {recv_reg[DATA_WIDTH-2:0], miso};
                                shift_reg <= {shift_reg[DATA_WIDTH-2:0], 1'b0};
                                bit_cnt   <= bit_cnt + 1;
                            end
                        end else begin // falling edge
                            if (cpha) begin
                                recv_reg  <= {recv_reg[DATA_WIDTH-2:0], miso};
                                shift_reg <= {shift_reg[DATA_WIDTH-2:0], 1'b0};
                                bit_cnt   <= bit_cnt + 1;
                            end
                        end
                    end
                end
                DEASSERT: begin
                    miso_data <= recv_reg;
                end
                default: ;
            endcase
        end
    end

    // Output assignments
    assign mosi = shift_reg[DATA_WIDTH-1];
    assign cs_n = (curr_state == IDLE || curr_state == DEASSERT);
    assign busy = (curr_state != IDLE);
    assign done = (curr_state == DEASSERT);

endmodule