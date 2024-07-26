`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/06 22:39:19
// Design Name: 
// Module Name: ALU
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


module ALU
    #(parameter add_op          = 5'h0,
                addi_op         = 5'h1,
                sub_op          = 5'h2,
                lu12i_op        = 5'h3,
                pcaddu12i_op    = 5'h4,
                slt_op          = 5'h5,
                sltu_op         = 5'h6,
                slti_op         = 5'h7,
                sltui_op        = 5'h8,
                and_op          = 5'h9,
                or_op           = 5'ha,
                nor_op          = 5'hb,
                xor_op          = 5'hc,
                andi_op         = 5'hd,
                ori_op          = 5'he,
                xori_op         = 5'hf,
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
        input       [31:0]  Op1, 
        input       [31:0]  Op2,   //Op1数据来源有rj,pc, Op2数据来源有rk,imm32(要预处理auipc情形),4
        input       [4:0]   Ctrl,
        output  reg [31:0]  alu_res
    );

    wire [31:0] and_result              =   Op1 & Op2;
    wire [31:0] or_result               =   Op1 | Op2;
    wire [31:0] xor_result              =   Op1 ^ Op2;
    wire [31:0] nor_result              =   ~or_result;
    wire [31:0] adder_result;
    wire        adder_cout;
    assign {adder_cout, adder_result}   =   Op1 + ( Ctrl == sub_op      |
                                                    Ctrl == slt_op      | 
                                                    Ctrl == slti_op     | 
                                                    Ctrl == sltu_op     |
                                                    Ctrl == sltui_op    | 
                                                    Ctrl == bgeu_op     | 
                                                    Ctrl == bge_op      | 
                                                    Ctrl == blt_op      | 
                                                    Ctrl == bltu_op 
                                                    ? ~Op2 + 1 :(Ctrl == bl_op | Ctrl == jirl_op ? 4 : Op2));

    wire [31:0] slt_result              =   { {31{1'b0}}, ( Op1[31] & !Op2[31]) | (~(Op1[31] ^ Op2[31] ) & adder_result[31]) };
    wire [31:0] sltu_result             =   { {31{1'b0}}, adder_cout };
    wire [31:0] shift_src               =   Ctrl == slli_op | Ctrl == sll_op ? 
                                        {
                                            Op1[0],     Op1[1],     Op1[2],     Op1[3],
                                            Op1[4],     Op1[5],     Op1[6],     Op1[7],
                                            Op1[8],     Op1[9],     Op1[10],    Op1[11],
                                            Op1[12],    Op1[13],    Op1[14],    Op1[15],
                                            Op1[16],    Op1[17],    Op1[18],    Op1[19],
                                            Op1[20],    Op1[21],    Op1[22],    Op1[23],
                                            Op1[24],    Op1[25],    Op1[26],    Op1[27],                                    
                                            Op1[28],    Op1[29],    Op1[30],    Op1[31]
                                        }
                                        :   Op1;
    wire [31:0] unsigned_mask           =   32'hffffffff >>> Op2;
    wire [31:0] shift_result            =   ($signed(shift_src) >>> Op2) & unsigned_mask;
    
    wire [31:0] srl_result              =   shift_result;
    wire [31:0] sll_result              =  
                                        {
                                            shift_result[0],    shift_result[1],    shift_result[2],    shift_result[3],
                                            shift_result[4],    shift_result[5],    shift_result[6],    shift_result[7],
                                            shift_result[8],    shift_result[9],    shift_result[10],   shift_result[11],
                                            shift_result[12],   shift_result[13],   shift_result[14],   shift_result[15],
                                            shift_result[16],   shift_result[17],   shift_result[18],   shift_result[19],
                                            shift_result[20],   shift_result[21],   shift_result[22],   shift_result[23],
                                            shift_result[24],   shift_result[25],   shift_result[26],   shift_result[27],                                    
                                            shift_result[28],   shift_result[29],   shift_result[30],   shift_result[31]
                                        };
    wire [31:0] signed_mask             =   ~({{32{Op1[31]}}} >>> Op2);
    wire [31:0] sra_result              =   (Op1[31] ?  (srl_result | signed_mask) : srl_result);
    wire [31:0] lu12i_result            =   {Op2[19:0],{12{1'b0}}};
    wire [31:0] pcaddu12i_result        =   lu12i_result + Op1;//此时Op1选择pc线，Op2选择20位有符号数位扩展结果
    assign alu_res                      =   ({32{Ctrl == add_op || Ctrl == addi_op || Ctrl == sub_op || Ctrl == bl_op || Ctrl == jirl_op}}      & adder_result)         |
                                            ({32{Ctrl == lu12i_op}}                                                                             & lu12i_result)         |
                                            ({32{Ctrl == pcaddu12i_op}}                                                                         & pcaddu12i_result)     |
                                            ({32{Ctrl == slt_op || Ctrl == slti_op }}                                                           & slt_result)           |
                                            ({32{Ctrl == sltu_op || Ctrl == sltui_op }}                                                         & sltu_result)          |
                                            ({32{Ctrl == and_op || Ctrl == andi_op}}                                                            & and_result)           |
                                            ({32{Ctrl == or_op || Ctrl == ori_op}}                                                              & or_result)            |
                                            ({32{Ctrl == nor_op}}                                                                               & nor_result)           |
                                            ({32{Ctrl == xor_op || Ctrl == xori_op}}                                                            & xor_result)           |
                                            ({32{Ctrl == sll_op || Ctrl == slli_op}}                                                            & sll_result)           |
                                            ({32{Ctrl == srl_op || Ctrl == srli_op}}                                                            & srl_result)           |
                                            ({32{Ctrl == sra_op || Ctrl == srai_op}}                                                            & sra_result)           |
                                            ({{31{1'b0}},{Ctrl == beq_op & Op1 == Op2}})                                                                                |
                                            ({{31{1'b0}},{Ctrl == bne_op & Op1 != Op2}})                                                                                |
                                            ({{31{1'b0}},{Ctrl == blt_op & slt_result[0]}})                                                                             |
                                            ({{31{1'b0}},{Ctrl == bge_op & !slt_result[0]}})                                                                            |
                                            ({{31{1'b0}},{Ctrl == bltu_op & sltu_result[0]}})                                                                           |
                                            ({{31{1'b0}},{Ctrl == bgeu_op & !sltu_result[0]}})                              
                                            ;
endmodule
