// Mirror of uart_tx.sv (receiver instead of transmitter), one-hot state
// encoding instead of default binary encoding
module uart_rx #(
    parameter CLKS_PER_BIT = 87
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       rx_serial,
    output logic [7:0] rx_data,
    output logic       rx_done
);

    typedef enum logic [4:0] {
        S_IDLE  = 5'b00001,
        S_START = 5'b00010,
        S_DATA  = 5'b00100,
        S_STOP  = 5'b01000,
        S_DONE  = 5'b10000
    } state_t;

    state_t              state;
    logic [15:0]          clk_count;
    logic [2:0]           bit_index;
    logic [7:0]           rx_shift;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            clk_count <= '0;
            bit_index <= '0;
            rx_shift  <= '0;
            rx_done   <= 1'b0;
            rx_data   <= '0;
        end else begin
            unique case (state)
                S_IDLE: begin
                    rx_done <= 1'b0;
                    if (rx_serial == 1'b0) begin
                        clk_count <= '0;
                        state     <= S_START;
                    end
                end

                S_START: begin
                    if (clk_count < (CLKS_PER_BIT - 1) / 2) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= '0;
                        bit_index <= '0;
                        state     <= S_DATA;
                    end
                end

                S_DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count            <= '0;
                        rx_shift[bit_index]  <= rx_serial;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1'b1;
                        end else begin
                            state <= S_STOP;
                        end
                    end
                end

                S_STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        state <= S_DONE;
                    end
                end

                S_DONE: begin
                    rx_data <= rx_shift;
                    rx_done <= 1'b1;
                    state   <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
