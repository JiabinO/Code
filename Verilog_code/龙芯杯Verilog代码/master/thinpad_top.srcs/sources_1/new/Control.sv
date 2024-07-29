`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/09 09:34:46
// Design Name: 
// Module Name: Control
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


module Control
    #(parameter add_inst        = 6'h00,
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
                jirl_inst       = 6'h26,
                nop_inst        = 6'h27,
                add_op          = 5'h00,
                addi_op         = 5'h01,
                sub_op          = 5'h02,
                lu12i_op        = 5'h03,
                pcaddu12i_op    = 5'h04,
                slt_op          = 5'h05,
                sltu_op         = 5'h06,
                slti_op         = 5'h07,
                sltui_op        = 5'h08,
                and_op          = 5'h09,
                or_op           = 5'h0a,
                nor_op          = 5'h0b,
                xor_op          = 5'h0c,
                andi_op         = 5'h0d,
                ori_op          = 5'h0e,
                xori_op         = 5'h0f,
                sll_op          = 5'h10,
                srl_op          = 5'h11,
                sra_op          = 5'h12,
                slli_op         = 5'h13,
                srli_op         = 5'h14,
                srai_op         = 5'h15,
                beq_op          = 5'h16,
                bne_op          = 5'h17,
                blt_op          = 5'h18,
                bge_op          = 5'h19,
                bltu_op         = 5'h1a,
                bgeu_op         = 5'h1b,
                bl_op           = 5'h1c,
                jirl_op         = 5'h1d   
    )
    (
        input       [5:0]   control_bus,        //译码输出对应命令编码
        // input               branch_enable,
        output reg  [4:0]   alu_ctrl,           //alu操作控制
        // output reg  [2:0]   branch_type,        //跳转类型
        output reg          mem_read,           //读信号，有效时可以暂时性地改变内存读地址
        output reg          mem_write,          //内存写使能
        // output reg          mem_to_reg,         //选择写回reg的数据，数据来源有alu、mem
        // output reg          alu_src1, alu_src2, //alu的Op1、Op2数据来源选择线，Op1:rj、pc, Op2:rk、imm32
        output reg          rf_write            //寄存器堆写使能
    );  


    assign alu_ctrl     =       ({5{control_bus == add_inst}}       &  add_op)          |
                                ({5{control_bus == addi_inst}}      &  addi_op)         |
                                ({5{control_bus == sub_inst}}       &  sub_op)          |
                                ({5{control_bus == lu12i_inst}}     &  lu12i_op)        |
                                ({5{control_bus == pcaddu12i_inst}} &  pcaddu12i_op)    |
                                ({5{control_bus == slt_inst}}       &  slt_op)          |
                                ({5{control_bus == sltu_inst}}      &  sltu_op)         |
                                ({5{control_bus == slti_inst}}      &  slti_op)         |
                                ({5{control_bus == sltui_inst}}     &  sltui_op)        |
                                ({5{control_bus == and_inst}}       &  and_op)          |
                                ({5{control_bus == or_inst}}        &  or_op)           |
                                ({5{control_bus == nor_inst}}       &  nor_op)          |
                                ({5{control_bus == xor_inst}}       &  xor_op)          |
                                ({5{control_bus == andi_inst}}      &  andi_op)         |
                                ({5{control_bus == ori_inst}}       &  ori_op)          |
                                ({5{control_bus == xori_inst}}      &  xori_op)         |
                                ({5{control_bus == sll_inst}}       &  sll_op)          |
                                ({5{control_bus == srl_inst}}       &  srl_op)          |
                                ({5{control_bus == sra_inst}}       &  sra_op)          |
                                ({5{control_bus == slli_inst}}      &  slli_op)         |
                                ({5{control_bus == srli_inst}}      &  srli_op)         |
                                ({5{control_bus == srai_inst}}      &  srai_op)         |
                                ({5{control_bus == beq_inst}}       &  beq_op)          |
                                ({5{control_bus == bne_inst}}       &  bne_op)          |
                                ({5{control_bus == blt_inst}}       &  blt_op)          |
                                ({5{control_bus == bge_inst}}       &  bge_op)          |
                                ({5{control_bus == bltu_inst}}      &  bltu_op)         |
                                ({5{control_bus == bgeu_inst}}      &  bgeu_op)         |
                                ({5{control_bus == bl_inst}}        &  bl_op)           |
                                ({5{control_bus == jirl_inst}}      &  jirl_op)
                                ;

    // assign branch_type  =       ({3{control_bus == beq_inst }} & branch_beq)    |
    //                             ({3{control_bus == bne_inst }} & branch_bne)    |
    //                             ({3{control_bus == blt_inst }} & branch_blt)    |
    //                             ({3{control_bus == bge_inst }} & branch_bge)    |
    //                             ({3{control_bus == bltu_inst}} & branch_bltu)   |
    //                             ({3{control_bus == bgeu_inst}} & branch_bgeu)   |
    //                             ({3{control_bus == b_inst   }} & branch_direct) |
    //                             ({3{control_bus == bl_inst  }} & branch_direct) |
    //                             ({3{control_bus == jirl_inst}} & branch_direct) ;
                                
    assign mem_read     =       (   control_bus == ldw_inst    |
                                    control_bus == ldh_inst    | 
                                    control_bus == ldb_inst    | 
                                    control_bus == ldhu_inst   | 
                                    control_bus == ldbu_inst   
                                );

    assign mem_write    =       (   control_bus == stb_inst     | 
                                    control_bus == sth_inst     |
                                    control_bus == stw_inst
                                );

    assign rf_write     =       (   control_bus == add_inst         |
                                    control_bus == addi_inst        |
                                    control_bus == sub_inst         |
                                    control_bus == lu12i_inst       |
                                    control_bus == pcaddu12i_inst   |
                                    control_bus == slt_inst         |
                                    control_bus == sltu_inst        |
                                    control_bus == slti_inst        |
                                    control_bus == sltui_inst       |
                                    control_bus == and_inst         |
                                    control_bus == or_inst          |
                                    control_bus == nor_inst         |
                                    control_bus == xor_inst         |
                                    control_bus == andi_inst        |
                                    control_bus == ori_inst         |
                                    control_bus == xori_inst        |
                                    control_bus == sll_inst         |
                                    control_bus == srl_inst         |
                                    control_bus == sra_inst         |
                                    control_bus == slli_inst        |
                                    control_bus == srli_inst        |
                                    control_bus == srai_inst        |
                                    control_bus == ldw_inst         |
                                    control_bus == ldh_inst         |
                                    control_bus == ldb_inst         |
                                    control_bus == ldhu_inst        |
                                    control_bus == ldbu_inst        |
                                    control_bus == bl_inst          |
                                    control_bus == jirl_inst
                                );

    // // 0 - rj, 1 - pc
    // assign alu_src1     =       control_bus == pcaddu12i_inst       |
    //                             control_bus == jirl_inst            |
    //                             control_bus == bl_inst;
                        

    // // 0 - rk, 1 - imm32(要预处理)
    // assign alu_src2     =       (   control_bus == addi_inst        |
    //                                 control_bus == lu12i_inst       |
    //                                 control_bus == pcaddu12i_inst   |
    //                                 control_bus == srai_inst        |
    //                                 control_bus == slli_inst        |
    //                                 control_bus == srli_inst        |
    //                                 control_bus == sltui_inst       |
    //                                 control_bus == slti_inst        |
    //                                 control_bus == andi_inst        |
    //                                 control_bus == ori_inst         |
    //                                 control_bus == xori_inst        |
    //                                 control_bus == b_inst           |
    //                                 control_bus == bl_inst          |
    //                                 control_bus == jirl_inst        |
    //                                 control_bus == stw_inst         |
    //                                 control_bus == stb_inst         |
    //                                 control_bus == sth_inst         |
    //                                 control_bus == ldb_inst         |
    //                                 control_bus == ldh_inst         |
    //                                 control_bus == ldw_inst         |
    //                                 control_bus == ldbu_inst        |
    //                                 control_bus == ldhu_inst
    //                             );
endmodule
