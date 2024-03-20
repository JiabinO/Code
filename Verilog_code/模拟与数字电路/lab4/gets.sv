`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/20 17:23:55
// Design Name: 
// Module Name: gets
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


module gets(
    input [7:0] d_rx,//高七位为ascii码
    input vld_rx,clk,rstn,
    output reg rdy_rx,
    output reg [31:0] dout
    );
    reg [31:0] RxW;
    wire [3:0] hex_out;
    reg [2:0] counter_reg;

    c2h  c2h_inst (
        .ascii_num(d_rx[6:0]),
        .dout(hex_out)
      );

    //rdy_rx的赋值
    assign rdy_rx=1;
    
    counter # (
      .WIDTH(3),
      .RST_VLU(0)
    )
    counter_inst (
      .clk(clk),
      .rstn(rstn),
      .pe(vld_rx&&~|counter_reg),
      .ce(vld_rx&&|counter_reg),
      .din(7),
      .q(counter_reg)
    );

    //RxW的赋值,每次接受一个ascii右移四位
    always@(posedge clk)begin
        if(!rstn)begin
            RxW<=32'h0;
        end
        else begin
            if(vld_rx)begin
              RxW<={RxW[27:0],hex_out};
            end
        end
    end

    //dout的赋值
    always@(posedge clk) begin
      if(!rstn)begin
        dout<=32'h0;
      end
      else begin
        if(~|counter_reg)begin
          dout<=RxW;
        end
      end
    end    
endmodule
