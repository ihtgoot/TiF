/* verilator lint_off UNUSEDSIGNAL */
module axi_lite_slave #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter NUM_REGS   = 8
)(
    input  logic                  clk,
    input  logic                  rst_n,

    input  logic [ADDR_WIDTH-1:0] awaddr,
    input  logic                  awvalid,
    output logic                  awready,

    input  logic [DATA_WIDTH-1:0] wdata,
    input  logic                  wvalid,
    output logic                  wready,

    output logic [1:0]            bresp,
    output logic                  bvalid,
    input  logic                  bready,

    input  logic [ADDR_WIDTH-1:0] araddr,
    input  logic                  arvalid,
    output logic                  arready,

    output logic [DATA_WIDTH-1:0] rdata,
    output logic [1:0]            rresp,
    output logic                  rvalid,
    input  logic                  rready
);

    localparam int REG_ADDR_W = $clog2(NUM_REGS);

    logic [DATA_WIDTH-1:0] regs [0:NUM_REGS-1];

    typedef enum logic [1:0] {W_IDLE, W_DATA, W_RESP} wstate_t;
    typedef enum logic [1:0] {R_IDLE, R_DATA}          rstate_t;

    wstate_t wstate;
    rstate_t rstate;

    logic [REG_ADDR_W-1:0] awaddr_reg;
    logic [REG_ADDR_W-1:0] araddr_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wstate     <= W_IDLE;
            awready    <= 1'b0;
            wready     <= 1'b0;
            bvalid     <= 1'b0;
            bresp      <= 2'b00;
            awaddr_reg <= '0;
        end else begin
            unique case (wstate)
                W_IDLE: begin
                    bvalid <= 1'b0;
                    if (awvalid) begin
                        awready    <= 1'b1;
                        awaddr_reg <= awaddr[REG_ADDR_W+1:2];
                        wstate     <= W_DATA;
                    end
                end

                W_DATA: begin
                    awready <= 1'b0;
                    if (wvalid) begin
                        wready        <= 1'b1;
                        regs[awaddr_reg] <= wdata;
                        bresp         <= 2'b00;
                        bvalid        <= 1'b1;
                        wstate        <= W_RESP;
                    end
                end

                W_RESP: begin
                    wready <= 1'b0;
                    if (bready) begin
                        bvalid <= 1'b0;
                        wstate <= W_IDLE;
                    end
                end

                default: wstate <= W_IDLE;
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rstate     <= R_IDLE;
            arready    <= 1'b0;
            rvalid     <= 1'b0;
            rresp      <= 2'b00;
            rdata      <= '0;
            araddr_reg <= '0;
        end else begin
            unique case (rstate)
                R_IDLE: begin
                    if (arvalid) begin
                        arready    <= 1'b1;
                        araddr_reg <= araddr[REG_ADDR_W+1:2];
                        rstate     <= R_DATA;
                    end
                end

                R_DATA: begin
                    arready <= 1'b0;
                    rdata   <= regs[araddr_reg];
                    rresp   <= 2'b00;
                    rvalid  <= 1'b1;
                    if (rready) begin
                        rvalid <= 1'b0;
                        rstate <= R_IDLE;
                    end
                end

                default: rstate <= R_IDLE;
            endcase
        end
    end

endmodule
