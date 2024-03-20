`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/14 08:38:33
// Design Name: 
// Module Name: TFD
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


module TFD#(parameter WIDTH = 32)(
    input [WIDTH-1:0] k,
    input st,rst,clk,
    output reg [WIDTH-1:0] q,
    output reg yp,yl,rstn
    );
    reg st_reg;
    reg pe;
    always @(*)begin
        pe=(st&&(~st_reg))||(st&&(~(|q)));//当计数完成且start信号仍为1时，重新置数
    end
    counter # (
    .WIDTH(WIDTH),
    .RST_VLU(0)
    )
    counter_inst (
      .clk(clk),
      .rstn(!rst),
      .pe(pe),
      .ce(|q),
      .din(k),      
      .q(q)
    );
    always@(posedge clk)begin
          st_reg<=st;
          if(rst)begin//复位后清零
              yp<=0;
              yl<=0;
              rstn<=0;
          end
          else begin
              rstn<=1;
              if(st)begin//当st变高时，重复进行计数，并适时输出脉冲和方波
                  if(!(|q))begin//重复计数过程
                      yp<=1;
                      yl<=1;
                  end
                  else begin
                      yp<=0;
                      if(q<=(k+1)/2)begin
                          yl<=0;
                      end
                  end
              end
              else begin//st变低，停止计数和输出
                  yp<=0;
                  yl<=0;
              end   
          end
    end
endmodule
