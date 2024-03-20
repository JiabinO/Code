`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/10 09:50:54
// Design Name: 
// Module Name: address_adder
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


module address_adder(
        input       [31:0] pc,
        input       [31:0] imm,
        output      [31:0] pc_jump
        );
    assign pc_jump = pc + imm;
endmodule
