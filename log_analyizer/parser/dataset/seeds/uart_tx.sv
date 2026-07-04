module uart_tx #(
    parameter CLKS_PER_BIT = 87
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx_active,
    output logic       tx_serial,
    output logic       tx_done
);

    typedef enum logic [2:0] {
        S_IDLE,
        S_START,
        S_DATA,
        S_STOP,
        S_DONE
    } state_t;

    state_t              state;
    logic [15:0]          clk_count;
    logic [2:0]            bit_index;
    logic [7:0]             tx_data_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= S_IDLE;
            tx_serial   <= 1'b1;
            tx_active   <= 1'b0;
            tx_done     <= 1'b0;
            clk_count   <= '0;
            bit_index   <= '0;
        end else begin
            unique case (state)
                S_IDLE: begin
                    tx_serial <= 1'b1;
                    tx_done   <= 1'b0;
                    clk_count <= '0;
                    bit_index <= '0;
                    if (tx_start) begin
                        tx_active   <= 1'b1;
                        tx_data_reg <= tx_data;
                        state       <= S_START;
                    end
                end

                S_START: begin
                    tx_serial <= 1'b0;
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= '0;
                        state     <= S_DATA;
                    end
                end

                S_DATA: begin
                    tx_serial <= tx_data_reg[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= '0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1'b1;
                        end else begin
                            bit_index <= '0;
                            state     <= S_STOP;
                        end
                    end
                end

                S_STOP: begin
                    tx_serial <= 1'b1;
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        state <= S_DONE;
                    end
                end

                S_DONE: begin
                    tx_active <= 1'b0;
                    tx_done   <= 1'b1;
                    state     <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
