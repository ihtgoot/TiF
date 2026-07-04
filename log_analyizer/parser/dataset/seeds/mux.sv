module mux #(
    parameter WIDTH   = 8,
    parameter N_INPUT = 4,
    parameter SEL_W   = $clog2(N_INPUT)
)(
    input  logic [N_INPUT-1:0][WIDTH-1:0] data_in,
    input  logic [SEL_W-1:0]              sel,
    output logic [WIDTH-1:0]              data_out
);

    always_comb begin
        data_out = data_in[sel];
    end

endmodule
