module round_robin_arbiter #(
    parameter NUM_REQ = 4
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [NUM_REQ-1:0]    req,
    output logic [NUM_REQ-1:0]    grant,
    output logic                  valid
);

    logic [$clog2(NUM_REQ)-1:0] last_grant;
    logic [NUM_REQ-1:0]         grant_comb;

    always_comb begin
        automatic logic [$clog2(NUM_REQ)-1:0] idx;
        grant_comb = '0;
        valid      = 1'b0;

        for (int offset = 1; offset <= NUM_REQ; offset++) begin
            /* verilator lint_off WIDTHTRUNC */
            idx = (last_grant + offset[$clog2(NUM_REQ)-1:0]) % NUM_REQ;
            /* verilator lint_on WIDTHTRUNC */
            if (!valid && req[idx]) begin
                grant_comb[idx] = 1'b1;
                valid           = 1'b1;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            last_grant <= '0;
            grant      <= '0;
        end else begin
            grant <= grant_comb;
            if (valid) begin
                for (int idx = 0; idx < NUM_REQ; idx++) begin
                    if (grant_comb[idx]) begin
                        last_grant <= idx[$clog2(NUM_REQ)-1:0];
                    end
                end
            end
        end
    end

endmodule
