`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/19 12:25:42
// Design Name: 
// Module Name: mul
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


module mul(
    input [31:0] a,b,
    input clk,
    input [1:0] en,
    output reg [31:0] l,h
    );
    reg [15:0][63:0] partial_product;
    reg [63:0] sum;
    wire [9:0][63:0] depth1result; 
    wire [5:0][63:0] depth2result;
    wire [3:0][63:0] depth3result;
    wire [3:0][63:0] depth4result;
    wire [1:0][63:0] depth5result;
    wire [1:0][63:0] depth6result;
    wire [1:0][63:0] buffer;
    coder Coder16(
        .y2(b[31]),
        .y1(b[30]),
        .y0(b[29]),
        .x({{2{a[31]}}, a, 30'b0}),
        .cout(partial_product[15])
    );
    coder Coder15(
        .y2(b[29]),
        .y1(b[28]),
        .y0(b[27]),
        .x({{4{a[31]}}, a, 28'b0}),
        .cout(partial_product[14])
    );
    coder Coder14(
        .y2(b[27]),
        .y1(b[26]),
        .y0(b[25]),
        .x({{6{a[31]}}, a, 26'b0}),
        .cout(partial_product[13])
    );
    coder Coder13(
        .y2(b[25]),
        .y1(b[24]),
        .y0(b[23]),
        .x({{8{a[31]}}, a, 24'b0}),
        .cout(partial_product[12])
    );
    coder Coder12(
        .y2(b[23]),
        .y1(b[22]),
        .y0(b[21]),
        .x({{10{a[31]}}, a, 22'b0}),
        .cout(partial_product[11])
    );
    coder Coder11(
        .y2(b[21]),
        .y1(b[20]),
        .y0(b[19]),
        .x({{12{a[31]}}, a, 20'b0}),
        .cout(partial_product[10])
    );
    coder Coder10(
        .y2(b[19]),
        .y1(b[18]),
        .y0(b[17]),
        .x({{14{a[31]}}, a, 18'b0}),
        .cout(partial_product[9])
    );
    coder Coder9(
        .y2(b[17]),
        .y1(b[16]),
        .y0(b[15]),
        .x({{16{a[31]}}, a, 16'b0}),
        .cout(partial_product[8])
    );
    coder Coder8(
        .y2(b[15]),
        .y1(b[14]),
        .y0(b[13]),
        .x({{18{a[31]}}, a, 14'b0}),
        .cout(partial_product[7])
    );
    coder Coder7(
        .y2(b[13]),
        .y1(b[12]),
        .y0(b[11]),
        .x({{20{a[31]}}, a, 12'b0}),
        .cout(partial_product[6])
    );
    coder Coder6(
        .y2(b[11]),
        .y1(b[10]),
        .y0(b[9]),
        .x({{22{a[31]}}, a, 10'b0}),
        .cout(partial_product[5])
    );
    coder Coder5(
        .y2(b[9]),
        .y1(b[8]),
        .y0(b[7]),
        .x({{24{a[31]}}, a, 8'b0}),
        .cout(partial_product[4])
    );
    coder Coder4(
        .y2(b[7]),
        .y1(b[6]),
        .y0(b[5]),
        .x({{26{a[31]}}, a, 6'b0}),
        .cout(partial_product[3])
    );
    coder Coder3(
        .y2(b[5]),
        .y1(b[4]),
        .y0(b[3]),
        .x({{28{a[31]}}, a, 4'b0}),
        .cout(partial_product[2])
    );
    coder Coder2(
        .y2(b[3]),
        .y1(b[2]),
        .y0(b[1]),
        .x({{30{a[31]}}, a, 2'b0}),
        .cout(partial_product[1])
    );
    coder Coder1(
        .y2(b[1]),
        .y1(b[0]),
        .y0(0),
        .x({{32{a[31]}}, a}),
        .cout(partial_product[0])
    );
    //第一层树
    tree depth1tree1(
        .a(partial_product[15]),
        .b(partial_product[14]),
        .cin(partial_product[13]),
        .s(depth1result[9]),
        .cout(depth1result[8])
    );
    tree depth1tree2(
        .a(partial_product[12]),
        .b(partial_product[11]),
        .cin(partial_product[10]),
        .s(depth1result[7]),
        .cout(depth1result[6])
    );
    tree depth1tree3(
        .a(partial_product[9]),
        .b(partial_product[8]),
        .cin(partial_product[7]),
        .s(depth1result[5]),
        .cout(depth1result[4])
    );
    tree depth1tree4(
        .a(partial_product[6]),
        .b(partial_product[5]),
        .cin(partial_product[4]),
        .s(depth1result[3]),
        .cout(depth1result[2])
    );
    tree depth1tree5(
        .a(partial_product[3]),
        .b(partial_product[2]),
        .cin(partial_product[1]),
        .s(depth1result[1]),
        .cout(depth1result[0])
    );
    //第二层树
    tree depth2tree1(
        .a(depth1result[9]),
        .b(depth1result[8]),
        .cin(depth1result[7]),
        .s(depth2result[5]),
        .cout(depth2result[4])
    );
    tree depth2tree2(
        .a(depth1result[6]),
        .b(depth1result[5]),
        .cin(depth1result[4]),
        .s(depth2result[3]),
        .cout(depth2result[2])
    );
    tree depth2tree3(
        .a(depth1result[3]),
        .b(depth1result[2]),
        .cin(depth1result[1]),
        .s(depth2result[1]),
        .cout(depth2result[0])
    );
    //第三层树
    tree depth3tree1(
        .a(depth2result[5]),
        .b(depth2result[4]),
        .cin(depth2result[3]),
        .s(depth3result[3]),
        .cout(depth3result[2])
    );
    tree depth3tree2(
        .a(depth2result[2]),
        .b(depth2result[1]),
        .cin(depth2result[0]),
        .s(depth3result[1]),
        .cout(depth3result[0])
    );
    //第四层树
    tree depth4tree1(
        .a(depth3result[3]),
        .b(depth3result[2]),
        .cin(depth3result[1]),
        .s(depth4result[3]),
        .cout(depth4result[2])
    );
    tree depth4tree2(
        .a(depth3result[0]),
        .b(depth1result[0]),
        .cin(partial_product[0]),
        .s(depth4result[1]),
        .cout(depth4result[0])
    );
    //第五层树
    tree depth5tree(
        .a(depth4result[3]),
        .b(depth4result[2]),
        .cin(depth4result[1]),
        .s(depth5result[1]),
        .cout(depth5result[0])
    );
    //第六层树
    tree depth6tree(
        .a(depth5result[1]),
        .b(depth5result[0]),
        .cin(depth4result[0]),
        .s(depth6result[1]),
        .cout(depth6result[0])
    );

    register # (
    .WIDTH(64),
    .RST_VAL(0)
    )
    register_inst_1l (
    .clk(clk),
    .rst(rst),
    .en(en[0]),
    .d(depth6result[0]),
    .q(buffer[0])
    );
    
    register # (
    .WIDTH(64),
    .RST_VAL(0)
    )
    register_inst_2h (
    .clk(clk),
    .rst(rst),
    .en(en[1    ]),
    .d(depth6result[1]),
    .q(buffer[1])
    );
    always @(*)begin
        sum=buffer[1]+buffer[0];
        l=sum[31:0];
        h=sum[63:32];
    end
endmodule
