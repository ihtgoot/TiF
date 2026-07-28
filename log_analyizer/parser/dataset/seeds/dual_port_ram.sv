module dual_port_ram #(
    parameter WIDTH = 16,
    parameter DEPTH = 256,
    parameter ADDR_W = $clog2(DEPTH)
)(
    input  logic              clk,

    input  logic               a_we,
    input  logic [ADDR_W-1:0]  a_addr,
    input  logic [WIDTH-1:0]   a_wdata,
    output logic [WIDTH-1:0]   a_rdata,

    input  logic               b_we,
    input  logic [ADDR_W-1:0]  b_addr,
    input  logic [WIDTH-1:0]   b_wdata,
    output logic [WIDTH-1:0]   b_rdata
);

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (a_we) begin
            mem[a_addr] <= a_wdata;
        end
        a_rdata <= mem[a_addr];
    end

    always_ff @(posedge clk) begin
        if (b_we) begin
            mem[b_addr] <= b_wdata;
        end
        b_rdata <= mem[b_addr];
    end

endmodule
