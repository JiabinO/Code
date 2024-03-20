`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/12 15:23:03
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
    (
    input [31:0] a,b,
    input [11:0] f,
    output reg [31:0] y
    );
    reg [31:0] add_out,sub_out,slt_out,sltu_out,and_out,or_out,nor_out,xor_out,sll_out,srl_out,sra_out;
    assign add_out = a+b;
    assign sub_out = a-b;   
    assign sltu_out = {32{a < b ? 1'b1 : 1'b0}};
    assign and_out = a & b;
    assign or_out = a|b;
    assign nor_out = ~(a|b);
    assign xor_out = a^b;
    assign sll_out = a<<b[4:0];
    assign srl_out = a>>b[4:0];
    assign sra_out = a>>>b[4:0];
    always @(*) begin
        case(a[31])
            0:begin
                case(b[31])
                    0:begin
                        if(a[30:0]<b[30:0]) begin
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
                        if(a[30:0]<b[30:0]) begin
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
