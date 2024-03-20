`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/14 19:58:58
// Design Name: 
// Module Name: Decoder
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


module Decoder(
        input [1:0] din,
        output reg [3:0] dout
    );
    always@(*)begin
        case(din)
            2'd0:dout = 4'b1110;
            2'd1:dout = 4'b1101;
            2'd2:dout = 4'b1011;
            2'd3:dout = 4'b0111;
        endcase
    end
endmodule
