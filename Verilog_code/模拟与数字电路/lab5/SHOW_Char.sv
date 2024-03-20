`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/08 21:24:50
// Design Name: 
// Module Name: SHOW_Char
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



module SHOW_Char(
    input        clk, rstn,
    input [31:0] dout_tx ,  //字节或字数据 
    input        type_tx ,  //0-字节，1-字
    input        req_tx  ,  //发送请求


    input     data_mode ,//如果为0，传输数据；如果为1，传输指令/ASCII
 
    output reg   ack_tx  ,
    output reg   txd
    );
    reg [7:0] d_tx;
    reg   rdy_tx ;
    reg reg_vld;
    wire start ;
    reg  start_reg;
    wire FDclk;
    reg vld_tx;
    

    TX  TX_inst (
        .clk(clk),
        .rstn(rstn),
        .d_tx(d_tx),
        .vld_tx(vld_tx),
        .rdy_tx(rdy_tx),
        .txd(txd)
    );
    

    assign start = ack_tx & req_tx;
    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            start_reg <= 1'b0;
        end
        else begin
            start_reg <= start;
        end
    end


    //d_tx
    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            d_tx <= 8'd0;
        end
        else if( start == 1'b1 ) begin 
            d_tx <= dout_tx[7:0];
        end
    end


    //vld_tx
    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            vld_tx <= 1'b1;
        end
        else if( vld_tx == 1'b1 && rdy_tx == 1'b1 ) begin
            vld_tx <= 1'b0;
        end
        else if( start_reg == 1'b1 && reg_vld != 1'b1) begin
            vld_tx <= 1'b1;
        end
    end
    //reg_vld
    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            reg_vld <= 1'b1;
        end
        else begin
            reg_vld <= vld_tx;
        end
    end

    //ack_tx
    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            ack_tx <= 1'b1; 
        end
        else if( ack_tx == 1'b1 && req_tx == 1'b1 )begin
            ack_tx <= 1'b0;
        end
        else if( rdy_tx == 1'b1 && vld_tx == 1'b1) begin
            ack_tx <= 1'b1;
        end
    end

endmodule
