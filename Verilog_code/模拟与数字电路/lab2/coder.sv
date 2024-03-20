`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/19 16:04:44
// Design Name: 
// Module Name: coder
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


module coder(
    input y2,y1,y0,
    input [63:0] x,
    output reg [63:0] cout
    );
    wire [2:0] y={y2,y1,y0};
    always @(*)begin
        if(y==3'b011)begin//2x
            cout = {x[62:0], 1'b0};
        end
        else if(y==3'b100)begin//-2x
            cout = -{x[62:0], 1'b0};
        end     
        else if((y==3'b001)|(y==3'b010))begin//x
            cout=x;
        end
        else if((y==3'b101)|(y==3'b110))begin//-x
            cout=-x;
        end
        else begin//0
            cout=0;
        end
    end
endmodule
