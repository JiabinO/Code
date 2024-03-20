`timescale 1ns / 1ps
/*************************************************************************************
    Moore型电路两段式顺序码检测比特流序列10101011
    输入：x(单个比特数字)、rstn(低电平有效状态清零)、clk(时钟信号，每次输入产生一个时钟信号)；
    输出：y(是否存在序列，若出现序列则不计算前面重叠部分)、s(3位顺序码led显示当前状态)。
*************************************************************************************/
module FSM4(
    input x,rstn,clk,
    output reg y,
    output reg [2:0] s
    );
    reg [2:0] d;
    reg y_ns;
    always @(posedge clk,negedge rstn)begin
        if(!rstn) begin //接收到清零信号
            s<=3'b000;
        end
        else begin//更新现态
            s<=d;
            y<=y_ns;
        end
    end

    always @(*)begin
        y_ns=0;
        d=s;
        case(s)//根据现态与输入计算次态，
            3'b000:begin
                if(x==0)begin
                    d=3'b000;
                end
                else begin
                    d=3'b001;
                end
                y_ns=0;
            end
            3'b001:begin
                if(x==0)begin
                    d=3'b010;
                end
                else begin
                    d=3'b001;
                end
                y_ns=0;
            end
            3'b010:begin
                if(x==0)begin
                    d=3'b000;
                end
                else begin
                    d=3'b011;
                end
                y_ns=0;
            end
            3'b011:begin
                if(x==0)begin
                    d=3'b100;
                end
                else begin
                    d=3'b001;
                end
                y_ns=0;
            end
            3'b100:begin
                if(x==0)begin
                    d=3'b000;
                end
                else begin
                    d=3'b101;
                end
                y_ns=0;
            end
            3'b101:begin
                if(x==0)begin
                    d=3'b110;
                end
                else begin
                    d=3'b001;
                end
                y_ns=0;
            end
            3'b110:begin
                if(x==0)begin
                    d=3'b000;
                end
                else begin
                    d=3'b111;
                end
                y_ns=0;
            end
            3'b111:begin
                if(x==0)begin
                    d=3'b000;
                    y_ns=0;
                end
                else begin
                    d=3'b000;
                    y_ns=1;
                end
            end
        endcase
    end
endmodule
