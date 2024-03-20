`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/17 17:41:49
// Design Name: 
// Module Name: tx
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


module tx(
    input vld_tx,
    input [7:0] d_tx,
    input clk,
    input rstn,
    output reg rdy_tx,
    output reg txd
    );
    reg [9:0] sor;
    wire [3:0] counter_out;
    wire pe=vld_tx&&rdy_tx;
  
    counter # (
    .WIDTH(4),
    .RST_VLU(0)
    )
    counter_inst (
      .clk(clk),
      .rstn(rstn),
      .pe(pe),
      .ce(1),
      .din(9),
      .q(counter_out)
    );
    
    //移位寄存器sor的更新
    always@(posedge clk)begin
        if(!rstn)begin
          txd<=1;//输出高电平表示空闲
          sor<=10'h3ff;
          rdy_tx<=1;
        end
        else begin
          if(pe)begin//开始传输一个字节
            sor<={1'b1,d_tx,1'b0};
            rdy_tx<=0;//当数据准备好且接收方准备好接受数据时，马上传输数据，并且将接收方准备好接收数据的标志置为0，直到当前数据传输完毕之后再重新置为1
          end
          else begin
            case(counter_out)
              0:begin
                txd<=1;
                rdy_tx<=1;
              end 
              default: begin
                txd<=sor[0];
                sor<={1'b1,sor[9:1]};//右移
              end
            endcase 
          end
        end
    end
endmodule
