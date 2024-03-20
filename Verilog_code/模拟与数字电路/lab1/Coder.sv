`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/30 12:17:11
// Design Name: 
// Module Name: Coder
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


module Coder(
    input enable, seltype,
    input [9:0] din1,
    input [3:0] din2,
    output reg flag,
    output reg [3:0] ledout,
    output reg [9:0] ecdout,
    output reg [6:0] ssdout,
    output wire dp,
    output wire [7:0] an
    );
    wire [3:0] dout1,dout2;
    wire selflag;
    mux MUX(
        .din1(dout1),
        .din2(din2),
        .sel(selflag),
        .dout(dout2)
    );
    ecd ECD(
        .a(din1),
        .enable(enable),
        .seltype(seltype),
        .flag(selflag),
        .dout(dout1)
    );
    bcd BCD(
        .din(dout2),
        .dout(ecdout)
    );
    ssd SSD(
        .din(dout2),
        .yn(ssdout)
    );
    assign dp = 1'b0, an = 8'b1111_1110;
    always@(*) begin
        flag = selflag;
        ledout = dout1;
    end
endmodule
