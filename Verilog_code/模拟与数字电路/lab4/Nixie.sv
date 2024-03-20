`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/14 19:15:48
// Design Name: 
// Module Name: DIS
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


module DIS(
        input [3:0] d0,d1,d2,d3,
        input clk,rst,st,
        output an0,an1,an2,an3,
        output [6:0] cn
    );
    reg rst_reg1,rst_reg2;
    wire [1:0] mux;
    reg [1:0] mux_reg;
    reg pe;
    reg yl,yp;
    wire [3:0] dout;
    always@(posedge clk)begin
      rst_reg1<=rst;
      rst_reg2<=rst_reg1;
      mux_reg<=mux;
    end
    always @(*) begin
        pe = (~(|mux))&&yp;
    end
    TFD # (
        .WIDTH(255)
    )
    TFD_inst (
      .k(255),
      .st(st),
      .rst(rst),
      .clk(clk),
      .yp(yp),
      .yl(yl)
    );
    
    counter # (
        .WIDTH(2),
        .RST_VLU(0)
    )
    counter_inst (
      .clk(yl),
      .rstn(!rst_reg2),
      .pe(yp&&(~(|mux_reg))),//
      .ce(1),
      .din(20),//设置计时器最大值为255
      .q(mux)
    );
    Decoder  Decoder_inst (//低电平有效
    .din(mux),
    .dout({an3,an2,an1,an0})
    );
    mux  mux_inst (
      .d0(d0),
      .d1(d1),
      .d2(d2),
      .d3(d3),
      .sel(mux),
      .dout(dout)
    );
    ssd  ssd_inst (
      .din(dout),
      .yn(cn)
    );
endmodule
