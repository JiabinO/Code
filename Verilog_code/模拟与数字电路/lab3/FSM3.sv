/*************************************************************************************
    Moore型电路一段式顺序码检测比特流序列10101011
    输入：x(单个比特数字)、rstn(低电平有效状态清零)、clk(时钟信号，每次输入产生一个时钟信号)；
    输出：y(是否存在序列，若出现序列则不计算前面重叠部分)、s(3位顺序码led显示当前状态)。
*************************************************************************************/
module FSM3(
    input x,rstn,clk,
    output reg y,
    output reg [2:0] s
);
    always @(posedge clk,negedge rstn)begin
        if(!rstn)begin//接收到清零信号
            y<=0;
            s[2:0]<=3'b000;
        end
        else begin
            case (s)//根据现态与输入更新次态，根据现态更新输出
                3'b000:begin
                    if(x)begin
                        s<=3'b001;
                    end
                    else begin
                        s<=3'b000;
                    end
                    y<=0;
                end
                3'b001:begin
                    if(x)begin
                        s<=3'b001;
                    end
                    else begin
                        s<=3'b010;
                    end
                    y<=0;
                end
                3'b010:begin
                    if(x)begin
                        s<=3'b011;
                    end
                    else begin
                        s<=3'b000;
                    end
                    y<=0;
                end
                3'b011:begin
                    if(x)begin
                        s<=3'b001;
                    end
                    else begin
                        s<=3'b100;
                    end
                    y<=0;
                end
                3'b100:begin
                    if(x)begin
                        s<=3'b101;
                    end
                    else begin
                        s<=3'b000;
                    end
                    y<=0;
                end
                3'b101:begin
                    if(x)begin
                        s<=3'b001;
                    end
                    else begin
                        s<=3'b110;
                    end
                    y<=0;
                end
                3'b110:begin
                    if(x)begin
                        s<=3'b111;
                    end
                    else begin
                        s<=3'b000;
                    end
                    y<=0;
                end
                3'b111: begin
                    if(x)begin
                        s<=3'b000;
                        y<=1;
                    end
                    else begin
                        s<=3'b000;
                        y<=0;
                    end
                end
            endcase
        end
    end
endmodule