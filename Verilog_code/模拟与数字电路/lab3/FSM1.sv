`timescale 1ns / 1ps
/********************************************************************************
    Mealy型电路两段式顺序码检测比特流序列10101011
    输入：x(单个比特数字)、rstn(低电平有效状态清零)、clk(时钟信号，每次输入产生一个时钟信号)；
    输出：y(是否存在序列，若出现序列则不计算前面重叠部分)、s(三位顺序码led显示当前状态)。
********************************************************************************/
module FSM1(
    input x,rstn,clk,
    output reg y,
    output reg [2:0] s
);
    reg [2:0] d,q;//next state,current state
    reg y_cs,y_ns;//y的现态与次态
    always @(*) begin//计算下个状态
        d[2]=(q[2]&&(~q[0])&&x)||((q[2]^q[1])&&q[0]&&(~x));
        d[1]=(q[1]&&(~q[0])&&x)||((~q[1])&&q[0]&&(~x));
        d[0]=((~q[2])||(~q[1])||(~q[0]))&&x;
        y_ns=q[2]&&q[1]&&q[0]&&x;
        y=y_cs;
        s[2:0]=q[2:0];
    end
    always @(posedge clk , negedge rstn) begin
        if(!rstn) begin//接收到清零信号，清零
            q <= 0;
        end
        else begin//更新状态
            q<=d;
            y_cs<=y_ns;
        end
    end
endmodule