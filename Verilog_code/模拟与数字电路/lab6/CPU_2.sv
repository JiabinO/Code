`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/21 20:22:00
// Design Name: 
// Module Name: CPU_2
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


module CPU_2(
    input rstn,cpu_clk,
    input [31:0] addr,
    output reg [31:0] A,B,IMM,IR,MDR,Y,dout_dm,dout_im,dout_rf,npc,pc
    );
    reg [31:0] instruction_reg,imm_reg,rf_rd_reg,rf_rdata1_reg,rf_rdata2_reg,alu_result_reg,jump_target_reg,mem_rdata_reg;
    reg alu_op_reg,mem_we_reg,wb_sel_reg,jump_en_reg,rf_we_reg;
    reg [1:0] alu_src1_sel_reg,alu_src2_sel_reg;
    reg [2:0] br_type_reg;
    wire [4:0] rf_raddr1,rf_raddr2;
    reg [31:0] rf_wdata;
    wire rf_we;
    wire [4:0]  rf_rd;
    wire [31:0] instruction;
    wire alu_op;
    wire mem_we,wb_sel;
    wire [2:0] br_type;
    wire [1:0] alu_src1_sel,alu_src2_sel;
    wire [31:0] imm;
    wire [31:0] inner_pc;
    wire [31:0] alu_result;
    reg [9:0] mem_addr;
    reg [31:0] mem_rdata;
    wire [31:0] rf_rdata1,rf_rdata2;//与mem_wdata的关系是什么
    reg [31:0] data;
    wire jump_en;
    wire [3:0] jump_type;
    wire [31:0] jump_target;
    wire [31:0] IP_rwdata; 
    reg [2:0] cu_count;
    assign Y = alu_result_reg;
    assign MDR = mem_rdata_reg;
    assign IR = instruction_reg;
    assign IMM = imm_reg;
    initial begin
      npc = 32'h1c000000;
    end
    //npc
    always@(*)begin
      if(cu_count == 5)begin
        npc = inner_pc;
      end
    end
    Data_Memory  Data_Memory_inst (
      .a(mem_addr),
      .d(rf_rdata2_reg),
      .clk(cpu_clk),
      .we(mem_we_reg),
      .spo(mem_rdata),
      .dpra(addr),
      .dpo(dout_dm)
    );

    Instruction_Memory  Instruction_Memory_inst (
    .a(inner_pc[17:2]),
    .dpra(addr[17:2]),
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


      Decoder2 # (
        .RF_ADDR_WIDTH(5),
        .IMM_WIDTH(32),
        .ALU_OPCODE_WIDTH(1)
      )
      Decoder2_inst (
        .instruction(instruction_reg),
        .clk(cpu_clk),
        .rstn(rstn),
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
        .alu_src2_sel(alu_src2_sel),
        .cu_count(cu_count)
      );
    ALU # (
        .ADD_WIDTH(32)
      )
      ALU_inst (
        .alu_op(alu_op),
        .clk(cpu_clk),
        .rstn(rstn),
        .pc(inner_pc),
        .imm(imm),
        .rf_rdata1(rf_rdata1),
        .rf_rdata2(rf_rdata2),
        .alu_src1_sel(alu_src1_sel_reg),
        .alu_src2_sel(alu_src2_sel_reg),
        .alu_result(alu_result),
        .mux1(A),
        .mux2(B)
      );  

      PC2 # (
        .ADD_WIDTH(32),
        .BR_WIDTH(32)
      )
      PC2_inst (
        .jump_en(jump_en_reg),
        .jump_target(jump_target_reg),
        .clk(cpu_clk),
        .rstn(rstn),
        .cu_count(cu_count),
        .pc_out(inner_pc)
      );

      Branch2 # (
        .ADD_WIDTH(32)
      )
      Branch2_inst (
        .br_type(br_type),
        .pc(pc),
        .imm(imm_reg),
        .rf_rdata1(rf_rdata1_reg),
        .rf_rdata2(rf_rdata2_reg),
        .cpu_clk(cpu_clk),
        .rstn(rstn),
        .jump_en(jump_en),
        .jump_target(jump_target),
        .cu_count(cu_count)
      );
    
    counter # (
        .WIDTH(3),
        .RST_VLU(4)
      )
    Control_Unit (
        .clk(cpu_clk),
        .rstn(rstn),
        .pe( cu_count == 1),
        .ce(|cu_count),
        .din(5),
        .q(cu_count) //addi_w状态机，当检测到指令为addi_w时，3-译码，2-ALU运算，1-写回
      );



    //br_type_reg
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            br_type_reg <= 7;
        end
        else begin
            br_type_reg <= br_type;
        end
      end

      //alu_op_reg
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            alu_op_reg <= 0;
        end
        else begin
            alu_op_reg <= alu_op;
        end
      end

      //mem_we_reg
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            mem_we_reg <= 0;
        end
        else begin
          if(cu_count == 2 && instruction_reg[31:22] == 10'h0A6)begin
            mem_we_reg <= mem_we;
          end
          else begin
            mem_we_reg <= 0;
          end
        end
      end

      //wb_sel_reg
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            wb_sel_reg <= 0;
        end
        else begin
          if(cu_count == 4)
            wb_sel_reg <= wb_sel;
        end
      end

      //jump_en_reg
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            jump_en_reg <= 0;
        end
        else begin
            jump_en_reg <= jump_en;
        end
      end

      //rf_we_reg
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            rf_we_reg <= 0;
        end
        else begin
            rf_we_reg <= rf_we;
        end
      end

      //imm_reg
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            imm_reg <= 0;
        end
        else begin
              imm_reg <= imm;
            end
      end

      //rf_rd_reg
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            rf_rd_reg <= 0;
        end
        else begin
            if(cu_count == 1 && (instruction_reg[31:26] == 6'h0 || instruction_reg[31:25] == 7'h0A || instruction_reg[31:22] == 10'h0A2))begin
              rf_rd_reg <= rf_rd;
            end
        end
      end

      //rf_rdata1_reg
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            rf_rdata1_reg <= 0;
        end
        else begin
            rf_rdata1_reg <= rf_rdata1;
        end
      end

      //rf_rdata2_reg
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            rf_rdata2_reg <= 0;
        end
        else begin
            // if(cu_count == 4 && (instruction_reg[31:22] == 10'h0A6 || instruction_reg[31:22] == 10'h000 || instruction_reg[31:26] == 6'h17))begin 
                rf_rdata2_reg <= rf_rdata2; 
            // end
        end
      end
      //alu_result
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            alu_result_reg <= 0;
        end
        else begin
            if(cu_count == 3 && (instruction_reg[31:26] == 6'h0A || instruction_reg[31:25] == 7'h0A || instruction_reg[31:26] == 6'h00 ) && instruction_reg != 32'h0) begin
              alu_result_reg <= alu_result;
            end
        end
      end

      //jump_target
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            jump_target_reg <= 0;
        end
        else begin
            jump_target_reg <= jump_target;
        end
      end

      //mem_rdata_reg 的赋值
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            mem_rdata_reg <= 0;
        end
        else begin
            if(cu_count == 2 && (instruction[31:22] == 10'h0A2))begin
              mem_rdata_reg <= mem_rdata;
            end
        end
      end

      //instruction_reg 的赋值
      always@(posedge cpu_clk)begin
        if(!rstn)begin
            instruction_reg <= 0;
        end
        else begin
          if(cu_count == 5)
            instruction_reg <= instruction; // 取指令
        end
      end

      //alu_src1_sel_reg 的赋值
      always@(posedge cpu_clk)begin
        if(!rstn)begin
          alu_src1_sel_reg <= 0;
        end
        else begin
          if(cu_count == 4)
          alu_src1_sel_reg <= alu_src1_sel; // 取指令
        end
      end

      //alu_src2_sel_reg 的赋值
      always@(posedge cpu_clk)begin
        if(!rstn)begin
          alu_src2_sel_reg <= 0;
        end
        else begin
          if(cu_count == 4)
          alu_src2_sel_reg <= alu_src2_sel; // 取指令
        end
      end

      always@(posedge cpu_clk)begin
        if(!rstn)begin
          pc <= 0;
        end
        else begin
          if(cu_count == 5) pc <= inner_pc;
        end
      end
      
      //rf_wdata
      always@(*)begin
        rf_wdata = wb_sel_reg ? mem_rdata_reg : alu_result_reg;//如果为 wb_sel_reg = 0 ，则以alu作为数据输入来源，反之为内存的数据
      end

      always@(*)begin
        if(cu_count == 2 && instruction_reg[31:22] == 10'h0A6)begin// 访存地址计算
          mem_addr = alu_result_reg[9:0];
        end
      end
endmodule
