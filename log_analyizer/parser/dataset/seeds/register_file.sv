module register_file #(
    parameter WIDTH    = 32,
    parameter NUM_REGS = 16,
    parameter ADDR_W   = $clog2(NUM_REGS)
)(
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic                 wr_en,
    input  logic [ADDR_W-1:0]    wr_addr,
    input  logic [WIDTH-1:0]     wr_data,
    input  logic [ADDR_W-1:0]    rd_addr0,
    input  logic [ADDR_W-1:0]    rd_addr1,
    output logic [WIDTH-1:0]     rd_data0,
    output logic [WIDTH-1:0]     rd_data1
);

    logic [WIDTH-1:0] regs [0:NUM_REGS-1];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < NUM_REGS; i++) begin
                regs[i] <= '0;
            end
        end else if (wr_en) begin
            regs[wr_addr] <= wr_data;
        end
    end

    assign rd_data0 = regs[rd_addr0];
    assign rd_data1 = regs[rd_addr1];

endmodule
