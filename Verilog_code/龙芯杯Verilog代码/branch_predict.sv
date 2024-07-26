`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/26 10:02:45
// Design Name: 
// Module Name: branch_predict
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

`define strongly_not_taken 2'b00 
`define weakly_not_taken 2'b01 
`define weakly_taken 2'b10
`define strongly_taken 2'b11

module branch_predict
#(parameter local_address_len = 8,                              // pc的低local_address_len位与BHR异或后来寻址基于局部历史的两位饱和计数器
            global_address_len = 16,                            // pc的低global_address_len位与GHR异或后来寻址基于全局历史的两位饱和计数器
            BHR_len = 8,                                        // 局部历史寄存器长度
            BHT_len = 8,                                        // 局部历史表寻址长度
            GHR_len = 16,                                       // 全局历史寄存器长度
            CPHT_len = 8                                        // 竞争分支饱和计数器表寻址长度
)    
    (
        input [31:0] instruction_pc,
        input [31:0] instruction,
        output       branch
    );

    reg [1:0] local_PHT [0:(1 << local_address_len) - 1];                                       // 基于局部历史的2位饱和计数器， local Pattern History Table
    reg [1:0] global_PHT[0:(1 << global_address_len) - 1];                                      // 基于全局历史的2位饱和计数器， global Pattern History Table
    wire[local_address_len - 1:0] local_pht_addr;                                               // 异或后用于对基于局部历史的计数器表寻址的pc，减少冲突概率
    wire[global_address_len - 1:0] global_pht_addr;                                             // 异或后用于对基于全局历史的计数器表寻址的pc，减少冲突概率
    reg [BHR_len - 1:0] BHT [0:(1 << BHT_len) - 1];                                             // Branch History Register, 长度取决于最长的循环序列长度, BHR_len <= 2^address_len
    reg [GHR_len - 1:0] GHR;                                                                    // 全局历史寄存器
    reg [1:0] CPHT [0:(1 << GHR_len) - 1];                                                      // 竞争分支饱和计数器表
    
    wire local_correct;
    wire global_correct;
    wire predict_sel;                                                                           // 基于局部历史的预测与基于全局历史的预测选择器
    
    assign local_pht_addr = instruction_pc[BHR_len + 1:2] ^ BHT[instruction_pc[BHT_len+1:2]];   // 使用异或减少BHR冲突情形
    assign global_pht_addr = instruction_pc[GHR_len + 1:2] ^ GHR;
    assign predict_sel = CPHT[global_pht_addr] >= 2'd2;                                         // predict_sel: 1 - global, 0 - local
    

    always @(*) begin
        if()
    end
endmodule
