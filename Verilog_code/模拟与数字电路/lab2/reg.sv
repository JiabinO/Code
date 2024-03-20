`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/17 18:06:26
// Design Name: 
// Module Name: reg
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


module  register
#( parameter WIDTH = 32,
             RST_VAL = 0
)(
    input  clk, rst, en,
    input  [WIDTH-1:0]  d,
    output reg  [WIDTH-1:0] q
);

    always @(posedge clk)
        if (rst) q <= RST_VAL;
        else  if (en) q <= d;

endmodule

