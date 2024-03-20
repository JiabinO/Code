`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/15 09:28:34
// Design Name: 
// Module Name: Decoder
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


module Decoder2 #(parameter RF_ADDR_WIDTH = 5,IMM_WIDTH = 32,ALU_OPCODE_WIDTH = 1)(
        input [31:0]  instruction,                              //输入指令
        input clk,rstn,
        input [2:0] cu_count,
        output reg [RF_ADDR_WIDTH-1:0] rf_rd,                   //寄存器堆写端口的地址，这个地址可能由指令中的rd字段给出，但在bl指令中，这个地址为1
        output reg [RF_ADDR_WIDTH-1:0] rf_raddr1,rf_raddr2,     //寄存器堆读端口1的地址，这个地址由指令中的rj字段给出; 寄存器堆读端口2的地址，这个地址由指令中的rk或rd字段给出
        output reg rf_we,                                       //寄存器堆写使能信号
        output reg [ALU_OPCODE_WIDTH-1:0] alu_op,               //ALU的操作类型，由译码器根据指令的意义给出 0-加法 1-符号扩展立即数加法 
        output reg mem_we,                                      //数据存储器写使能信号，当指令为store类型时，这个信号为1
        output reg [2:0] br_type,                               //跳转指令的类型，根据指令是否跳转以及跳转的类型给出 跳转条件分别为( 操作数分别为 rj 和 rd )： 0-相等(BEQ) 1-不等(BNE) 2-有符号小于(BLT) 3-有符号大于(BGE) 4-无符号小于(BLTU) 5-无符号大于(BGEU),规定 7-不跳转
        output reg wb_sel,                                      //写回的数据来源，可能来自ALU和Data_Memory 0-Data_Memory 1-ALU
        output reg [IMM_WIDTH-1:0] imm,                         //符号位扩展后的立即数，其拼接方式和指令的类型有关。特别注意，对于许多跳转指令，这个地址往往省略了最低两位的0。
        output reg [1:0] alu_src1_sel,                          //0-pc 1-rf_rdata1 2-0
        output reg [1:0] alu_src2_sel                           //0-imm 1-rf_rdata2 2-4
    );

    //目前实现: 
    //add.w     000000  0000    0100000 rk5 rj5 rd5     rd = rj + rk
    //addi.w    000000  1010    si12        rj5 rd5     rd = rj + si12
    //lu12i.w   000101  0       si20            rd5     rd = {si20,12'b0}
    //st.w      001010  0110    si12        rj5 rd5     Mem[ GR[rj] + SignExtend[ si12 ] ] = GR[rd] 
    //ld.w      001010  0010    si12        rj5 rd5     rd = Mem[ GR[rj] + SignExtend[ si12 ] ]
    //bne       010111          offset16    rj5 rd5     PC = GR[rj] == GR[rd] ? PC : PC + SignExtend{ { offset16, 2'b0 } , 32} 注意offset扩展不要前两位
    reg [4:0] rk , rj , rd ;
    //rk的赋值
    always@(*)begin
        if( cu_count == 4 && instruction[31:22]==10'b0 )begin
            rk = instruction[14:10];
        end
    end
    
    //rj的赋值
    always@(*)begin
        if( cu_count == 4 && (instruction[31:26]==6'h00 || instruction[31:26]==6'h0A || instruction[31:26]==6'h17) ) begin
            rj = instruction[9:5]; 
        end
    end

    //rd的赋值
    always@(*)begin
        if( cu_count == 4 && (instruction[31:26]==6'h00 || instruction[31:25]==7'h0A || instruction[31:26]==6'h0A || instruction[31:26]==6'h17)  ) begin
            rd = instruction[4:0]; 
        end
    end

    //rf_we的赋值
    always@(*)begin
        rf_we = 0;
        if(cu_count == 1 && (instruction[31:26]==6'h00 || instruction[31:25]==7'h0A || instruction[31:22]==10'h0A2) && instruction != 32'h0)begin
            rf_we = 1;
        end
        else begin
            rf_we = 0;
        end

    end

    //rf_rd的赋值
    always@(*)begin
        if(cu_count == 4 )begin
            if( instruction[31:26]==6'h00 || instruction[31:25]==7'h0A || instruction[31:26]==6'h0A || instruction[31:26]==6'h17 )begin
                rf_rd = instruction[4:0];//当指令为 add.w、addi.w、lu12i.w、ld.w 时将rd的值赋给rf_rd
            end
        end
    end

    //rf_raddr1的赋值
    always@(*)begin
        if(cu_count == 4)begin
            if( instruction[31:26]==6'h00 || instruction[31:26]==6'h0A || instruction[31:26]==6'h17) begin
                rf_raddr1 = rj;    //当指令为 add.w  addi.w  st.w  ld.w  bne  
            end
        end
    end

    //rf_raddr2的赋值
    always@(*)begin
        if(cu_count == 4)begin
            if( instruction[31:22]==10'h0A6 || instruction[31:26]==6'h17 ) begin    //
                rf_raddr2 = rd;
            end
            else if( instruction[31:22]==10'h00 ) begin
                rf_raddr2 = rk;
            end
        end
    end

    //alu_op的赋值
    always@(*)begin
        if( instruction[31:22] == 10'h000 ) begin       // add.w
            alu_op = 0;
        end
        else if ( instruction[31:22] == 10'h00A ) begin // addi.w
            alu_op = 1;
        end
    end

    //mem_we的赋值
    always@(*)begin
        if(instruction[31:22] == 10'h0A6 && cu_count == 2)begin
            mem_we = 1;
        end
        else begin
            mem_we = 0;
        end
    end

    //br_type的赋值
    always@(*)begin
        if(cu_count == 4)begin
            if( instruction[31:26] == 6'h17 )begin
                br_type = 3'd1;                    //bne
            end
            else begin
                br_type = 3'd7;
            end
        end
    end

    //wb_sel的赋值
    always@(*)begin
        if(cu_count == 4) begin
            if( instruction[31:26] == 6'h00 || instruction[31:26] == 6'h0A )begin
                wb_sel = 0;                                //来源是ALU
            end
            else if( instruction[31:22] == 10'h0A2) begin
                wb_sel = 1;                                //来源是数据内存
            end
        end
    end
    //imm_的赋值
    always@(*)begin
        if(cu_count == 4 ) begin
            if( instruction[31:22] == 10'h0A2 || instruction[31:22] == 10'h00A || instruction[31:22] == 10'h0A6 )begin
                imm = {{20{instruction[21]}}, instruction[21:10]};         //addi.w st.w ld.w 12位立即数位扩展
            end
            else if( instruction[31:25] == 7'h0A )begin
                imm = {instruction[24:5],12'b0};                           //lu12i.w
            end
            else if( instruction[31:26] == 6'h17)begin
                imm = {{14{instruction[17]}},instruction[25:10],2'b0};      //bne 位扩展 + 左移两位
            end
        end
    end

    // alu_src1_sel
    always@(*)begin
        if(cu_count == 4)begin//译码阶段
            if(instruction[31:26] == 6'h00 || instruction[31:26] == 6'h0A || instruction[31:26] == 6'h17 ) begin
                alu_src1_sel = 1;//rj
            end
            else if(instruction[31:26] == 6'h05) begin
                alu_src1_sel = 2;//0
            end
        end
    end
    //alu_src2_sel
    always@(*)begin
        if(cu_count == 4) begin
            if(instruction[31:22] == 10'h000 || instruction[31:26] == 6'h17) begin
                alu_src2_sel = 1;//rk或rd
            end
            else if(instruction[31:22] == 10'h00A || instruction[31:26] == 6'h05 || instruction[31:26] == 6'h0A ) begin
                alu_src2_sel = 0;//imm
            end
        end
    end
endmodule
