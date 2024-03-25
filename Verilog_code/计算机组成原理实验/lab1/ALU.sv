`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 16:54:28
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
    #(parameter add_op  = 4'h0,
                sub_op  = 4'h1,
                slt_op  = 4'h2,
                sltu_op = 4'h3,
                and_op  = 4'h4,
                or_op   = 4'h5,
                nor_op  = 4'h6,
                xor_op  = 4'h7,
                sll_op  = 4'h8,
                srl_op  = 4'h9,
                sra_op  = 4'hA,
                ass_op  = 4'hB
    )
    (
        input   [31:0]  src0,
        input   [31:0]  src1,
        input   [3:0]   op,
        output  [31:0]  res
    );

    wire        adder_cout;
    wire [31:0] adder_res;
    wire [31:0] slt_res;
    wire [31:0] sltu_res;
    wire [31:0] and_res;
    wire [31:0] or_res;
    wire [31:0] nor_res;
    wire [31:0] xor_res;
    wire [31:0] sll_res;
    wire [31:0] srl_res;
    wire [31:0] sra_res;

    wire [31:0] shift_src;
    wire [31:0] shift_res;
    assign {adder_cout, adder_res}  =   src0 + (op == sub_op | op == slt_op | op == sltu_op ? ~src1 + 1 : src1);
    assign slt_res                  =   {{31{1'b0}},{( src0[31] & ~src1[31] | ( ~(src0[31] ^ src1[31]) & adder_cout ))}};
    assign sltu_res                 =   {{31{1'b0}},adder_cout};
    assign sra_res                  =   src0 >>> src1[4:0];

    assign shift_src                =   op == slt_op ? 
                                        {
                                            src0[0],     src0[1],     src0[2],     src0[3],
                                            src0[4],     src0[5],     src0[6],     src0[7],
                                            src0[8],     src0[9],     src0[10],    src0[11],
                                            src0[12],    src0[13],    src0[14],    src0[15],
                                            src0[16],    src0[17],    src0[18],    src0[19],
                                            src0[20],    src0[21],    src0[22],    src0[23],
                                            src0[24],    src0[25],    src0[26],    src0[27],                                    
                                            src0[28],    src0[29],    src0[30],    src0[31]
                                        }
                                        :   src0;
    assign shift_res                =   shift_src >> src1;
    assign sll_res                  =   {
                                            shift_res[0],    shift_res[1],    shift_res[2],    shift_res[3],
                                            shift_res[4],    shift_res[5],    shift_res[6],    shift_res[7],
                                            shift_res[8],    shift_res[9],    shift_res[10],   shift_res[11],
                                            shift_res[12],   shift_res[13],   shift_res[14],   shift_res[15],
                                            shift_res[16],   shift_res[17],   shift_res[18],   shift_res[19],
                                            shift_res[20],   shift_res[21],   shift_res[22],   shift_res[23],
                                            shift_res[24],   shift_res[25],   shift_res[26],   shift_res[27],                                    
                                            shift_res[28],   shift_res[29],   shift_res[30],   shift_res[31]
                                        };
    assign srl_res                  =   shift_res;

    assign and_res                  =   src0 & src1;
    assign or_res                   =   src0 | src1;
    assign nor_res                  =   ~or_res;
    assign xor_res                  =   src0 ^ src1;

    assign res                      =   ({{32{op == and_op | op == sub_op}} & adder_res} | 
                                         {{32{op == slt_op}}                & slt_res}   |
                                         {{32{op == sltu_op}}               & sltu_res}  |
                                         {{32{op == and_op}}                & and_res}   |
                                         {{32{op == or_op}}                 & or_res}    |
                                         {{32{op == nor_op}}                & nor_res}   |
                                         {{32{op == xor_op}}                & xor_res}   |
                                         {{32{op == sll_op}}                & sll_res}   |
                                         {{32{op == srl_op}}                & srl_res}   |
                                         {{32{op == sra_op}}                & sra_res}   |
                                         {{32{op == ass_op}}                & src1});
endmodule
