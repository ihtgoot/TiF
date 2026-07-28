// Verilog-2001 style: reg/wire, always @*, function-based, camelCase
module alu_functional #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] opA,
    input  wire [WIDTH-1:0] opB,
    input  wire [1:0]       opSel,
    output reg  [WIDTH-1:0] aluResult,
    output wire             zeroFlag
);

    function [WIDTH-1:0] computeAlu;
        input [WIDTH-1:0] x, y;
        input [1:0]       sel;
        begin
            case (sel)
                2'b00: computeAlu = x + y;
                2'b01: computeAlu = x - y;
                2'b10: computeAlu = x & y;
                2'b11: computeAlu = x | y;
            endcase
        end
    endfunction

    always @* begin
        aluResult = computeAlu(opA, opB, opSel);
    end

    assign zeroFlag = (aluResult == {WIDTH{1'b0}});

endmodule
