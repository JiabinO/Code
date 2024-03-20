`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/23 09:37:54
// Design Name: 
// Module Name: clk_pulse
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


module clk_pulse(
    input [31:0] k,
    input clk,
    output reg y_pulse
    );

    reg [31:0] counter;
    initial begin
        y_pulse=0;
        counter=0;        
    end

    always@(posedge clk)begin
        case(k[0])
            0:begin
                if(counter==0)begin
                    y_pulse<=0;
                    counter<=k-1;
                end
                else begin
                    if(counter>(k-1/2))begin
                        y_pulse<=1;
                    end
                    else begin
                        y_pulse<=0;
                    end
                    counter<=counter-1;
                end
            end
            1:begin
                if(counter==0)begin
                    y_pulse<=0;
                    counter<=k;
                end
                else begin
                    if(counter>(k+1/2))begin
                        y_pulse<=1;
                    end
                    else begin
                        y_pulse<=0;
                    end
                    counter<=counter-1;
                end
            end
        endcase
    end
endmodule
