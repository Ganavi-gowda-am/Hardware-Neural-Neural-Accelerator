// ===============================
// Generic Weight/Bias BRAM
// ===============================
module weight_bram #(
    parameter ADDR_WIDTH = 8,
    parameter INIT_FILE  = ""
)(
    input  clk,

    // Read interface (for MAC computation)
    input  [ADDR_WIDTH-1:0] addr,
    output reg signed [7:0] dout,

    // Write interface (for model loader UART)
    input  we,
    input  [ADDR_WIDTH-1:0] waddr,
    input  signed [7:0] din
);

    // Memory array
    reg signed [7:0] mem [(2**ADDR_WIDTH)-1:0];

    // Initial load from HEX file if provided
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    // Read port
    always @(posedge clk) begin
        dout <= mem[addr];
    end

    // Write port
    always @(posedge clk) begin
        if (we)
            mem[waddr] <= din;
    end

endmodule

