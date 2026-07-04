module adder_subtractor #(
    parameter WIDTH = 8
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             sub,       // 0 = add, 1 = subtract
    output logic [WIDTH-1:0] result,
    output logic             carry_out,
    output logic             overflow
);

    logic [WIDTH-1:0] b_operand;
    logic [WIDTH:0]   sum_ext;

    assign b_operand = sub ? ~b : b;
    assign sum_ext   = {1'b0, a} + {1'b0, b_operand} + {{WIDTH{1'b0}}, sub};

    assign result    = sum_ext[WIDTH-1:0];
    assign carry_out = sum_ext[WIDTH];

    assign overflow  = (a[WIDTH-1] == b_operand[WIDTH-1]) &&
                        (result[WIDTH-1] != a[WIDTH-1]);

endmodule
