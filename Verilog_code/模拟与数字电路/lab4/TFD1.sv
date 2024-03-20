`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/21 13:09:45
// Design Name: 
// Module Name: TFD1
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


module TFD1(
    input [31:0] k,
    input clk,
    output reg tclk
    );
    reg [31:0] counter;
    initial begin
        tclk = 0;
        counter = 0;
    end
    always@(posedge clk)begin
        if(counter==0)begin
            tclk<=~tclk;
            counter<=k;
        end
        else begin
            counter<=counter-1;
        end
    end
endmodule
