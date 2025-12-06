module activation_relu(
    input  signed [31:0] din,
    output signed [31:0] dout
);
    assign dout = (din > 0) ? din : 0;
endmodule

