`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/05 20:59:11
// Design Name: 
// Module Name: register_file
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


module  register_file # (
    parameter ADDR_WIDTH  = 5,              //地址宽度
    parameter DATA_WIDTH  = 32              //数据宽度
)(
    input                       clk,        //时钟
    input   [ADDR_WIDTH -1:0]   ra0, ra1,   //读地址
    output  [DATA_WIDTH -1:0]   rd0, rd1,   //读数据
    input   [ADDR_WIDTH -1:0]   wa,         //写地址
    input   [DATA_WIDTH -1:0]   wd,         //写数据
    input                       we          //写使能
);
    reg [DATA_WIDTH -1:0]  rf [0:(1<<ADDR_WIDTH)-1];    //寄存器堆
    initial begin                                           //寄存器堆初始化
        rf[0]   = 32'hf4ffff0f;
        rf[1]   = 32'hf4fffffe;
        rf[2]   = 32'hf4ffffed;
        rf[3]   = 32'hf4f6fedc;
        rf[4]   = 32'hf4f6fdcb;
        rf[5]   = 32'hf4f6fcba;
        rf[6]   = 32'hf4f6fba9;
        rf[7]   = 32'hf4f6fa98;
        rf[8]   = 32'hf4f6f987;
        rf[9]   = 32'hf4f6f876;
        rf[10]  = 32'hf4f6f765;
        rf[11]  = 32'hf4f6f654;
        rf[12]  = 32'hf4f6f543;
        rf[13]  = 32'hf4f6f432;
        rf[14]  = 32'hf4f69321;
        rf[15]  = 32'h34f69210;
        rf[16]  = 32'h3ff6910f;
        rf[17]  = 32'h3ff690fe;
        rf[18]  = 32'h3ff69fed;
        rf[19]  = 32'h3fff9fdc;
        rf[20]  = 32'h3fff9fcb;
        rf[21]  = 32'h3fff9fba;
        rf[22]  = 32'h3fff9fa9;
        rf[23]  = 32'h3fff9f98;
        rf[24]  = 32'h3fff9f87;
        rf[25]  = 32'h3fff9f76;
        rf[26]  = 32'h3fff9f65;
        rf[27]  = 32'h3fff9f54;
        rf[28]  = 32'h3fff9f43;
        rf[29]  = 32'h3fff9f32;
        rf[30]  = 32'h3fffff21;
        rf[31]  = 32'hffffff10;
    end
    //读操作：读优先，异步读
    assign rd0 = rf[ra0];   
    assign rd1 = rf[ra1];
    //写操作：同步写
    always@ (posedge clk) begin
        if (we)  rf[wa] <= wd;  
    end

endmodule
