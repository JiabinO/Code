`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/09 08:00:55
// Design Name: 
// Module Name: PC
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


module PC(
        input                   pc_mux, pc_enable, clk, rstn,   //选择线，pc迭代使能，时钟
        input           [31:0]  address_adder,                  //用于计算跳转地址的加法器
        input           [31:0]  fixed_pc,
        input                   fix_flag,
        output  reg     [31:0]  pc                              //输出当前pc
    );

    reg [31:0] next_pc ;
    assign next_pc = pc_mux == 1 ? address_adder + 4 : pc + 4;

    always@(posedge clk) begin
        if(!rstn) begin
            pc <= 32'h80000000;
        end
        else begin
            if(pc_enable) begin
                if(fix_flag) begin
                    pc <= fixed_pc + 4;
                end
                else begin
                    pc <= next_pc;
                end
            end
        end
    end
endmodule
