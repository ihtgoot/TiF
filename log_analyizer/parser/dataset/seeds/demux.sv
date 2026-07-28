// Mirror of mux.sv but 1:N demultiplexer, built with a generate block
// instead of a single always_comb + array indexing
module demux #(
    parameter WIDTH    = 8,
    parameter N_OUTPUT = 4,
    parameter SEL_W    = $clog2(N_OUTPUT)
)(
    input  logic [WIDTH-1:0]                data_in,
    input  logic [SEL_W-1:0]                 sel,
    output logic [N_OUTPUT-1:0][WIDTH-1:0]   data_out
);

    genvar i;
    generate
        for (i = 0; i < N_OUTPUT; i++) begin : demux_out
            assign data_out[i] = (sel == i) ? data_in : '0;
        end
    endgenerate

endmodule
