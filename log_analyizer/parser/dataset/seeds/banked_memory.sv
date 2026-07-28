// Same complexity class as register_file.sv, but reset via generate/genvar
// loop instead of a for-loop inside always_ff, and 1 write / 1 read port
module banked_memory #(
    parameter WIDTH    = 32,
    parameter NUM_REGS = 8
)(
    input  logic                              clk,
    input  logic                              rst_n,
    input  logic                              wr_en,
    input  logic [$clog2(NUM_REGS)-1:0]       wr_addr,
    input  logic [WIDTH-1:0]                  wr_data,
    input  logic [$clog2(NUM_REGS)-1:0]       rd_addr,
    output logic [WIDTH-1:0]                  rd_data
);

    logic [WIDTH-1:0] bank [0:NUM_REGS-1];

    genvar g;
    generate
        for (g = 0; g < NUM_REGS; g = g + 1) begin : reg_bank
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    bank[g] <= '0;
                end else if (wr_en && (wr_addr == g)) begin
                    bank[g] <= wr_data;
                end
            end
        end
    endgenerate

    assign rd_data = bank[rd_addr];

endmodule
