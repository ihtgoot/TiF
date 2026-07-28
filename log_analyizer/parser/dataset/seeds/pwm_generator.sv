// Same complexity class as fsm_traffic_light.sv, but a free-running
// counter-compare PWM generator instead of an enumerated FSM
module pwm_generator #(
    parameter WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] duty_cycle,
    output logic             pwm_out
);

    logic [WIDTH-1:0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else begin
            count <= count + 1'b1;
        end
    end

    always_comb begin
        pwm_out = (count < duty_cycle);
    end

endmodule
