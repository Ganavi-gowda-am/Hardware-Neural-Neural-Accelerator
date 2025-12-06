//===========================
// Weight Memory ROM
//===========================
`timescale 1ns/1ps

module weight_memory #(
    parameter FILE = "weights.hex",
    parameter DEPTH = 256      
)(
    input clk,
    input [7:0] addr,
    output reg signed [7:0] data
);

    reg signed [7:0] mem [0:DEPTH-1];

    // load weights at simulation start from hex file
    initial begin
        $display("Loading weights from %s ...", FILE);
        $readmemh(FILE, mem);
    end

    // synchronous read
    always @(posedge clk) begin
        data <= mem[addr];
    end

endmodule

