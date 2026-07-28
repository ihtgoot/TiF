// Same complexity class as fifo.sv but LIFO ordering, single pointer
module lifo_stack #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             push,
    input  logic [WIDTH-1:0] push_data,
    input  logic             pop,
    output logic [WIDTH-1:0] pop_data,
    output logic             full,
    output logic             empty
);

    localparam PTR_W = $clog2(DEPTH);

    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_W-1:0] top;    // index of next free slot
    logic [PTR_W:0]   count;  // number of elements currently stored

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            top   <= '0;
            count <= '0;
        end else begin
            if (push && !full) begin
                mem[top] <= push_data;
                top      <= top + 1'b1;
                count    <= count + 1'b1;
            end else if (pop && !empty) begin
                top   <= top - 1'b1;
                count <= count - 1'b1;
            end
        end
    end

    assign pop_data = mem[top - 1'b1];
    assign full     = (count == DEPTH);
    assign empty    = (count == 0);

endmodule
