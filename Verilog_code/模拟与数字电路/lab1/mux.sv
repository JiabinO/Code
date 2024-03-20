module mux( 
    input   [3:0] din1,//编码器的输出结果
    input   [3:0] din2,//候选的4位2进制代码
    input   sel,//选择器
    output  reg [3:0] dout//输出的4位2进制代码
);
    always@(*) begin
        case(sel)
        1'b0: dout = din2;
        1'b1: dout = din1;
        endcase
    end
endmodule