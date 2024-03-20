`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/12 12:11:40
// Design Name: 
// Module Name: NewFD
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

module NewFD (
    input [31:0]k,      //分频常数，fclk = (k+1) * fy 
    input clk, rstn,

    output reg yl  //方波

    );

    reg [12:0] q;

    always @(posedge clk) begin
        if(!rstn) begin
            q <= 0;
        end
        else if(q == 0) begin
            q <= 13'd5208;
        end
        else begin
            q <= q - 13'd1;
        end
    end


    always @(posedge clk)begin
        if( !rstn )begin
            yl <= 1'b0;
        end
        else begin
            if(q == 13'd5208) begin
                yl <= ~yl;
            end
        end
    end
endmodule

