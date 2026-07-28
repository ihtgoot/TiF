module axis_fifo #(
    parameter DATA_WIDTH  = 32,
    parameter DEPTH       = 32,
    parameter ADDR_W      = $clog2(DEPTH),
    parameter ALMOST_MARGIN = 4
)(
    input  logic                   clk,
    input  logic                   rst_n,

    input  logic                   s_axis_tvalid,
    output logic                   s_axis_tready,
    input  logic [DATA_WIDTH-1:0]  s_axis_tdata,
    input  logic                   s_axis_tlast,

    output logic                   m_axis_tvalid,
    input  logic                   m_axis_tready,
    output logic [DATA_WIDTH-1:0]  m_axis_tdata,
    output logic                   m_axis_tlast,

    output logic                   almost_full,
    output logic                   almost_empty
);

    typedef struct packed {
        logic [DATA_WIDTH-1:0] data;
        logic                  last;
    } entry_t;

    entry_t              mem [0:DEPTH-1];
    logic [ADDR_W-1:0]   wr_ptr, rd_ptr;
    logic [ADDR_W:0]     count;

    logic wr_fire, rd_fire;

    assign wr_fire       = s_axis_tvalid && s_axis_tready;
    assign rd_fire       = m_axis_tvalid && m_axis_tready;
    assign s_axis_tready = (count < DEPTH);
    assign m_axis_tvalid = (count > 0);

    assign m_axis_tdata  = mem[rd_ptr].data;
    assign m_axis_tlast  = mem[rd_ptr].last;

    assign almost_full   = (count >= DEPTH - ALMOST_MARGIN);
    assign almost_empty  = (count <= ALMOST_MARGIN);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
        end else begin
            if (wr_fire) begin
                mem[wr_ptr].data <= s_axis_tdata;
                mem[wr_ptr].last <= s_axis_tlast;
                wr_ptr           <= wr_ptr + 1'b1;
            end

            if (rd_fire) begin
                rd_ptr <= rd_ptr + 1'b1;
            end

            unique case ({wr_fire, rd_fire})
                2'b10:   count <= count + 1'b1;
                2'b01:   count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

endmodule
