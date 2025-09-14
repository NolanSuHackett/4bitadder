`timescale 1ns / 1ps

module adder4 (

    input logic clk,
    input logic [3:0] a,
    input logic [3:0] b,
    output logic [4:0] sum
);


always_ff @(negedge clk) begin
    
    sum <= a + b;

end

endmodule