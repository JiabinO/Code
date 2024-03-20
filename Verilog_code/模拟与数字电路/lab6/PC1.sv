`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/15 09:00:25
// Design Name: 
// Module Name: PC
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


module PC1#(parameter ADD_WIDTH = 32,BR_WIDTH = 32 )(
    input                       jump_en,
    input [BR_WIDTH-1:0]        jump_target,    
    input                       clk,rstn,
    output reg [ADD_WIDTH-1:0]  pc_out,
    output reg [31:0]           npc
    );
    
    reg [ADD_WIDTH-1:0] pc_plus_4;
    //pc_out更新
    always@(posedge clk)begin
        if(!rstn)begin
            pc_out <= 32'h1c000000;
        end
        else begin
            if(jump_en)begin
                pc_out<= jump_target;
            end
            else begin
                pc_out<=pc_plus_4;
            end
        end
    end
    
    //pc_plus_4更新
    always@(posedge clk)begin
        if(!rstn)begin
            pc_plus_4 <= 32'h1c000000;
        end
        else begin
            if(jump_en)begin
                pc_plus_4<= jump_target;
            end
            else begin
                pc_plus_4<=pc_out + 4;
            end
        end
        // pc_plus_4 <= pc_out + 4;
    end
    assign npc = jump_en ? jump_target : pc_plus_4; 

endmodule
