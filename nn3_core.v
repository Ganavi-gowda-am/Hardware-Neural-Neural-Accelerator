// nn3_core.v - USE THIS ROBUST ANSI-STYLE PORT DECLARATION

module nn3_core (
    // CLOCK & CONTROL INPUTS
    input clk,
    input reset,
    input start_inference,

    // DATA INPUTS (8 x 8-bit signed)
    input signed [7:0] in0, 
    input signed [7:0] in1, 
    input signed [7:0] in2, 
    input signed [7:0] in3,
    input signed [7:0] in4, 
    input signed [7:0] in5, 
    input signed [7:0] in6, 
    input signed [7:0] in7,

    // OUTPUTS - LAYER 1
    output layer1_done,
    output signed [7:0] layer1_out0, 
    output signed [7:0] layer1_out1, 
    output signed [7:0] layer1_out2, 
    output signed [7:0] layer1_out3,
    output signed [7:0] layer1_out4, 
    output signed [7:0] layer1_out5, 
    output signed [7:0] layer1_out6, 
    output signed [7:0] layer1_out7,

    // OUTPUTS - LAYER 2 <--- The crucial additions that must match the testbench
    output layer2_done,
    output signed [7:0] layer2_out0, 
    output signed [7:0] layer2_out1, 
    output signed [7:0] layer2_out2, 
    output signed [7:0] layer2_out3,
    output signed [7:0] layer2_out4, 
    output signed [7:0] layer2_out5, 
    output signed [7:0] layer2_out6, 
    output signed [7:0] layer2_out7,
    
    // OUTPUTS - LAYER 3
    output layer3_done,
    output signed [7:0] layer3_out0, 
    output signed [7:0] layer3_out1, 
    output signed [7:0] layer3_out2, 
    output signed [7:0] layer3_out3,
    output signed [7:0] layer3_out4, 
    output signed [7:0] layer3_out5, 
    output signed [7:0] layer3_out6, 
    output signed [7:0] layer3_out7,

    // UART OUTPUTS
    output tx_dv,
    output [7:0] tx_byte,
    output tx_busy
);
    // ... Internal logic of nn3_core (wires, regs, assignments, etc.) goes here ...
endmodule
