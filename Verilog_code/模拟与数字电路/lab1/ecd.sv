`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/30 12:50:26
// Design Name: 
// Module Name: ecd
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

module ecd(
    input [9:0] a,//待处理2进制代码
    input enable,seltype,//输入使能，编码模式选择，0为普通编码，1为优先编码
    output reg flag,//有效标志
    output reg [3:0] dout//编码结果
);
    always@(*) begin
        if(enable==0) begin dout=4'b0000; flag = 0;end//使能为0时，输出为0000，且无效
        else begin
            case(seltype)
                1'b0: begin //选择普通编码模式
                        case(a)
                            10'b0000000001: begin dout = 4'b0000; flag=1'b1;end
                            10'b0000000010: begin dout = 4'b0001;flag=1'b1;end
                            10'b0000000100: begin dout = 4'b0010;flag=1'b1;end
                            10'b0000001000: begin dout = 4'b0011;flag=1'b1;end
                            10'b0000010000: begin dout = 4'b0100;flag=1'b1;end
                            10'b0000100000: begin dout = 4'b0101;flag=1'b1;end
                            10'b0001000000: begin dout = 4'b0110;flag=1'b1;end
                            10'b0010000000: begin dout = 4'b0111;flag=1'b1;end
                            10'b0100000000: begin dout = 4'b1000;flag=1'b1;end
                            10'b1000000000: begin dout = 4'b1001;flag=1'b1;end
                            default: begin dout = 4'b0000; flag=1'b0;end
                        endcase
                      end
                      
                1'b1: begin  //选择优先编码模式
                       if(a[9]) begin dout = 4'b1001; flag = 1'b1;end
                       else if(a[8]) begin dout = 4'b1000; flag = 1'b1;end
                       else if(a[7]) begin dout = 4'b0111; flag = 1'b1;end
                       else if(a[6]) begin dout = 4'b0110; flag = 1'b1;end
                       else if(a[5]) begin dout = 4'b0101; flag = 1'b1;end
                       else if(a[4]) begin dout = 4'b0100; flag = 1'b1;end
                       else if(a[3]) begin dout = 4'b0011; flag = 1'b1;end
                       else if(a[2]) begin dout = 4'b0010; flag = 1'b1;end
                       else if(a[1]) begin dout = 4'b0001; flag = 1'b1;end
                       else if(a[0]) begin dout = 4'b0000; flag = 1'b1;end 
                       else begin dout = 4'b0000; flag = 1'b0; end
                       end
            endcase
        end            
    end
endmodule
