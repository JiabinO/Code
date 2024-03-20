`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/08 17:36:57
// Design Name: 
// Module Name: Decoder
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


module Decoder
    #(parameter add_code        = 17'h00020,
                addi_code       = 10'h00a,  
                sub_code        = 17'h00022,
                lu12i_code      = 7'h0a,     
                pcaddu12i_code  = 7'h0e,    
                slt_code        = 17'h00024,
                sltu_code       = 17'h00025,
                slti_code       = 10'h008,  
                sltui_code      = 10'h009,  
                and_code        = 17'h00029,
                andi_code       = 10'h00d,  
                or_code         = 17'h0002a,
                ori_code        = 10'h00e,  
                nor_code        = 17'h00028,
                xor_code        = 17'h0002b,
                xori_code       = 10'h00f,  
                sll_code        = 17'h0002e,
                slli_code       = 17'h00081,
                srl_code        = 17'h0002f,
                srli_code       = 17'h00089,
                sra_code        = 17'h00030,
                srai_code       = 17'h00091,
                stw_code        = 10'h0a6,  
                sth_code        = 10'h0a5,  
                stb_code        = 10'h0a4,  
                ldw_code        = 10'h0a2,  
                ldh_code        = 10'h0a1,  
                ldb_code        = 10'h0a0,  
                ldhu_code       = 10'h0a9,  
                ldbu_code       = 10'h0a8,  
                beq_code        = 6'h16,    
                bne_code        = 6'h17,    
                blt_code        = 6'h18,    
                bge_code        = 6'h19,    
                bltu_code       = 6'h1a,    
                bgeu_code       = 6'h1b,    
                b_code          = 6'h14,    
                bl_code         = 6'h15,    
                jirl_code       = 6'h13, 
                nop_code        = 32'h0,   
    
                add_inst        = 6'h00, 
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
                nop_inst        = 6'h27
    )
    (
        input       [31:0]  Instruction,
        output  reg [4:0]   rk, 
        output  reg [4:0]   rj, 
        output  reg [4:0]   rd,
        output      [5:0]   control_bus
    );

    assign rk = ({5{Instruction[31:15] == add_code      || 
                    Instruction[31:15] == sub_code      || 
                    Instruction[31:15] == slt_code      ||
                    Instruction[31:15] == sltu_code     ||
                    Instruction[31:15] == nor_code      ||
                    Instruction[31:15] == and_code      ||
                    Instruction[31:15] == or_code       ||
                    Instruction[31:15] == xor_code      ||
                    Instruction[31:15] == sll_code      ||
                    Instruction[31:15] == srl_code      ||
                    Instruction[31:15] == sra_code  }
                    } 
                    & Instruction[14:10]) ;
    
    assign rj = ({5{Instruction[31:15] == add_code      || 
                    Instruction[31:15] == sub_code      || 
                    Instruction[31:15] == slt_code      ||
                    Instruction[31:15] == sltu_code     ||
                    Instruction[31:15] == nor_code      ||
                    Instruction[31:15] == and_code      ||
                    Instruction[31:15] == or_code       ||
                    Instruction[31:15] == xor_code      ||
                    Instruction[31:15] == sll_code      ||
                    Instruction[31:15] == srl_code      ||
                    Instruction[31:15] == sra_code      ||
                    Instruction[31:15] == slli_code     ||
                    Instruction[31:15] == srli_code     ||
                    Instruction[31:15] == srai_code     ||

                    Instruction[31:22] == slti_code     ||
                    Instruction[31:22] == sltui_code    ||
                    Instruction[31:22] == addi_code     ||
                    Instruction[31:22] == andi_code     ||
                    Instruction[31:22] == ori_code      ||
                    Instruction[31:22] == xori_code     ||
                    Instruction[31:22] == ldb_code      ||
                    Instruction[31:22] == ldh_code      ||
                    Instruction[31:22] == ldw_code      ||
                    Instruction[31:22] == stb_code      ||
                    Instruction[31:22] == sth_code      ||
                    Instruction[31:22] == stw_code      ||
                    Instruction[31:22] == ldbu_code     ||
                    Instruction[31:22] == ldhu_code     ||

                    Instruction[31:26] == jirl_code     ||
                    Instruction[31:26] == beq_code      ||
                    Instruction[31:26] == bne_code      ||
                    Instruction[31:26] == blt_code      ||
                    Instruction[31:26] == bge_code      ||
                    Instruction[31:26] == bltu_code     ||
                    Instruction[31:26] == bgeu_code     }
                    }
                    & Instruction[9:5]);

    assign rd = ({5{Instruction[31:15] == add_code      || 
                    Instruction[31:15] == sub_code      || 
                    Instruction[31:15] == slt_code      ||
                    Instruction[31:15] == sltu_code     ||
                    Instruction[31:15] == nor_code      ||
                    Instruction[31:15] == and_code      ||
                    Instruction[31:15] == or_code       ||
                    Instruction[31:15] == xor_code      ||
                    Instruction[31:15] == sll_code      ||
                    Instruction[31:15] == srl_code      ||
                    Instruction[31:15] == sra_code      ||
                    Instruction[31:15] == slli_code     ||
                    Instruction[31:15] == srli_code     ||
                    Instruction[31:15] == srai_code     ||

                    Instruction[31:22] == slti_code     ||
                    Instruction[31:22] == sltui_code    ||
                    Instruction[31:22] == addi_code     ||
                    Instruction[31:22] == andi_code     ||
                    Instruction[31:22] == ori_code      ||
                    Instruction[31:22] == xori_code     ||
                    Instruction[31:22] == ldb_code      ||
                    Instruction[31:22] == ldh_code      ||
                    Instruction[31:22] == ldw_code      ||
                    Instruction[31:22] == stb_code      ||
                    Instruction[31:22] == sth_code      ||
                    Instruction[31:22] == stw_code      ||
                    Instruction[31:22] == ldbu_code     ||
                    Instruction[31:22] == ldhu_code     ||

                    Instruction[31:26] == jirl_code     ||
                    Instruction[31:26] == beq_code      ||
                    Instruction[31:26] == bne_code      ||
                    Instruction[31:26] == blt_code      ||
                    Instruction[31:26] == bge_code      ||
                    Instruction[31:26] == bltu_code     ||
                    Instruction[31:26] == bgeu_code     ||

                    Instruction[31:25] == lu12i_code    ||
                    Instruction[31:25] == pcaddu12i_code}
                    }& Instruction[4:0])
                    |
                    ({5{Instruction[31:26] == bl_code}} & 5'h1)
                    ;
    assign control_bus =    ({6{Instruction[31:15] == add_code }}       & add_inst)         |
                            ({6{Instruction[31:15] == sub_code }}       & sub_inst)         |
                            ({6{Instruction[31:15] == slt_code }}       & slt_inst)         |
                            ({6{Instruction[31:15] == sltu_code}}       & sltu_inst)        |
                            ({6{Instruction[31:15] == nor_code }}       & nor_inst)         |
                            ({6{Instruction[31:15] == and_code }}       & and_inst)         |
                            ({6{Instruction[31:15] == or_code  }}       & or_inst)          |
                            ({6{Instruction[31:15] == xor_code }}       & xor_inst)         |
                            ({6{Instruction[31:15] == sll_code }}       & sll_inst)         |
                            ({6{Instruction[31:15] == srl_code }}       & srl_inst)         |
                            ({6{Instruction[31:15] == sra_code }}       & sra_inst)         |
                            ({6{Instruction[31:15] == slli_code}}       & slli_inst)        |
                            ({6{Instruction[31:15] == srli_code}}       & srli_inst)        |
                            ({6{Instruction[31:15] == srai_code}}       & srai_inst)        |
                    
                            ({6{Instruction[31:22] == slti_code }}      & slti_inst)        |
                            ({6{Instruction[31:22] == sltui_code}}      & sltui_inst)       |
                            ({6{Instruction[31:22] == addi_code }}      & addi_inst)        |
                            ({6{Instruction[31:22] == andi_code }}      & andi_inst)        |
                            ({6{Instruction[31:22] == ori_code  }}      & ori_inst)         |
                            ({6{Instruction[31:22] == xori_code }}      & xori_inst)        |
                            ({6{Instruction[31:22] == ldb_code  }}      & ldb_inst)         |
                            ({6{Instruction[31:22] == ldh_code  }}      & ldh_inst)         |
                            ({6{Instruction[31:22] == ldw_code  }}      & ldw_inst)         |
                            ({6{Instruction[31:22] == stb_code  }}      & stb_inst)         |
                            ({6{Instruction[31:22] == sth_code  }}      & sth_inst)         |
                            ({6{Instruction[31:22] == stw_code  }}      & stw_inst)         |
                            ({6{Instruction[31:22] == ldbu_code }}      & ldbu_inst)        |
                            ({6{Instruction[31:22] == ldhu_code }}      & ldhu_inst)        |
                    
                            ({6{Instruction[31:25] == lu12i_code    }}  & lu12i_inst)       |
                            ({6{Instruction[31:25] == pcaddu12i_code}}  & pcaddu12i_inst)   |
                            
                            ({6{Instruction[31:26] == jirl_code}}       & jirl_inst)        |
                            ({6{Instruction[31:26] == beq_code }}       & beq_inst)         |
                            ({6{Instruction[31:26] == bne_code }}       & bne_inst)         |
                            ({6{Instruction[31:26] == blt_code }}       & blt_inst)         |
                            ({6{Instruction[31:26] == bge_code }}       & bge_inst)         |
                            ({6{Instruction[31:26] == bltu_code}}       & bltu_inst)        |
                            ({6{Instruction[31:26] == bgeu_code}}       & bgeu_inst)        |
                            ({6{Instruction[31:26] == b_code }}         & b_inst)           |
                            ({6{Instruction[31:26] == bl_code }}        & bl_inst)          |
                            ({32{Instruction[31:0] == nop_code}}        & nop_inst);


endmodule
