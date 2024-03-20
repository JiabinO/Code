`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/15 21:20:14
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


module ALU #(parameter ADD_WIDTH = 32)(
    input alu_op,clk,rstn,
    input [ADD_WIDTH-1:0] pc,
    input [31:0] imm,
    input [31:0] rf_rdata1,rf_rdata2,
    input [1:0] alu_src1_sel,alu_src2_sel,
    output reg [31:0] mux1,mux2,
    output reg [31:0] alu_result
    );

    

    //alu_result的更新
    always@(*)begin
        case(alu_op)
            0: alu_result <= mux1 + mux2;
            1: alu_result <= mux1 + mux2;
        endcase
    end

    //mux1的更新
    always@(*)begin
            case(alu_src1_sel)
                2'd0: mux1 = {16'b0,pc};
                2'd1: mux1 = rf_rdata1;
                2'd2: mux1 = 0;
                default: mux1 = 32'hffffffff;
            endcase
    end

    //mux2的更新
    always@(*)begin
            case(alu_src2_sel)
                2'd0: mux2 = imm;
                2'd1: mux2 = rf_rdata2;
                2'd2: mux2 = 32'd4;
                default: mux2 = 32'hffffffff;
            endcase
        end
endmodule
