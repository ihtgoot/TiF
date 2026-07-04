module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR_W = $clog2(DEPTH)
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             wr_en,
    input  logic [WIDTH-1:0] wr_data,
    input  logic             rd_en,
    output logic [WIDTH-1:0] rd_data,
    output logic             full,
    output logic             empty
);

    logic [WIDTH-1:0]  mem [0:DEPTH-1];
    logic [ADDR_W-1:0]  wr_ptr, rd_ptr;
    logic [ADDR_W:0]    count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr      <= wr_ptr + 1'b1;
            end

            if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1'b1;
            end

            case ({wr_en && !full, rd_en && !empty})
                2'b10:   count <= count + 1'b1;
                2'b01:   count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

    assign rd_data = mem[rd_ptr];
    assign full     = (count == DEPTH);
    assign empty    = (count == 0);

endmodule
