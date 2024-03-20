`timescale 1ns/1ps
module top1(
    input               clk,            //clk100mhz
    input               rstn,           //cpu_resetn
        
    input [15:0]        x,              //sw15-0
	  input               ent,            //btnc
    input               del,            //btnl
    input               step,           //btnr
	  input               pre,            //btnu	
    input               nxt,            //btnd
        
    //输出指示
    output [15:0]       taddr,          //led15-0 
    output [2:0]        flag,           //led 16 15-0，指示数码管显示的数据类型
    output [7:0]        an,             //an7-0
    output [6:0]        seg             //ca-cg
);
    wire [31:0]  tdout;
    reg [31:0] tdin;
    wire twe;    
    wire rst, tclk;

    wire an0,an1,an2,an3; 
    wire [31:0] d0_reg,d1_reg,d2_reg,d3_reg,mux_reg;
    wire [15:0] mux = ({16{~(an0)}}&d0_reg[15:0])||({16{~(an1)}}&d1_reg[15:0])||({16{~(an2)}}&d2_reg[15:0])||({16{~(an3)}}&d3_reg[15:0]);
    

    DIS  DIS_inst (
    .d0(d0_reg),
    .d1(d1_reg),
    .d2(d2_reg),
    .d3(d3_reg),
    .clk(clk),
    .rst(rst),
    .st(1),
    .an0(an0),
    .an1(an1),
    .an2(an2),
    .an3(an3),
    .cn(cn)
    );

    register # (
        .WIDTH(32),
        .RST_VAL(0)
      )
      register_inst1 (
        .clk(clk),
        .rst(rst),
        .en(taddr == 16'h0 && twe),
        .d(tdout),
        .q(d0_reg)
      );

    register # (
        .WIDTH(32),
        .RST_VAL(0)
      )
      register_inst2 (
        .clk(clk),
        .rst(rst),
        .en(taddr == 16'h1 && twe),
        .d(tdout),
        .q(d1_reg)
    );
    register # (
        .WIDTH(32),
        .RST_VAL(0)
      )
      register_inst3 (
        .clk(clk),
        .rst(rst),
        .en(taddr == 16'h2 && twe),
        .d(tdout),
        .q(d2_reg)
      );
    register # (
        .WIDTH(32),
        .RST_VAL(0)
      )
      register_inst (
        .clk(clk),
        .rst(rst),
        .en(taddr == 16'h3 && twe),
        .d(tdout),
        .q(d3_reg)
    );

    register # (
        .WIDTH(32),
        .RST_VAL(0)
      )
    register_inst5 (
        .clk(clk),
        .rst(rst),
        .en(taddr == 16'h4 && twe),
        .d({{16{1'b0}},mux}),
        .q(mux_reg)
      );

    utu  utu_inst (
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
        .tclk   (tclk)
    );

    always@(*) begin
        case(taddr)
        16'h0:   tdin = d0_reg;
        16'h1:   tdin = d1_reg;
        16'h2:   tdin = d2_reg;
        16'h3:   tdin = d3_reg;
        16'h4:   tdin = mux_reg;
        default: tdin = 0;
        endcase
    end
endmodule

