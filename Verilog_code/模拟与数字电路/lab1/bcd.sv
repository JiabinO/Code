`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/30 12:19:26
// Design Name: 
// Module Name: bcd
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


module bcd(
    input [3:0] din,//输入的4位2进制代码
    output reg [9:0] dout//输出的10位2进制代码
);
    always@(*) begin
        case(din)
            4'b0000: dout = 10'b0000000001;
            4'b0001: dout = 10'b0000000010;
            4'b0010: dout = 10'b0000000100;
            4'b0011: dout = 10'b0000001000;
            4'b0100: dout = 10'b0000010000;
            4'b0101: dout = 10'b0000100000;
            4'b0110: dout = 10'b0001000000;
            4'b0111: dout = 10'b0010000000;
            4'b1000: dout = 10'b0100000000;
            4'b1001: dout = 10'b1000000000;
            default: dout = 10'b0000000000;
        endcase
    end
endmodule
