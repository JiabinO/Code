`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/14 07:56:07
// Design Name: 
// Module Name: Counter
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


module  counter #(
    parameter WIDTH = 32, 
              RST_VLU = 0
)(
    input                   clk, rstn, 
    input                   pe, ce,
    input       [WIDTH-1:0] din,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (!rstn)      q <= RST_VLU;
        else if (pe)    q <= din;//置数使能时将din的值赋给计数器
        else if (ce)    q <= q - 1; 
    end
endmodule

