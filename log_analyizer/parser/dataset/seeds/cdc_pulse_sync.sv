module cdc_pulse_sync (
    input  logic src_clk,
    input  logic src_rst_n,
    input  logic pulse_in,

    input  logic dst_clk,
    input  logic dst_rst_n,
    output logic pulse_out
);

    logic toggle_src;
    logic sync_ff1, sync_ff2, sync_ff3;

    always_ff @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) begin
            toggle_src <= 1'b0;
        end else if (pulse_in) begin
            toggle_src <= ~toggle_src;
        end
    end

    always_ff @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
            sync_ff3 <= 1'b0;
        end else begin
            sync_ff1 <= toggle_src;
            sync_ff2 <= sync_ff1;
            sync_ff3 <= sync_ff2;
        end
    end

    assign pulse_out = sync_ff2 ^ sync_ff3;

endmodule
