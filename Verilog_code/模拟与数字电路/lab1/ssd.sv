`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/30 15:53:02
// Design Name: 
// Module Name: ssd
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


module ssd(
    input [3:0] din,//输入的4位2进制代码
    output reg [6:0] yn//输出七段数码管的亮暗状态
    );
    always@(*) begin
        case(din)
            4'b0000: yn = 7'b0000001;//0
            4'b0001: yn = 7'b1001111; //1
            4'b0010: yn = 7'b0010010;//2
            4'b0011: yn = 7'b0000110;//3
            4'b0100: yn = 7'b1001100;//4
            4'b0101: yn = 7'b0100100;//5
            4'b0110: yn = 7'b0100000;//6
            4'b0111: yn = 7'b0001111;//7
            4'b1000: yn = 7'b0000000;//8
            4'b1001: yn = 7'b0000100;//9
            4'b1010: yn = 7'b0001000;//A
            4'b1011: yn = 7'b1100000;//b
            4'b1100: yn = 7'b0110001;//C
            4'b1101: yn = 7'b1000010;//d
            4'b1110: yn = 7'b0110000;//E
            4'b1111: yn = 7'b0111000;//F
            default: yn = 7'b1111111;//void
        endcase
    end
endmodule
