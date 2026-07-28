module crc8_calculator #(
    parameter POLY = 8'hD5
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       data_valid,
    input  logic [7:0] data_in,
    input  logic       crc_reset,
    output logic [7:0] crc_out
);

    logic [7:0] crc_reg;

    function automatic [7:0] crc8_next(input [7:0] crc, input [7:0] data);
        logic [7:0] result;
        logic       feedback;
        begin
            result = crc ^ data;
            for (int i = 0; i < 8; i++) begin
                feedback = result[7];
                result   = result << 1;
                if (feedback) begin
                    result = result ^ POLY;
                end
            end
            crc8_next = result;
        end
    endfunction

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_reg <= 8'hFF;
        end else if (crc_reset) begin
            crc_reg <= 8'hFF;
        end else if (data_valid) begin
            crc_reg <= crc8_next(crc_reg, data_in);
        end
    end

    assign crc_out = crc_reg;

endmodule
