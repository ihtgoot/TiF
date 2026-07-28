module pipelined_adder #(
    parameter WIDTH  = 16,
    parameter STAGES = 4
)(
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   in_valid,
    output logic                   in_ready,
    input  logic [WIDTH-1:0]       a,
    input  logic [WIDTH-1:0]       b,
    output logic                   out_valid,
    input  logic                   out_ready,
    output logic [WIDTH-1:0]       sum
);

    logic [WIDTH-1:0] partial_sum [0:STAGES];
    logic              valid_pipe  [0:STAGES];

    assign partial_sum[0] = a + b;
    assign valid_pipe[0]  = in_valid && in_ready;
    assign in_ready       = 1'b1;

    genvar i;
    generate
        for (i = 0; i < STAGES; i++) begin : pipe_stage
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    partial_sum[i+1] <= '0;
                    valid_pipe[i+1]  <= 1'b0;
                end else if (out_ready) begin
                    partial_sum[i+1] <= partial_sum[i];
                    valid_pipe[i+1]  <= valid_pipe[i];
                end
            end
        end
    endgenerate

    assign sum       = partial_sum[STAGES];
    assign out_valid = valid_pipe[STAGES];

endmodule
