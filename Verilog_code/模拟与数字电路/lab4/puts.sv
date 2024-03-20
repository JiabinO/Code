`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/17 16:46:53
// Design Name: 
// Module Name: puts
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


module puts(
    input [31:0] din,       //32位串口数据
    input we,               //串口数据写入使能
    input rdy_tx,           //接收方准备就绪信号
    input clk,
    input rstn,
    output reg [7:0] d_tx,  //发送的一个字节
    output reg vld_tx       //发送方数据准备就绪信号
    );
    reg [3:0] counter_reg;
    wire [6:0] ascii_num;
    reg [31:0] TxW;
    // wire tclk;//分频时钟
 
    // TFD1  TFD1_inst (
    // .k(10415),
    // .clk(clk),
    // .tclk(tclk)
    // );

    //ascii译码器
    h2c  h2c_inst (
      .din(TxW[31:28]),
      .ascii_num(ascii_num)
    );

    //时钟计数器，用于确定din的内容是否输出完毕，然后再输出换行和回车
    counter # (
        .WIDTH(4),
        .RST_VLU(10)
    )
    count (
      .clk  (clk),
      .rstn (rstn),
      .pe   (we && rdy_tx && counter_reg == 0),//tx空闲且put数据准备好开始接受数据
      .ce   (rdy_tx && vld_tx),//成功接收到上一个数的时候继续往下数   
      .din  (10),      
      .q    (counter_reg)
    );
  
    always@(posedge clk)begin
      if(!rstn)begin//重置
        TxW<=0;
      end
      else begin
        if(rdy_tx && vld_tx) begin
          TxW <= counter_reg == 0 && we ? din : TxW << 4;
        end
        else if(we && rdy_tx)begin//如果写入数据
          TxW <= din;
        end
      end 
    end

    always@(*) begin
      case(counter_reg)
      4'd2: d_tx = 8'h0d;
      4'd1: d_tx = 8'h0a;
      default: d_tx = {1'b0,ascii_num};
      endcase
    end

    always @(posedge clk) begin
      if(!rstn) begin
        vld_tx <= 0;
      end
      else if(counter_reg == 0) begin
        vld_tx <= 0;
      end
      else if(we) begin
        vld_tx <= 1;
      end
    end

endmodule

