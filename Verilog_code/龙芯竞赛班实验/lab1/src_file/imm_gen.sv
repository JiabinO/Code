`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/10 09:55:13
// Design Name: 
// Module Name: imm_gen
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


module imm_gen 
    #(parameter     add_inst        = 6'h00,
                    addi_inst       = 6'h01,
                    sub_inst        = 6'h02,
                    lu12i_inst      = 6'h03,
                    pcaddu12i_inst  = 6'h04,
                    slt_inst        = 6'h05,
                    sltu_inst       = 6'h06,
                    slti_inst       = 6'h07,
                    sltui_inst      = 6'h08,
                    and_inst        = 6'h09,
                    andi_inst       = 6'h0a,
                    or_inst         = 6'h0b,
                    ori_inst        = 6'h0c,
                    nor_inst        = 6'h0d,
                    xor_inst        = 6'h0e,
                    xori_inst       = 6'h0f,
                    sll_inst        = 6'h10,
                    slli_inst       = 6'h11,
                    srl_inst        = 6'h12,
                    srli_inst       = 6'h13,
                    sra_inst        = 6'h14,
                    srai_inst       = 6'h15,
                    stw_inst        = 6'h16,
                    sth_inst        = 6'h17,
                    stb_inst        = 6'h18,
                    ldw_inst        = 6'h19,
                    ldh_inst        = 6'h1a,
                    ldb_inst        = 6'h1b,
                    ldhu_inst       = 6'h1c,
                    ldbu_inst       = 6'h1d,
                    beq_inst        = 6'h1e,
                    bne_inst        = 6'h1f,
                    blt_inst        = 6'h20,
                    bge_inst        = 6'h21,
                    bltu_inst       = 6'h22,
                    bgeu_inst       = 6'h23,
                    b_inst          = 6'h24,
                    bl_inst         = 6'h25,
                    jirl_inst       = 6'h26)
    (
            input       [5:0]  control_bus,
            input       [31:0] instruction,
            output reg  [31:0] imm
    );
    assign imm =    ( {32{control_bus == addi_inst}}         & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == slti_inst}}         & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == sltui_inst}}        & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == andi_inst}}         & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == ori_inst}}          & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == xori_inst}}         & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == slli_inst}}         & {27'b0 ,instruction[14:10]})                                     |
                    ( {32{control_bus == srli_inst}}         & {27'b0 ,instruction[14:10]})                                     |
                    ( {32{control_bus == srai_inst}}         & {27'b0 ,instruction[14:10]})                                     |
                    ( {32{control_bus == lu12i_inst}}        & {{12{instruction[24]}}, instruction[24:5]})                      |
                    ( {32{control_bus == pcaddu12i_inst}}    & {{12{instruction[24]}}, instruction[24:5]})                      |
                    ( {32{control_bus == ldb_inst}}          & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == ldh_inst}}          & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == ldw_inst}}          & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == ldbu_inst}}         & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == ldhu_inst}}         & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == stb_inst}}          & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == sth_inst}}          & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == stw_inst}}          & {{20{instruction[21]}} ,instruction[21:10]})                     |
                    ( {32{control_bus == jirl_inst}}         & {{14{instruction[25]}},instruction[25:10],2'b0})                 |
                    ( {32{control_bus == b_inst}}            & {{4{instruction[9]}},instruction[9:0],instruction[25:10],2'b0})  |
                    ( {32{control_bus == bl_inst}}           & {{4{instruction[9]}},instruction[9:0],instruction[25:10],2'b0})  |
                    ( {32{control_bus == beq_inst}}          & {{14{instruction[25]}},instruction[25:10],2'b0})                 |
                    ( {32{control_bus == bne_inst}}          & {{14{instruction[25]}},instruction[25:10],2'b0})                 |
                    ( {32{control_bus == blt_inst}}          & {{14{instruction[25]}},instruction[25:10],2'b0})                 |
                    ( {32{control_bus == bge_inst}}          & {{14{instruction[25]}},instruction[25:10],2'b0})                 |
                    ( {32{control_bus == bltu_inst}}         & {{14{instruction[25]}},instruction[25:10],2'b0})                 |
                    ( {32{control_bus == bgeu_inst}}         & {{14{instruction[25]}},instruction[25:10],2'b0});
endmodule
