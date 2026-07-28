module i2c_master (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic [6:0] slave_addr,
    input  logic       rw,
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       busy,
    output logic       done,
    output logic       ack_error,

    inout  wire        sda,
    output logic        scl
);

    typedef enum logic [3:0] {
        S_IDLE, S_START, S_ADDR, S_ADDR_ACK,
        S_DATA, S_DATA_ACK, S_STOP
    } state_t;

    state_t state;

    logic [3:0]                bit_count;
    logic [7:0]                shift_reg;
    logic                      sda_out;
    logic                      sda_oe;

    assign sda = sda_oe ? sda_out : 1'bz;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_IDLE;
            bit_count  <= '0;
            shift_reg  <= '0;
            sda_out    <= 1'b1;
            sda_oe     <= 1'b1;
            scl        <= 1'b1;
            busy       <= 1'b0;
            done       <= 1'b0;
            ack_error  <= 1'b0;
            rx_data    <= '0;
        end else begin
            done <= 1'b0;

            unique case (state)
                S_IDLE: begin
                    if (start) begin
                        shift_reg <= {slave_addr, rw};
                        bit_count <= '0;
                        busy      <= 1'b1;
                        sda_out   <= 1'b0;
                        state     <= S_START;
                    end
                end

                S_START: begin
                    scl   <= 1'b0;
                    state <= S_ADDR;
                end

                S_ADDR: begin
                    sda_out <= shift_reg[7];
                    scl     <= 1'b1;
                    if (bit_count < 7) begin
                        bit_count <= bit_count + 1'b1;
                        shift_reg <= shift_reg << 1;
                    end else begin
                        state <= S_ADDR_ACK;
                    end
                end

                S_ADDR_ACK: begin
                    sda_oe    <= 1'b0;
                    ack_error <= sda;
                    shift_reg <= tx_data;
                    bit_count <= '0;
                    state     <= S_DATA;
                end

                S_DATA: begin
                    sda_oe  <= 1'b1;
                    sda_out <= shift_reg[7];
                    if (bit_count < 7) begin
                        bit_count <= bit_count + 1'b1;
                        shift_reg <= shift_reg << 1;
                    end else begin
                        state <= S_DATA_ACK;
                    end
                end

                S_DATA_ACK: begin
                    sda_oe <= 1'b0;
                    rx_data <= shift_reg;
                    state   <= S_STOP;
                end

                S_STOP: begin
                    sda_oe  <= 1'b1;
                    sda_out <= 1'b1;
                    busy    <= 1'b0;
                    done    <= 1'b1;
                    state   <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
