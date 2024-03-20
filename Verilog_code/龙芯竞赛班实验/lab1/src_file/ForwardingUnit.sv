`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/11 11:02:23
// Design Name: 
// Module Name: ForwardingUnit
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


    module ForwardingUnit(
        input       [4:0]   rs1_ID_EX, 
        input       [4:0]   rs2_ID_EX, 
        input       [4:0]   rd_EX_MEM, 
        input       [4:0]   rd_MEM_WB,
        input               writeback_EX_MEM, writeback_MEM_WB,
        output  reg [1:0]   afwd, 
        output  reg [1:0]   bfwd
    );
    //afwd和bfwd的编码: 0 - 译码器当个周期的译码结果, 1 - MEM/WB时段写回数据选择器的数据, 2 - EX/MEM时段ALU的计算结果  3 - 该周期有写入信号但要下个时钟上升沿才能写入的数据

    assign afwd =   {{2{ ~(~(rs1_ID_EX == rd_EX_MEM && writeback_EX_MEM) && rs1_ID_EX == rd_MEM_WB && writeback_MEM_WB) && rs1_ID_EX != rd_EX_MEM && rs1_ID_EX != rd_MEM_WB }}                    & 2'd0} | /*没有数据相关*/
                    {{2{ ~(rs1_ID_EX == rd_EX_MEM && writeback_EX_MEM) && rs1_ID_EX == rd_MEM_WB && writeback_MEM_WB}} & 2'd1} | /*与ALU计算好的下个周期有数据相关*/
                    {{2{ rs1_ID_EX == rd_EX_MEM && writeback_EX_MEM}} & 2'd2} ; 

    assign bfwd =   {{2{ ~(~(rs2_ID_EX == rd_EX_MEM && writeback_EX_MEM) && rs2_ID_EX != rd_EX_MEM && rs2_ID_EX == rd_MEM_WB && writeback_MEM_WB) && rs2_ID_EX != rd_EX_MEM && rs2_ID_EX != rd_MEM_WB }} & 2'd0} |
                    {{2{ ~(rs2_ID_EX == rd_EX_MEM && writeback_EX_MEM) && rs2_ID_EX == rd_MEM_WB && writeback_MEM_WB}} & 2'd1} |
                    {{2{ rs2_ID_EX == rd_EX_MEM && writeback_EX_MEM}} & 2'd2} ; 
endmodule
