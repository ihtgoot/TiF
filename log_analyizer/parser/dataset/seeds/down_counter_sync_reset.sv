// Same behavior family as counter.sv, but: synchronous reset,
// down-only, saturating at zero, reg/wire style
module down_counter_sync_reset #(
    parameter WIDTH = 8
)(
    input  wire               clk,
    input  wire               rst,       // synchronous, active-high
    input  wire               dec_en,
    input  wire  [WIDTH-1:0]  load_val,
    input  wire               load,
    output reg   [WIDTH-1:0]  value
);

    always @(posedge clk) begin
        if (rst) begin
            value <= {WIDTH{1'b0}};
        end else if (load) begin
            value <= load_val;
        end else if (dec_en) begin
            if (value != {WIDTH{1'b0}}) begin
                value <= value - 1'b1;
            end
        end
    end

endmodule
