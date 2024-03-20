`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/20 20:12:17
// Design Name: 
// Module Name: puts_tb
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


module puts_tb(

    );
    reg [31:0] din;
    reg we,rdy_tx,clk,rstn;
    wire [7:0] d_tx;
    wire vld_tx;
    puts  puts_inst (
        .din(din),
        .we(we),
        .rdy_tx(rdy_tx),
        .clk(clk),
        .d_tx(d_tx),
        .vld_tx(vld_tx),
        .rstn(rstn)
    );
    initial begin
        clk=0;
        forever begin
            #1 clk=~clk;
        end
    end
    initial begin
        rstn=0;
        we = 1;
        din = 32'habcdef32;
        rdy_tx=1;
        #20 rstn=1;
        repeat(10)begin
            #20 rdy_tx=0;
            #400 rdy_tx=1; 
        end
        #400 din = 32'h0;
    end

endmodule
