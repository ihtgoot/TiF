// Mirror of shift_register.sv: parallel-in, serial-out (opposite direction),
// reg/wire Verilog-2001 style
module piso_register #(
    parameter WIDTH = 8
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire              load,
    input  wire  [WIDTH-1:0] parallel_in,
    input  wire              shift_en,
    output wire              serial_out
);

    reg [WIDTH-1:0] shift_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_data <= {WIDTH{1'b0}};
        end else if (load) begin
            shift_data <= parallel_in;
        end else if (shift_en) begin
            shift_data <= {shift_data[WIDTH-2:0], 1'b0};
        end
    end

    assign serial_out = shift_data[WIDTH-1];

endmodule
