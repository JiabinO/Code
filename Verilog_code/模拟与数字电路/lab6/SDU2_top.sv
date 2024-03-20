`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/22 22:08:34
// Design Name: 
// Module Name: SDU2_top
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


module SDU2_top(
    input clk,rstn,rxd,
    output reg txd
    );
    wire clk_cpu;
    wire [31:0] A , B , IMM, IR , MDR, Y, dout_dm, dout_im, dout_rf, npc, pc, addr, pc_chk, din;
    wire we_dm,we_im,clk_ld,debug;
    CPU_2  CPU_2_inst (
      .rstn(rstn),
      .cpu_clk(clk_cpu),
      .addr(addr),
      .A(A),
      .B(B),
      .IMM(IMM),
      .IR(IR),
      .MDR(MDR),
      .Y(Y),
      .dout_dm(dout_dm),
      .dout_im(dout_im),
      .dout_rf(dout_rf),
      .npc(npc),
      .pc(pc)
    );

    SDU  SDU_inst (
    .clk(clk),
    .rstn(rstn),
    .rxd(rxd),
    .txd(txd),
    .clk_cpu(clk_cpu),
    .pc_chk(0),
    .npc(npc),
    .pc(pc),
    .IR(IR),
    .IMM(IMM),
    .CTL(CTL),
    .A(A),
    .B(B),
    .Y(Y),
    .MDR(MDR),
    .addr(addr),
    .dout_rf(dout_rf),
    .dout_dm(dout_dm),
    .dout_im(dout_im),
    .din(din),
    .we_dm(we_dm),
    .we_im(we_im),
    .clk_ld(clk_ld),
    .debug(debug)
  );
endmodule
