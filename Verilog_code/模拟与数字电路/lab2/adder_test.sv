`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/24 17:05:01
// Design Name: 
// Module Name: adder_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adder_test(
    input [31:0] a,b,
    output [31:0] y
    );
    reg [11:0] f=12'b000000000001;
    ALU addertest(
        .a(a),
        .b(b),
        .f(f),
        .y(y)
    );
endmodule
