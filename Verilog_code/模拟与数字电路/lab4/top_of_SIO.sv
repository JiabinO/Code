`timescale 1ns/1ps
module top_of_SIO(
    input               clk,            //clk100mhz
    input               rstn,           //cpu_resetn
    input [15:0]        x,              //sw15-0
	  input               ent,            //btnc
    input               del,            //btnl
    input               step,           //btnr
	  input               pre,            //btnu	
    input               nxt,            //btnd
    input               rxd,            //外部电脑串口输入
    output [15:0]       taddr,          //led15-0 
    output [2:0]        flag,           //led 16 15-0，指示数码管显示的数据类型
    output [7:0]        an,             //an7-0
    output [6:0]        seg,            //ca-cg
    output              txd             //外部电脑串口输出
);
    wire [31:0]  tdout;
    reg [31:0] tdin;
    wire [31:0] receive_in;
    reg [31:0] put_out_reg,receive_in_reg;
    wire twe;
    wire rst, tclk;
    wire vld_tx,rdy_tx;
    wire [7:0] d_tx;
    wire [7:0] d_rx;
    wire vld_rx,rdy_rx;
    wire step_stable;
    reg step_1;
    wire clk1;
    wire clk2;
    TFD1  TFD1_inst (
    .k(2604),
    .clk(clk),
    .tclk(clk1)
    );
    
    TFD1  TFD2_inst (
    .k(163),
    .clk(clk),
    .tclk(clk2)
    );

    always@(posedge clk1)begin
        step_1<=step_stable;
    end
    wire step_p = step_stable & ~step_1;
    utu_of_SIO  utu_inst (
        .clk    (clk),
        .rstn   (rstn),
        .x      (x),
        .ent    (ent),
        .del    (del),
        .step   (step),
        .pre    (pre),
        .nxt    (nxt),
        .taddr  (taddr),
        .tdin   (tdin),
        .tdout  (tdout),
        .twe    (twe),
        .flag   (flag),
        .an     (an),
        .seg    (seg),
        .rst    (rst),
        .tclk   (tclk),
        .step_stable (step_stable)
    );
    
    puts  puts_inst (
      .din      (put_out_reg),
      .we       (step_p),
      .rdy_tx   (rdy_tx),
      .clk      (clk1),
      .rstn     (rstn),
      .d_tx     (d_tx),
      .vld_tx   (vld_tx)
    );

    tx  tx_inst (
      .vld_tx   (vld_tx),
      .d_tx     (d_tx),
      .clk      (clk1),
      .rstn     (rstn),
      .rdy_tx   (rdy_tx),
      .txd      (txd)
    );

    rx  rx_inst (
      .rxd      (rxd),
      .rdy_rx   (rdy_rx),
      .clk      (clk2),
      .rstn     (rstn),
      .d_rx     (d_rx),
      .vld_rx   (vld_rx)
    );

    gets  gets_inst (
      .d_rx     (d_rx),
      .vld_rx   (vld_rx),
      .clk      (clk2),
      .rstn     (rstn),
      .rdy_rx   (rdy_rx),
      .dout     (receive_in)
    );
    
    register# ( .WIDTH(32), .RST_VAL(0))
    puts (
        .clk    (clk),
        .rstn    (rstn),
        .en     (taddr == 16'h0 && twe),
        .d      (tdout),
        .q      (put_out_reg)
    );

    

    register# ( .WIDTH(32), .RST_VAL(0))
    gets (
        .clk    (clk1),
        .rstn    (rstn),
        .en     (1),
        .d      (receive_in),
        .q      (receive_in_reg)
    );
    
    always@(*) begin
        case(taddr)
        16'h0:   tdin = put_out_reg;
        16'h1:   tdin = receive_in_reg;
        default: tdin = 0;
        endcase
    end

endmodule

