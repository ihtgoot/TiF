module shift_register #(
    parameter WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             shift_en,
    input  logic             serial_in,
    input  logic             load,
    input  logic [WIDTH-1:0] parallel_in,
    output logic [WIDTH-1:0] parallel_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            parallel_out <= '0;
        end else if (load) begin
            parallel_out <= parallel_in;
        end else if (shift_en) begin
            parallel_out <= {parallel_out[WIDTH-2:0], serial_in};
        end
    end

endmodule
