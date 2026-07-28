// Same complexity class as adder_subtractor.sv, but pure combinational
// comparator built from ternary chains instead of arithmetic slicing
module magnitude_comparator #(
    parameter WIDTH = 8
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic             a_gt_b,
    output logic             a_eq_b,
    output logic             a_lt_b
);

    assign a_gt_b = (a > b) ? 1'b1 : 1'b0;
    assign a_eq_b = (a == b) ? 1'b1 : 1'b0;
    assign a_lt_b = (a < b) ? 1'b1 : 1'b0;

endmodule
