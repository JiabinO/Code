`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/06 16:39:25
// Design Name: 
// Module Name: TX
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


 module TX(
    input clk          ,  //f = 9600Hz
    input rstn         ,
    input [7:0] d_tx    ,  //八位输入
    input vld_tx       ,  //发送数据有效检验

    output reg rdy_tx  ,  //返回是否准备好
    output txd        //串行数据输出
    );


    wire [3:0] cnt ;//计数器输出
    wire sign ;//作为是否下一个时钟周期能否计数/跳变的标志


    assign sign = rdy_tx & vld_tx;
    

    //SOR
    SOR shift_right(
        .clk (clk),
        .rstn(rstn),
        .start(sign),
        .d_tx(d_tx),
        .cnt(cnt),
        .txd(txd)
    );

    //计数器
    CNT count(
        .clk (clk),
        .rstn(rstn),
        .pe  (sign),
        .din (4'd8),
        .q   (cnt)
    );


    //Ready Register
    always @(posedge clk, negedge rstn) begin
        if(!rstn) begin
            rdy_tx <= 1'b1;
        end
        else if(sign == 1'b1)begin
            rdy_tx <= 1'b0;
        end
        else if(cnt == 4'b0) begin
            rdy_tx <= 1'b1;
        end
    end
endmodule