`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/21 12:51:13
// Design Name: 
// Module Name: top
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


module top(
    input clk,rstn,rxd,
    output reg txd
    );

    wire flag_rx,ack_rx,ack_tx,req_rx,req_tx,type_tx,data_mode,vld_rx,rdy_rx,vld_tx;
    wire [7:0] d_rx;
    wire [31:0] din_rx,dout_tx;
    TFD1  TFD1_inst (
    .k(163),
    .clk(clk),
    .tclk(tclk)
    );
    DIF  DIF_inst (
    .clk(tclk),
    .rstn(rstn),
    .flag_rx(flag_rx),
    .din_rx(din_rx),
    .ack_rx(ack_rx),
    .ack_tx(ack_tx),
    .req_rx(req_rx),
    .req_tx(req_tx),
    .dout_tx(dout_tx),
    .type_tx(type_tx),
    .data_mode(data_mode)
    );

  SCAN # (
    .DATAWIDTH(32),
    .S1(8'hC4),
    .S2(8'hC9),
    .S3(8'hCC),
    .S4(8'hD2)
  )
  SCAN_inst (
    .d_rx(d_rx),
    .vld_rx(vld_rx),
    .req_rx(req_rx),
    .clk(tclk),
    .rstn(rstn),
    .flag_rx(flag_rx),
    .rdy_rx(rdy_rx),
    .ack_rx(ack_rx),
    .din_rx(din_rx)
  );

  rx  rx_inst (
    .rxd(rxd),
    .rdy_rx(rdy_rx),
    .clk(tclk),
    .rstn(rstn),
    .d_rx(d_rx),
    .vld_rx(vld_rx)
  );

  SHOW_Char  SHOW_Char_inst (
    .clk(tclk),
    .rstn(rstn),
    .dout_tx(dout_tx),
    .type_tx(type_tx),
    .req_tx(req_tx),
    .data_mode(data_mode),
    .ack_tx(ack_tx),
    .txd(txd)
  );
endmodule
