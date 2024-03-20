`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/22 22:16:21
// Design Name: 
// Module Name: SOR
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


module SOR(
    input clk, rstn     ,  
    input [7:0] d_tx    ,//8 bits数据
    input start         ,
    input [3:0] cnt     ,

    output reg txd
    );

    reg [7:0] din_reg ;//10bits output



    //din_reg
    always @(posedge clk, negedge rstn) begin
        if(!rstn) begin
            din_reg <= 8'hff;
        end
        else if(start) begin
            din_reg <= d_tx;
        end
        else if(cnt > 4'd0) begin
            din_reg[7:0] <= {1'b1,din_reg[7:1]}; //右移拼接 
        end
        else if(cnt == 4'd0) begin
            din_reg <= 8'hff;
        end
    end
    //txd
    always @(posedge clk, negedge rstn) begin
        if(!rstn) begin
            txd <= 1'b1;
        end
        else if(start == 1'b1)begin
            txd <= 1'b0; //Start bit
        end
        else if(cnt > 4'd0) begin
            txd <= din_reg[0];
        end
        else if(cnt == 4'd0) begin
            txd <= 1'b1; //Stop bit
        end
    end
endmodule
