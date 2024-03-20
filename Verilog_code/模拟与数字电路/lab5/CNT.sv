`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/22 22:37:23
// Design Name: 
// Module Name: CNT
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


module CNT(
    input       clk, rstn, 
    input       pe,  //pe：置数使能，当其有效时，计数器将会将din的值赋值给计数器的当前值
                        // ce：计数使能，当其有效时，计数器将会在时钟上升沿将自身值减一
                        //强制保持计数
    input       [3:0] din, //din：输入数据，即强制置数的数据
    output reg  [3:0] q
    );

    always @(posedge clk, negedge rstn) begin
        if( !rstn ) q <= 4'd0;
        else if (pe) q <= din ;
        else  begin
            if( q == 0)
                q <= 0;
            else
                q <= q - 1;
        end
    end
endmodule
