module priority_encoder #(
    parameter WIDTH   = 16,
    parameter OUT_W   = $clog2(WIDTH)
)(
    input  logic [WIDTH-1:0]  data_in,
    output logic [OUT_W-1:0]  index,
    output logic              valid
);

    always_comb begin
        index = '0;
        valid = 1'b0;
        for (int i = WIDTH - 1; i >= 0; i--) begin
            if (data_in[i] && !valid) begin
                index = i[OUT_W-1:0];
                valid = 1'b1;
            end
        end
    end

endmodule
