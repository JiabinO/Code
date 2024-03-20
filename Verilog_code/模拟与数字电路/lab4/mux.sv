`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/14 20:10:04
// Design Name: 
// Module Name: mux
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


module mux(
        input [3:0] d0,d1,d2,d3,
        input [1:0] sel,
        output reg [3:0] dout
    );
    always@(*)begin
        case(sel)
            2'b0:dout = d0;
            2'b1:dout = d1;
            2'b10:dout = d2;
            2'b11:dout = d3;
        endcase
    end 
endmodule
