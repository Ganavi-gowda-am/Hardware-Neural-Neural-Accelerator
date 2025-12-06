`timescale 1ns/1ps

module nn_uart_top(
    input  clk,
    input  reset,
    input  start_inference,

    // 8 scalar input features
    input signed [7:0] in0,
    input signed [7:0] in1,
    input signed [7:0] in2,
    input signed [7:0] in3,
    input signed [7:0] in4,
    input signed [7:0] in5,
    input signed [7:0] in6,
    input signed [7:0] in7,

    output tx_serial
);

    // -------------------------
    // Weight Memories
    // -------------------------
    wire signed [7:0] w1_out;
    wire signed [7:0] w2_out;
    wire [7:0] addr_w1, addr_w2;

    weight_memory #(.FILE("W1.hex")) w1_mem (
        .clk(clk),
        .addr(addr_w1),
        .data(w1_out)
    );

    weight_memory #(.FILE("W2.hex")) w2_mem (
        .clk(clk),
        .addr(addr_w2),
        .data(w2_out)
    );

    // -------------------------
    // Layer Computation Core
    // -------------------------
    wire layer1_done;
    wire signed [7:0] layer1_out0, layer1_out1, layer1_out2, layer1_out3;
    wire signed [7:0] layer1_out4, layer1_out5, layer1_out6, layer1_out7;

    wire tx_dv;
    wire [7:0] tx_byte;
    wire tx_busy;

    nn3_core core_inst (
        .clk(clk),
        .reset(reset),
        .start_inference(start_inference),

        .in0(in0), .in1(in1), .in2(in2), .in3(in3),
        .in4(in4), .in5(in5), .in6(in6), .in7(in7),

        .layer1_done(layer1_done),
        .layer1_out0(layer1_out0), .layer1_out1(layer1_out1),
        .layer1_out2(layer1_out2), .layer1_out3(layer1_out3),
        .layer1_out4(layer1_out4), .layer1_out5(layer1_out5),
        .layer1_out6(layer1_out6), .layer1_out7(layer1_out7),

        .tx_dv(tx_dv),
        .tx_byte(tx_byte),
        .tx_busy(tx_busy)
    );

    // -------------------------
    // UART Transmit Interface
    // -------------------------
    uart_tx #(.CLKS_PER_BIT(868)) uart_inst (     // 115200 baud @ 100 MHz
        .i_Clock(clk),
        .i_Tx_DV(tx_dv),
        .i_Tx_Byte(tx_byte),
        .o_Tx_Active(tx_busy),
        .o_Tx_Serial(tx_serial),
        .o_Tx_Done()
    );

endmodule

