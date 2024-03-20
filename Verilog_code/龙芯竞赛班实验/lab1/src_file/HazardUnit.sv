`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/11 11:02:39
// Design Name: 
// Module Name: HazardUnit
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


module HazardUnit(
        input       [4:0]   rs1_ID, 
        input       [4:0]   rs2_ID, 
        input       [4:0]   rd_ID_EX,
        input               mem_read,
        output reg          fStall, dStall, eFlush
    );

    assign fStall = (rd_ID_EX == rs1_ID || rd_ID_EX == rs2_ID ) & mem_read;
    assign dStall = fStall;
    assign eFlush = fStall;
endmodule
