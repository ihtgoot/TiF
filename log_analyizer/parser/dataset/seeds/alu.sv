module alu #(
    parameter WIDTH = 4
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [1:0]       op,
    output logic [WIDTH-1:0] result,
    output logic             zero
);

    always_comb begin
        unique case (op)
            2'b00: result = a + b;
            2'b01: result = a - b;
            2'b10: result = a & b;
            2'b11: result = a | b;
            default: result = '0;
        endcase
    end

    assign zero = (result == '0);

endmodule
