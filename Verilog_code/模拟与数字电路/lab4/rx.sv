`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/17 18:05:29
// Design Name: 
// Module Name: rx
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


module rx(
    input rxd,rdy_rx,clk,rstn,
    output reg [7:0] d_rx,
    output reg vld_rx
    );
    reg rxd_t;
    reg [7:0] SIR;//移位寄存器
    reg [3:0] bit_count;   //剩余接受数据的位数
    reg [2:0] st_count;
    reg [3:0] clk_count;

    // TFD1  TFD1_inst (
    //   .k(10415),
    //   .clk(clk),
    //   .tclk(tclk)
    // );

    always@(posedge clk)begin
        rxd_t<=rxd;
    end

    //检查是否为起始位
    counter # (
      .WIDTH(3),
      .RST_VLU(7)
    )
    start_counter (
      .clk(clk),
      .rstn(rstn),
      .pe(((~|st_count)&&vld_rx)||(rxd_t&&~rxd&&st_count)),   //空闲状态下信号突变或数据传输完毕时置数，回归空闲状态
      .ce(st_count&&~rxd),//如果一直保持低位且不为0,为0后不会继续数
      .din(7),
      .q(st_count)
    );


    //每隔16个接受时钟对rxd检测一次
    counter # (             
    .WIDTH(4),
    .RST_VLU(0)
    )
    clk_counter (              
      .clk(clk),
      .rstn(rstn),
      .pe(~|st_count&&~|clk_count),//当传输数据且时钟计数器为0时(因为可能中间在校验时还要继续统计)置数
      .ce((~|st_count&&bit_count>1)||(bit_count==1&&|clk_count)),
      .din(15),
      .q(clk_count)
    );
    
    //剩余输入数据位数
    counter # (
      .WIDTH(4),
      .RST_VLU(0)
    )
    bit_counter (
      .clk(clk),
      .rstn(rstn),
      .pe(~|st_count&&~|bit_count),
      .ce(~|clk_count&&|bit_count),//处于数据传输状态，每过16个时钟周期减一
      .din(8),
      .q(bit_count)
    );

    //vld_rx的赋值
    always@(posedge clk)begin//接收数据
        if(!rstn)//开始计数
        begin
          vld_rx<=0;
        end
        else begin
          if(~|clk_count&&bit_count==1)begin
            vld_rx<=1;
          end
          else begin
            if(vld_rx&&~|st_count)begin
              vld_rx<=0;
            end
          end 
        end
    end

    //d_rx的赋值
    always@(*)begin
      d_rx=SIR[7:0];
    end  
    
    //SIR的赋值
    always@(posedge clk)begin
      if(!rstn)begin
        SIR=8'hff;
      end
      else begin
        if(~|st_count)begin     //不会记录到开始位,包含结束位1(最高位)
          if(clk_count==0)begin//每过16个时钟周期右移一位
            SIR<={rxd,SIR[7:1]}; 
          end
        end
      end
    end
endmodule
