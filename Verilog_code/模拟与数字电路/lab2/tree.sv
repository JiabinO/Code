`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/24 15:49:00
// Design Name: 
// Module Name: tree
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


module tree(
    input [63:0] a,b,cin,
    output reg [63:0] cout, s
    );
    always @(*)begin
        s= a^b^cin;
        cout=((a&b)|(b&cin)|(a&cin))<<1;
    end
endmodule
