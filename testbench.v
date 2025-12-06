// testbench.v - Complete code for 3-Layer Tracing

`timescale 1ns/1ps
module testbench;

// --- 1. Stimulus and Input Registers ---
reg clk, reset, start_inference;
reg signed [7:0] in0, in1, in2, in3, in4, in5, in6, in7;

// --- 2. Output Wires (Layer 1) ---
wire layer1_done;
wire signed [7:0] layer1_out0, layer1_out1, layer1_out2, layer1_out3;
wire signed [7:0] layer1_out4, layer1_out5, layer1_out6, layer1_out7;

// --- 3. Output Wires (Layer 2) ---
wire layer2_done; 
wire signed [7:0] layer2_out0, layer2_out1, layer2_out2, layer2_out3;
wire signed [7:0] layer2_out4, layer2_out5, layer2_out6, layer2_out7;

// --- 4. Output Wires (Layer 3) ---
wire layer3_done; 
wire signed [7:0] layer3_out0, layer3_out1, layer3_out2, layer3_out3;
wire signed [7:0] layer3_out4, layer3_out5, layer3_out6, layer3_out7;

// --- 5. UART Wires ---
wire tx_dv;
wire [7:0] tx_byte;
wire tx_busy;

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// --- 6. Instantiate DUT (nn3_core) ---
nn3_core uut (
    .clk(clk),
    .reset(reset),
    .start_inference(start_inference),
    .in0(in0), .in1(in1), .in2(in2), .in3(in3),
    .in4(in4), .in5(in5), .in6(in6), .in7(in7),
    
    // Layer 1 connections
    .layer1_done(layer1_done),
    .layer1_out0(layer1_out0), .layer1_out1(layer1_out1),
    .layer1_out2(layer1_out2), .layer1_out3(layer1_out3),
    .layer1_out4(layer1_out4), .layer1_out5(layer1_out5),
    .layer1_out6(layer1_out6), .layer1_out7(layer1_out7),
    
    // Layer 2 connections
    .layer2_done(layer2_done),
    .layer2_out0(layer2_out0), .layer2_out1(layer2_out1),
    .layer2_out2(layer2_out2), .layer2_out3(layer2_out3),
    .layer2_out4(layer2_out4), .layer2_out5(layer2_out5),
    .layer2_out6(layer2_out6), .layer2_out7(layer2_out7),
    
    // Layer 3 connections
    .layer3_done(layer3_done),
    .layer3_out0(layer3_out0), .layer3_out1(layer3_out1),
    .layer3_out2(layer3_out2), .layer3_out3(layer3_out3),
    .layer3_out4(layer3_out4), .layer3_out5(layer3_out5),
    .layer3_out6(layer3_out6), .layer3_out7(layer3_out7),
    
    // UART connections
    .tx_dv(tx_dv),
    .tx_byte(tx_byte),
    .tx_busy(tx_busy)
);

// --- 7. Stimulus and VCD Dump ---
initial begin
    $dumpfile("outputs.vcd"); 

    // The comprehensive $dumpvars command
    $dumpvars(0, 
        uut.layer1_out0, uut.layer1_out1, uut.layer1_out2, uut.layer1_out3,
        uut.layer1_out4, uut.layer1_out5, uut.layer1_out6, uut.layer1_out7,
        uut.layer2_out0, uut.layer2_out1, uut.layer2_out2, uut.layer2_out3, 
        uut.layer2_out4, uut.layer2_out5, uut.layer2_out6, uut.layer2_out7, 
        uut.layer3_out0, uut.layer3_out1, uut.layer3_out2, uut.layer3_out3, 
        uut.layer3_out4, uut.layer3_out5, uut.layer3_out6, uut.layer3_out7, 
        uut.layer1_done, uut.layer2_done, uut.layer3_done 
    );
    
    // Initialize inputs
    reset = 1;
    start_inference = 0;

    in0 = 10; in1 = 20; in2 = 30; in3 = 40;
    in4 = 50; in5 = 60; in6 = 70; in7 = 80;

    #50 reset = 0;

    // Run multiple inference cycles
    repeat (10) begin
        start_inference = 1;
        #20 start_inference = 0;
        #200; // wait for completion
    end

    #2000;
    $stop;
end

endmodule
