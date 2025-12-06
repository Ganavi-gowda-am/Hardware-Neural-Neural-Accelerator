module mac_unit(
    input clk,
    input reset,
    input start,
    input signed [7:0] a,
    input signed [7:0] b,
    output reg done,
    output reg signed [31:0] result
);

    reg signed [31:0] mult_res;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 0;
            mult_res <= 0;
            done <= 0;
        end
        else begin
            if (start) begin
                mult_res <= a * b;
                result <= mult_res;
                done <= 1;
            end
            else begin
                done <= 0;
            end
        end
    end

endmodule

