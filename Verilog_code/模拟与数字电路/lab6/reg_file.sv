`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/16 10:40:39
// Design Name: 
// Module Name: reg_file
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


module  reg_file # (
    parameter ADDR_WIDTH  = 5,	                            //地址宽度
    parameter DATA_WIDTH  = 32	                            //数据宽度
)(                                                          
    input  clk,			                                    //时钟
    input [ADDR_WIDTH -1:0]  rf_raddr1, rf_raddr2, rf_dbg_raddr,  //读地址
    input [ADDR_WIDTH -1:0]  rf_rd, 	                    //写地址
    input [DATA_WIDTH -1:0]  rf_wdata,	                    //写数据
    input  rf_we,			                                //写使能  
    output [DATA_WIDTH -1:0] rf_rdata1, rf_rdata2,rf_dbg_rdata//读数据
);
    reg [DATA_WIDTH -1:0]  rf [0: (1<<ADDR_WIDTH) - 1];     //寄存器堆

    assign rf_rdata1 = rf[rf_raddr1];	                    //读操作
    assign rf_rdata2 = rf[rf_raddr2];
    assign rf_dbg_rdata = rf[rf_dbg_raddr];
    initial begin                                           //寄存器堆初始化
        rf[0]   = 32'h0;
        rf[1]   = 32'h0;
        rf[2]   = 32'h0;
        rf[3]   = 32'h0;
        rf[4]   = 32'h0;
        rf[5]   = 32'h0;
        rf[6]   = 32'h0;
        rf[7]   = 32'h0;
        rf[8]   = 32'h0;
        rf[9]   = 32'h0;
        rf[10]  = 32'h0;
        rf[11]  = 32'h0;
        rf[12]  = 32'h0;
        rf[13]  = 32'h0;
        rf[14]  = 32'h0;
        rf[15]  = 32'h0;
        rf[16]  = 32'h0;
        rf[17]  = 32'h0;
        rf[18]  = 32'h0;
        rf[19]  = 32'h0;
        rf[20]  = 32'h0;
        rf[21]  = 32'h0;
        rf[22]  = 32'h0;
        rf[23]  = 32'h0;
        rf[24]  = 32'h0;
        rf[25]  = 32'h0;
        rf[26]  = 32'h0;
        rf[27]  = 32'h0;
        rf[28]  = 32'h0;
        rf[29]  = 32'h0;
        rf[30]  = 32'h0;
        rf[31]  = 32'h0;

    end
    always  @ (posedge  clk)begin
        if (rf_we)  begin
            rf[rf_rd] <= rf_wdata;	                        //写操作
        end
    end
endmodule
