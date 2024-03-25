`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/24 18:32:39
// Design Name: 
// Module Name: rf
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
module  rf (
    input           clk,		//时钟
    input   [4:0]   ra0, ra1,	//读地址
    output  [31:0]  rd0, rd1,	//读数据
    input   [4:0]   wa,		    //写地址
    input   [31:0]  wd,	        //写数据
    input           we		    //写使能
);
    reg [31:0]  x[0:31]; 	    //寄存器堆

    assign rd0 = we & wa == ra0 & ra0 != 0 ? wd : ( ra0 == 0 ? 0 : x[ra0]); 	    //读操作,写优先 
    assign rd1 = we & wa == ra1 & ra1 != 0 ? wd : ( ra1 == 0 ? 0 : x[ra1]);

    always  @(posedge  clk)
        if (we)  begin
            if(wa == 0) begin
                x[wa] <= 0;
            end
            else begin
                x[wa] <= wd;   //写操作
            end
        end
        
endmodule


