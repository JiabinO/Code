`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/11 20:19:24
// Design Name: 
// Module Name: Branch
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


module Branch
    #(parameter branch_beq      = 3'h1,
                branch_bne      = 3'h2,
                branch_blt      = 3'h3,
                branch_bge      = 3'h4,
                branch_bltu     = 3'h5,
                branch_bgeu     = 3'h6,
                branch_direct   = 3'h7
    )
    (
        input [2:0]     branch_type,
        input [5:0]     control_bus_ID_EX,
        input           alu_res,
        output reg      branch_enable
    );

    assign branch_enable =    (((branch_type == branch_beq  | 
                                branch_type == branch_blt   | 
                                branch_type == branch_bne   | 
                                branch_type == branch_bge   | 
                                branch_type == branch_bltu  | 
                                branch_type == branch_bgeu) 
                                & alu_res)                  |
                                branch_type == branch_direct)
                                & control_bus_ID_EX != 6'h27 ;
endmodule
