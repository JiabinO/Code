`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/21 19:15:05
// Design Name: 
// Module Name: SDU_top
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


module SDU_top(

    );
    reg cpu_clk;
    reg cpu_rstn;

  lab6_top # (
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
  )
  lab6_top_inst (
    .cpu_clk(cpu_clk),
    .cpu_rstn(cpu_rstn)
  );
endmodule
