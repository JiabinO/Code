`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/07 20:06:36
// Design Name: 
// Module Name: H2C_5
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


module H2C_5(
    input [3:0] din,
    output reg [6:0] ascii_num
    );
    always@(*)begin
        case(din)
            4'h0:ascii_num = 7'h30;
            4'h1:ascii_num = 7'h31;
            4'h2:ascii_num = 7'h32;
            4'h3:ascii_num = 7'h33;
            4'h4:ascii_num = 7'h34;
            4'h5:ascii_num = 7'h35;
            4'h6:ascii_num = 7'h36;
            4'h7:ascii_num = 7'h37;
            4'h8:ascii_num = 7'h38;
            4'h9:ascii_num = 7'h39;
            4'ha:ascii_num = 7'h41;
            4'hb:ascii_num = 7'h42;
            4'hc:ascii_num = 7'h43;
            4'hd:ascii_num = 7'h44;
            4'he:ascii_num = 7'h45;
            4'hf:ascii_num = 7'h46;
        endcase
    end
endmodule
