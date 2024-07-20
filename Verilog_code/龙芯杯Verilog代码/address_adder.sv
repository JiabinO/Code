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
        input       [5:0]  control_bus_ID_EX,
        input       [31:0] rj_data_ID_EX,
        output      [31:0] pc_jump
        );
    assign pc_jump = imm + (control_bus_ID_EX == 6'h26 ? rj_data_ID_EX : pc); 
endmodule
