// Same complexity class as edge_detector.sv, but a debounce filter using
// a saturating counter instead of a single-cycle previous-value register
module debounce #(
    parameter integer COUNT_MAX = 50000
)(
    input  logic clk,
    input  logic rst_n,
    input  logic noisy_in,
    output logic clean_out
);

    localparam CNT_W = $clog2(COUNT_MAX + 1);

    logic [CNT_W-1:0] count;
    logic             noisy_sync;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            noisy_sync <= 1'b0;
            count      <= '0;
            clean_out  <= 1'b0;
        end else begin
            noisy_sync <= noisy_in;

            if (noisy_sync == clean_out) begin
                count <= '0;
            end else if (count < COUNT_MAX[CNT_W-1:0]) begin
                count <= count + 1'b1;
            end else begin
                clean_out <= noisy_sync;
                count     <= '0;
            end
        end
    end

endmodule
