module fsm_traffic_light (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       tick,      // slow enable pulse
    output logic [2:0] lights     // {red, yellow, green}
);

    typedef enum logic [1:0] {
        S_RED,
        S_GREEN,
        S_YELLOW
    } state_t;

    state_t state;
    logic [3:0] timer;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_RED;
            timer <= '0;
        end else if (tick) begin
            unique case (state)
                S_RED: begin
                    if (timer < 4'd8) begin
                        timer <= timer + 1'b1;
                    end else begin
                        timer <= '0;
                        state <= S_GREEN;
                    end
                end

                S_GREEN: begin
                    if (timer < 4'd6) begin
                        timer <= timer + 1'b1;
                    end else begin
                        timer <= '0;
                        state <= S_YELLOW;
                    end
                end

                S_YELLOW: begin
                    if (timer < 4'd2) begin
                        timer <= timer + 1'b1;
                    end else begin
                        timer <= '0;
                        state <= S_RED;
                    end
                end

                default: state <= S_RED;
            endcase
        end
    end

    always_comb begin
        unique case (state)
            S_RED:    lights = 3'b100;
            S_GREEN:  lights = 3'b001;
            S_YELLOW: lights = 3'b010;
            default:  lights = 3'b100;
        endcase
    end

endmodule
