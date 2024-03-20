`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/30 15:20:09
// Design Name: 
// Module Name: c2h
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


module c2h(
    input [6:0] ascii_num,
    output reg [3:0] dout
    );
    always@(*)begin
        case(ascii_num)
        7'h30: dout = 4'h0;
        7'h31: dout = 4'h1;
        7'h32: dout = 4'h2;
        7'h33: dout = 4'h3;
        7'h34: dout = 4'h4;
        7'h35: dout = 4'h5;
        7'h36: dout = 4'h6;
        7'h37: dout = 4'h7;
        7'h38: dout = 4'h8;
        7'h39: dout = 4'h9;
        7'h61: dout = 4'ha;
        7'h62: dout = 4'hb;
        7'h63: dout = 4'hc;
        7'h64: dout = 4'hd;
        7'h65: dout = 4'he;
        7'h66: dout = 4'hf;
        default: dout = 4'h0;
        endcase
    end
endmodule
