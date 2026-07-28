module spi_master #(
    parameter CLK_DIV = 4,
    parameter DATA_WIDTH = 8
)(
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   start,
    input  logic [DATA_WIDTH-1:0]  tx_data,
    output logic [DATA_WIDTH-1:0]  rx_data,
    output logic                   busy,
    output logic                   done,

    output logic                   sclk,
    output logic                   mosi,
    input  logic                   miso,
    output logic                   cs_n
);

    typedef enum logic [1:0] {S_IDLE, S_TRANSFER, S_DONE} state_t;

    state_t                    state;
    logic [DATA_WIDTH-1:0]     shift_reg;
    logic [$clog2(DATA_WIDTH):0] bit_count;
    logic [$clog2(CLK_DIV):0]    clk_count;
    logic                       sclk_int;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            shift_reg <= '0;
            bit_count <= '0;
            clk_count <= '0;
            sclk_int  <= 1'b0;
            cs_n      <= 1'b1;
            busy      <= 1'b0;
            done      <= 1'b0;
            rx_data   <= '0;
        end else begin
            unique case (state)
                S_IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        shift_reg <= tx_data;
                        bit_count <= '0;
                        clk_count <= '0;
                        cs_n      <= 1'b0;
                        busy      <= 1'b1;
                        state     <= S_TRANSFER;
                    end
                end

                S_TRANSFER: begin
                    if (clk_count < CLK_DIV - 1) begin
                        clk_count <= clk_count + 1'b1;
                    end else begin
                        clk_count <= '0;
                        sclk_int  <= ~sclk_int;

                        if (sclk_int) begin
                            shift_reg <= {shift_reg[DATA_WIDTH-2:0], miso};
                            if (bit_count < DATA_WIDTH - 1) begin
                                bit_count <= bit_count + 1'b1;
                            end else begin
                                state <= S_DONE;
                            end
                        end
                    end
                end

                S_DONE: begin
                    cs_n    <= 1'b1;
                    busy    <= 1'b0;
                    done    <= 1'b1;
                    rx_data <= shift_reg;
                    state   <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

    assign sclk = sclk_int;
    assign mosi = shift_reg[DATA_WIDTH-1];

endmodule
