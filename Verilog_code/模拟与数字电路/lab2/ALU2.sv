`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/17 17:23:22
// Design Name: 
// Module Name: ALU2
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


module ALU2(
    input [31:0] a,b,
    input [11:0] f,
    output reg [31:0] y
    );
    reg [31:0] add_out,sub_out,slt_out,sltu_out,and_out,or_out,nor_out,xor_out,sll_out,srl_out,sra_out,a_reverse,sll_out_reverse;
    reg [4:0] b_reverse;
    assign add_out = a+b;
    assign sub_out = a+(~b)+1;   
    assign sltu_out = {32{a - b < 0 ? 1'b1 : 1'b0}};
    assign and_out = a & b;
    assign or_out = a|b;
    assign nor_out = ~(a|b);
    assign xor_out = a^b;
    assign srl_out = a>>b[4:0];
    assign sra_out = a>>>b[4:0];

    assign a_reverse[0]=a[31];    
    assign a_reverse[1]=a[30];
    assign a_reverse[2]=a[29];
    assign a_reverse[3]=a[28];
    assign a_reverse[4]=a[27];
    assign a_reverse[5]=a[26];
    assign a_reverse[6]=a[25];
    assign a_reverse[7]=a[24];
    assign a_reverse[8]=a[23];
    assign a_reverse[9]=a[22];
    assign a_reverse[10]=a[21];
    assign a_reverse[11]=a[20];
    assign a_reverse[12]=a[19];
    assign a_reverse[13]=a[18];
    assign a_reverse[14]=a[17];
    assign a_reverse[15]=a[16];
    assign a_reverse[16]=a[15];
    assign a_reverse[17]=a[14];
    assign a_reverse[18]=a[13];
    assign a_reverse[19]=a[12];
    assign a_reverse[20]=a[11];
    assign a_reverse[21]=a[10];
    assign a_reverse[22]=a[9];
    assign a_reverse[23]=a[8];
    assign a_reverse[24]=a[7];
    assign a_reverse[25]=a[6];
    assign a_reverse[26]=a[5];
    assign a_reverse[27]=a[4];
    assign a_reverse[28]=a[3];
    assign a_reverse[29]=a[2];
    assign a_reverse[30]=a[1];
    assign a_reverse[31]=a[0];

    assign b_reverse[0]=b[4];
    assign b_reverse[1]=b[3];
    assign b_reverse[2]=b[2];
    assign b_reverse[3]=b[1];
    assign b_reverse[4]=b[0];

    always @(*) begin
        sll_out_reverse = a_reverse>>b_reverse[4:0];
        sll_out[0]=sll_out_reverse[31];    
        sll_out[1]=sll_out_reverse[30];
        sll_out[2]=sll_out_reverse[29];
        sll_out[3]=sll_out_reverse[28];
        sll_out[4]=sll_out_reverse[27];
        sll_out[5]=sll_out_reverse[26];
        sll_out[6]=sll_out_reverse[25];
        sll_out[7]=sll_out_reverse[24];
        sll_out[8]=sll_out_reverse[23];
        sll_out[9]=sll_out_reverse[22];
        sll_out[10]=sll_out_reverse[21];
        sll_out[11]=sll_out_reverse[20];
        sll_out[12]=sll_out_reverse[19];
        sll_out[13]=sll_out_reverse[18];
        sll_out[14]=sll_out_reverse[17];
        sll_out[15]=sll_out_reverse[16];
        sll_out[16]=sll_out_reverse[15];
        sll_out[17]=sll_out_reverse[14];
        sll_out[18]=sll_out_reverse[13];
        sll_out[19]=sll_out_reverse[12];
        sll_out[20]=sll_out_reverse[11];
        sll_out[21]=sll_out_reverse[10];
        sll_out[22]=sll_out_reverse[9];
        sll_out[23]=sll_out_reverse[8];
        sll_out[24]=sll_out_reverse[7];
        sll_out[25]=sll_out_reverse[6];
        sll_out[26]=sll_out_reverse[5];
        sll_out[27]=sll_out_reverse[4];
        sll_out[28]=sll_out_reverse[3];
        sll_out[29]=sll_out_reverse[2];
        sll_out[30]=sll_out_reverse[1];
        sll_out[31]=sll_out_reverse[0];
        case(a[31])
            0:begin
                case(b[31])
                    0:begin
                        if(a[30:0]-b[30:0]<0) begin
                            slt_out={32{1'b1}};
                        end 
                        else begin
                            slt_out={32{1'b0}};
                        end
                    end
                    1:begin
                        slt_out={32{1'b0}};
                    end
                endcase
            end
            1:begin
                case(b[31])
                    0:begin
                        slt_out={32{1'b1}};
                    end
                    1:begin
                        if(a[30:0]-b[30:0]<0) begin
                            slt_out={32{1'b1}};
                        end 
                        else begin
                            slt_out={32{1'b0}};
                        end    
                    end
                endcase
            end       
        endcase
        y=({32{f[0]}}&add_out)|({32{f[1]}}&sub_out)|({32{f[2]}}&slt_out)|({32{f[3]}}&sltu_out)|({32{f[4]}}&and_out)|({32{f[5]}}&or_out)|({32{f[6]}}&nor_out)|({32{f[7]}}&xor_out)|({32{f[8]}}&sll_out)|({32{f[9]}}&srl_out)|({32{f[10]}}&sra_out)|({32{f[11]}}&b);
    end
endmodule
