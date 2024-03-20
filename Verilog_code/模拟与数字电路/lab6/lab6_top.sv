`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/15 08:59:07
// Design Name: 
// Module Name: lab6_top
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


module lab6_top# (
    parameter ADDR_WIDTH  = 5,	                            //地址宽度
    parameter DATA_WIDTH  = 32	                            //数据宽度
)(  
      input cpu_clk,cpu_rstn,
      input [31:0] addr,
      output reg [31:0] A,B,IMM,IR,MDR,Y,dout_dm,dout_im,dout_rf,npc,pc
      );
    
    wire [4:0] rf_raddr1,rf_raddr2;
    reg [31:0] rf_wdata;
    wire rf_we;
    wire [ADDR_WIDTH-1:0]  rf_rd;
    wire [31:0] instruction;
    wire alu_op;
    wire mem_we,wb_sel;
    wire [2:0] br_type;
    wire [1:0] alu_src1_sel,alu_src2_sel;
    wire [31:0] imm;
    wire [31:0] inner_pc;
    wire [31:0] alu_result;
    reg [15:0] mem_addr;
    reg [31:0] mem_rdata;
    wire [31:0] rf_rdata1,rf_rdata2;//与mem_wdata的关系是什么
    reg [31:0] data;
    wire jump_en;
    wire [3:0] jump_type;
    wire [31:0] jump_target;
    wire [31:0] IP_rwdata;
    assign Y = alu_result;
    assign MDR = mem_rdata;
    assign pc = inner_pc;
    assign IMM = imm;
    assign IR = instruction;
    
    Data_Memory  Data_Memory_inst (
      .a(mem_addr),
      .d(data),
      .clk(cpu_clk),
      .we(mem_we),
      .spo(mem_rdata),
      .dpra(addr[9:0]),
      .dpo(dout_dm)
    );

    Instruction_Memory  Instruction_Memory_inst (
    .a(inner_pc[11:2]),
    .dpra(addr[11:2]),
    .d(0),
    .we(0),
    .clk(cpu_clk),
    .spo(instruction),
    .dpo(dout_im)
    );

    reg_file # (
      .ADDR_WIDTH(5),
      .DATA_WIDTH(32)
    )
    reg_file_inst (
      .clk(cpu_clk),
      .rf_raddr1(rf_raddr1),
      .rf_raddr2(rf_raddr2),
      .rf_rd(rf_rd),
      .rf_wdata(rf_wdata),
      .rf_we(rf_we),
      .rf_rdata1(rf_rdata1),
      .rf_rdata2(rf_rdata2),
      .rf_dbg_raddr(addr[4:0]),
      .rf_dbg_rdata(dout_rf)
    );

    Decoder # (
        .RF_ADDR_WIDTH(ADDR_WIDTH),
        .IMM_WIDTH(32),
        .ALU_OPCODE_WIDTH(1)
      )
      Decoder_inst (
        .instruction(instruction),
        .clk(cpu_clk),
        .rstn(cpu_rstn),
        .rf_rd(rf_rd),
        .rf_raddr1(rf_raddr1),
        .rf_raddr2(rf_raddr2),
        .rf_we(rf_we),
        .alu_op(alu_op),
        .mem_we(mem_we),
        .br_type(br_type),
        .wb_sel(wb_sel),
        .imm(imm),
        .alu_src1_sel(alu_src1_sel),
        .alu_src2_sel(alu_src2_sel)
      );

    ALU # (
        .ADD_WIDTH(32)
      )
      ALU_inst (
        .alu_op(alu_op),
        .clk(cpu_clk),
        .rstn(cpu_rstn),
        .pc(inner_pc),
        .imm(imm),
        .rf_rdata1(rf_rdata1),
        .rf_rdata2(rf_rdata2),
        .alu_src1_sel(alu_src1_sel),
        .alu_src2_sel(alu_src2_sel),
        .alu_result(alu_result),
        .mux1(A),
        .mux2(B)
      );  

      PC1 # (
        .ADD_WIDTH(32),
        .BR_WIDTH(32)
      )
      PC_inst (
        .jump_en(jump_en),
        .jump_target(jump_target),
        .clk(cpu_clk),
        .rstn(cpu_rstn),
        .pc_out(inner_pc),
        .npc(npc)
      );
      Branch # (
        .ADD_WIDTH(32)
      )
      Branch_inst (
        .br_type(br_type),
        .pc(inner_pc),
        .imm(imm),
        .rf_rdata1(rf_rdata1),
        .rf_rdata2(rf_rdata2),
        .clk(cpu_clk),
        .rstn(cpu_rstn),
        .jump_en(jump_en),
        .jump_target(jump_target)
      ); 
    //add.w 需要等加法操作完成之后才能存储ALU的结果
    
    //rf_wdata的赋值
    always@(*)begin
        if(!wb_sel)begin
            rf_wdata = alu_result;
        end
        else begin
            rf_wdata = mem_rdata;
        end
    end

    //mem_wdata的赋值
    assign data = rf_rdata2;

    //mem_addr的赋值
    always@(*)begin
        mem_addr = 0;
        if(instruction[31:22] == 10'h0A6)begin
            mem_addr = alu_result[9:0];
        end
    end
  
endmodule
