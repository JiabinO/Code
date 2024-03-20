`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/14 07:55:47
// Design Name: 
// Module Name: Timer
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


module Timer#(
    parameter WIDTH = 32 ,
              RST_VLU = 0)
    (
        input [WIDTH-1:0] k,//定时常数,定时时长为t=(k+1)*T_clk
        input st,rstn,clk,//启动信号;复位信号;时钟信号
        output reg td,//定时结束标志
        output reg [WIDTH-1:0] q//计数器输出
    );
    reg ce;
    reg st_reg;
    counter # (
    .WIDTH(WIDTH),
    .RST_VLU(RST_VLU)
    )
    counter_inst (
      .clk(clk),
      .rstn(rstn),
      .pe(st&&(~st_reg)),//上升沿置数
      .ce(ce),
      .din(k),
      .q(q)
    );
    always@(posedge clk)begin
        st_reg<=st;
    end
    
    always @(*)begin
        ce = q==0 ? 0 : 1;
        td = q==0 ? 1 : 0;
    end
endmodule
