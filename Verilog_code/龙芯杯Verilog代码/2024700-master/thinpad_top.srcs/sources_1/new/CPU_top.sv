`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/06 19:56:56
// Design Name: 
// Module Name: CPU_top
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


module CPU_top 
#(parameter 
            add_code        = 17'h00020,
            addi_code       = 10'h00a,  
            sub_code        = 17'h00022,
            lu12i_code      = 7'h0a,     
            pcaddu12i_code  = 7'h0e,    
            slt_code        = 17'h00024,
            sltu_code       = 17'h00025,
            slti_code       = 10'h008,  
            sltui_code      = 10'h009,  
            and_code        = 17'h00029,
            andi_code       = 10'h00d,  
            or_code         = 17'h0002a,
            ori_code        = 10'h00e,  
            nor_code        = 17'h00028,
            xor_code        = 17'h0002b,
            xori_code       = 10'h00f,  
            sll_code        = 17'h0002e,
            slli_code       = 17'h00081,
            srl_code        = 17'h0002f,
            srli_code       = 17'h00089,
            sra_code        = 17'h00030,
            srai_code       = 17'h00091,
            stw_code        = 10'h0a6,  
            sth_code        = 10'h0a5,  
            stb_code        = 10'h0a4,  
            ldw_code        = 10'h0a2,  
            ldh_code        = 10'h0a1,  
            ldb_code        = 10'h0a0,  
            ldhu_code       = 10'h0a9,  
            ldbu_code       = 10'h0a8,  
            beq_code        = 6'h16,    
            bne_code        = 6'h17,    
            blt_code        = 6'h18,    
            bge_code        = 6'h19,    
            bltu_code       = 6'h1a,    
            bgeu_code       = 6'h1b,    
            b_code          = 6'h14,    
            bl_code         = 6'h15,    
            jirl_code       = 6'h13, 
            nop_code        = 32'h0,
            halt_code       = 32'h80000000,   
            add_inst        = 6'h00, 
            addi_inst       = 6'h01,
            sub_inst        = 6'h02,
            lu12i_inst      = 6'h03,
            pcaddu12i_inst  = 6'h04,
            slt_inst        = 6'h05,
            sltu_inst       = 6'h06,
            slti_inst       = 6'h07,
            sltui_inst      = 6'h08,
            and_inst        = 6'h09,
            andi_inst       = 6'h0a,
            or_inst         = 6'h0b,
            ori_inst        = 6'h0c,
            nor_inst        = 6'h0d,
            xor_inst        = 6'h0e,
            xori_inst       = 6'h0f,
            sll_inst        = 6'h10,
            slli_inst       = 6'h11,
            srl_inst        = 6'h12,
            srli_inst       = 6'h13,
            sra_inst        = 6'h14,
            srai_inst       = 6'h15,
            stw_inst        = 6'h16,
            sth_inst        = 6'h17,
            stb_inst        = 6'h18,
            ldw_inst        = 6'h19,
            ldh_inst        = 6'h1a,
            ldb_inst        = 6'h1b,
            ldhu_inst       = 6'h1c,
            ldbu_inst       = 6'h1d,
            beq_inst        = 6'h1e,
            bne_inst        = 6'h1f,
            blt_inst        = 6'h20, 
            bge_inst        = 6'h21, 
            bltu_inst       = 6'h22, 
            bgeu_inst       = 6'h23, 
            b_inst          = 6'h24, 
            bl_inst         = 6'h25, 
            jirl_inst       = 6'h26,
            nop_inst        = 6'h27,
            halt_inst       = 6'h28,
            add_op          = 5'h00,
            addi_op         = 5'h01,
            sub_op          = 5'h02,
            lu12i_op        = 5'h03,
            pcaddu12i_op    = 5'h04,
            slt_op          = 5'h05,
            sltu_op         = 5'h06,
            slti_op         = 5'h07,
            sltui_op        = 5'h08,
            and_op          = 5'h09,
            or_op           = 5'h0a,
            nor_op          = 5'h0b,
            xor_op          = 5'h0c,
            andi_op         = 5'h0d,
            ori_op          = 5'h0e,
            xori_op         = 5'h0f,
            sll_op          = 5'h10,
            srl_op          = 5'h11,
            sra_op          = 5'h12,
            slli_op         = 5'h13,
            srli_op         = 5'h14,
            srai_op         = 5'h15,
            beq_op          = 5'h16,
            bne_op          = 5'h17,
            blt_op          = 5'h18,
            bge_op          = 5'h19,
            bltu_op         = 5'h1a,
            bgeu_op         = 5'h1b,
            bl_op           = 5'h1c,
            jirl_op         = 5'h1d,
            Offset_len      = 6  ,
            Queue_count_len = 4
)

    (
        input clk, rstn,
        //BaseRAM信号
        inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
        output wire[19:0] base_ram_addr, //BaseRAM地址
        output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
        output wire base_ram_ce_n,       //BaseRAM片选，低有效
        output wire base_ram_oe_n,       //BaseRAM读使能，低有效
        output wire base_ram_we_n,       //BaseRAM写使能，低有效

        //ExtRAM信号
        inout wire[31:0] ext_ram_data,  //ExtRAM数据
        output wire[19:0] ext_ram_addr, //ExtRAM地址
        output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
        output wire ext_ram_ce_n,       //ExtRAM片选，低有效
        output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
        output wire ext_ram_we_n        //ExtRAM写使能，低有效
    );

    reg [31:0]  exe_instruction_count;
    wire [31:0] pc;
    wire        load_use_stop;
    reg         load_use_stop_reg;
    //IF_ID
    reg [31:0]  pc_IF_ID;           

    reg [4:0]   rf_src1;
    reg [4:0]   rf_src2;

    wire [5:0]  control_bus;
    wire [4:0]  rj;
    wire [4:0]  rk;
    wire [4:0]  rd;
    wire [31:0] imm;
    wire        mem_read;
    wire        mem_write;
    wire        rf_write;
    wire [31:0] rf_src1_rdata;
    wire [31:0] rf_src2_rdata;
    wire [4:0]  alu_ctrl;
    reg  [Queue_count_len - 1 : 0] task_count;
    reg  [31:0] instruction_queue [0:(1 << Queue_count_len) - 1];
    reg  [31:0] instruction_pc_queue [0:(1 << Queue_count_len) - 1];
    reg  [1:0]  branch_count;

    //ID_EX
    reg [5:0]   control_bus_ID_EX;
    reg [4:0]   rf_src1_ID_EX;
    reg [4:0]   rd_ID_EX;
    reg [4:0]   rf_src2_ID_EX;
    reg [31:0]  pc_ID_EX;
    reg [31:0]  imm_ID_EX;
    reg [31:0]  rf_src1_rdata_ID_EX;
    reg [31:0]  rf_src2_rdata_ID_EX;
    reg         mem_read_ID_EX;
    reg         mem_write_ID_EX;
    reg         rf_we_ID_EX;
    reg [4:0]   alu_ctrl_ID_EX;
    
    reg         branch_enable;
    reg [31:0]  alu_src1, alu_src2;
    wire[31:0]  alu_res;
    wire[31:0]  pc_jump;

    //EX_MEM
    reg [5:0]   control_bus_EX_MEM;
    reg [4:0]   rd_EX_MEM;
    reg [31:0]  alu_res_EX_MEM;
    reg         mem_read_EX_MEM;
    reg         rf_we_EX_MEM;
    reg [31:0]  rf_src2_rdata_EX_MEM;
    reg         mem_write_EX_MEM;
    reg [31:0]  DCache_wdata;

    //MEM_WB, 多加两级流水以适应DCache的结果输出
    reg [5:0]   control_bus_MEM_WB;
    reg [5:0]   control_bus_MEM_WB_pipeline1;
    reg [5:0]   control_bus_MEM_WB_pipeline2;
    reg [31:0]  dmem_rdata_MEM_WB;
    reg [31:0]  alu_res_MEM_WB;
    reg [31:0]  alu_res_MEM_WB_pipeline1;
    reg [31:0]  alu_res_MEM_WB_pipeline2;
    reg         mem_read_MEM_WB;
    reg         mem_read_MEM_WB_pipeline1;
    reg         mem_read_MEM_WB_pipeline2;
    reg         rf_we_MEM_WB;
    reg         rf_we_MEM_WB_pipeline1;
    reg         rf_we_MEM_WB_pipeline2;
    reg [4:0]   rd_MEM_WB;
    reg [4:0]   rd_MEM_WB_pipeline1;
    reg [4:0]   rd_MEM_WB_pipeline2;

    reg [31:0]  rf_wdata;
    wire [31:0] ICache_rdata;
    wire [31:0] DCache_rdata;
    reg         byte_write;
    reg         half_word_write;
    reg         word_write;

    wire [31:0] instruction_pc;
    wire        src2_mux = (control_bus == bne_inst | control_bus == beq_inst | control_bus == blt_inst | control_bus == bge_inst | control_bus == bltu_inst | control_bus == bgeu_inst | control_bus == stb_inst | control_bus == sth_inst | control_bus == stw_inst);
    wire        ICache_miss;
    wire        DCache_miss;
    reg         ICache_miss_reg;
    reg         DCache_miss_reg;
    reg         rf_we_reg;
    reg  [4:0]  writeback_reg;
    reg  [31:0] reg_writeback_data;
    wire [31:0] ICache_addr;
    reg         i_rinterrupt;
    reg         branch_enable_reg;

    wire        task_full;
    wire        fix_flag;

    assign task_full = task_count == (1 << Queue_count_len) - 1;
    assign ICache_addr = branch_enable ? pc_jump : pc;
    assign rf_src1 = rj;
    assign rf_src2 = src2_mux ? rd: rk; 
    assign branch_enable = (((control_bus_ID_EX == beq_inst || control_bus_ID_EX == bge_inst || control_bus_ID_EX == blt_inst || control_bus_ID_EX == bgeu_inst || control_bus_ID_EX == bltu_inst || control_bus_ID_EX == bne_inst) && alu_res[0]) || control_bus_ID_EX == jirl_inst || control_bus_ID_EX == b_inst || control_bus_ID_EX == bl_inst) & !load_use_stop;
    assign byte_write = (control_bus_EX_MEM == stb_inst);
    assign half_word_write = (control_bus_EX_MEM == sth_inst);
    assign word_write = (control_bus_EX_MEM == stw_inst);
    assign i_rinterrupt = branch_enable & ICache_miss & !branch_enable_reg;
    assign load_use_stop = (mem_read_EX_MEM & (rf_src1_ID_EX == rd_EX_MEM | rf_src2_ID_EX == rd_EX_MEM)) | (mem_read_MEM_WB_pipeline1 & (rf_src1_ID_EX == rd_MEM_WB_pipeline1 | rf_src2_ID_EX == rd_MEM_WB_pipeline1)) | (mem_read_MEM_WB_pipeline2 & (rf_src1_ID_EX == rd_MEM_WB_pipeline2 | rf_src2_ID_EX == rd_MEM_WB_pipeline2));
    wire   pc_enable;

    //计算算术逻辑运算结果
    ALU # (
      .add_op(add_op),
      .addi_op(addi_op),
      .sub_op(sub_op),
      .lu12i_op(lu12i_op),
      .pcaddu12i_op(pcaddu12i_op),
      .slt_op(slt_op),
      .sltu_op(sltu_op),
      .slti_op(slti_op),
      .sltui_op(sltui_op),
      .and_op(and_op),
      .or_op(or_op),
      .nor_op(nor_op),
      .xor_op(xor_op),
      .andi_op(andi_op),
      .ori_op(ori_op),
      .xori_op(xori_op),
      .sll_op(sll_op),
      .srl_op(srl_op),
      .sra_op(sra_op),
      .slli_op(slli_op),
      .srli_op(srli_op),
      .srai_op(srai_op),
      .beq_op(beq_op),
      .bne_op(bne_op),
      .blt_op(blt_op),
      .bge_op(bge_op),
      .bltu_op(bltu_op),
      .bgeu_op(bgeu_op),
      .bl_op(bl_op),
      .jirl_op(jirl_op)
    )
    ALU_inst (
      .Op1(alu_src1),
      .Op2(alu_src2),
      .Ctrl(alu_ctrl_ID_EX),
      .alu_res(alu_res)
    );

    //指令地址计数器
    PC  PC_inst (
      .pc_mux(branch_enable),
      .pc_enable(pc_enable),
      .clk(clk),
      .rstn(rstn),
      .address_adder(pc_jump),
      .pc(pc)
    );

    //计算跳转地址
    address_adder  address_adder_inst (
      .pc(pc_ID_EX),
      .imm(imm_ID_EX),
      .control_bus_ID_EX(control_bus_ID_EX),
      .rj_data_ID_EX(rf_src1_rdata_ID_EX),
      .pc_jump(pc_jump)
    );

    register_file # (
      .ADDR_WIDTH(5),
      .DATA_WIDTH(32)
    )
    register_file_inst (
      .clk(clk),
      .ra0(rf_src1),
      .ra1(rf_src2),
      .rd0(rf_src1_rdata),
      .rd1(rf_src2_rdata),
      .wa(rd_MEM_WB),
      .wd(rf_wdata),
      .we(rf_we_MEM_WB)
    );

    Control # (
      .add_inst(add_inst),
      .addi_inst(addi_inst),
      .sub_inst(sub_inst),
      .lu12i_inst(lu12i_inst),
      .pcaddu12i_inst(pcaddu12i_inst),
      .slt_inst(slt_inst),
      .sltu_inst(sltu_inst),
      .slti_inst(slti_inst),
      .sltui_inst(sltui_inst),
      .and_inst(and_inst),
      .andi_inst(andi_inst),
      .or_inst(or_inst),
      .ori_inst(ori_inst),
      .nor_inst(nor_inst),
      .xor_inst(xor_inst),
      .xori_inst(xori_inst),
      .sll_inst(sll_inst),
      .slli_inst(slli_inst),
      .srl_inst(srl_inst),
      .srli_inst(srli_inst),
      .sra_inst(sra_inst),
      .srai_inst(srai_inst),
      .stw_inst(stw_inst),
      .sth_inst(sth_inst),
      .stb_inst(stb_inst),
      .ldw_inst(ldw_inst),
      .ldh_inst(ldh_inst),
      .ldb_inst(ldb_inst),
      .ldhu_inst(ldhu_inst),
      .ldbu_inst(ldbu_inst),
      .beq_inst(beq_inst),
      .bne_inst(bne_inst),
      .blt_inst(blt_inst),
      .bge_inst(bge_inst),
      .bltu_inst(bltu_inst),
      .bgeu_inst(bgeu_inst),
      .b_inst(b_inst),
      .bl_inst(bl_inst),
      .jirl_inst(jirl_inst),
      .nop_inst(nop_inst),
      .add_op(add_op),
      .addi_op(addi_op),
      .sub_op(sub_op),
      .lu12i_op(lu12i_op),
      .pcaddu12i_op(pcaddu12i_op),
      .slt_op(slt_op),
      .sltu_op(sltu_op),
      .slti_op(slti_op),
      .sltui_op(sltui_op),
      .and_op(and_op),
      .or_op(or_op),
      .nor_op(nor_op),
      .xor_op(xor_op),
      .andi_op(andi_op),
      .ori_op(ori_op),
      .xori_op(xori_op),
      .sll_op(sll_op),
      .srl_op(srl_op),
      .sra_op(sra_op),
      .slli_op(slli_op),
      .srli_op(srli_op),
      .srai_op(srai_op),
      .beq_op(beq_op),
      .bne_op(bne_op),
      .blt_op(blt_op),
      .bge_op(bge_op),
      .bltu_op(bltu_op),
      .bgeu_op(bgeu_op),
      .bl_op(bl_op),
      .jirl_op(jirl_op)
    )
    Control_inst (
      .control_bus(control_bus),
      .alu_ctrl(alu_ctrl),
      .mem_read(mem_read),
      .mem_write(mem_write),
      .rf_write(rf_write)
    );

    Decoder # (
      .add_code(add_code),
      .addi_code(addi_code),
      .sub_code(sub_code),
      .lu12i_code(lu12i_code),
      .pcaddu12i_code(pcaddu12i_code),
      .slt_code(slt_code),
      .sltu_code(sltu_code),
      .slti_code(slti_code),
      .sltui_code(sltui_code),
      .and_code(and_code),
      .andi_code(andi_code),
      .or_code(or_code),
      .ori_code(ori_code),
      .nor_code(nor_code),
      .xor_code(xor_code),
      .xori_code(xori_code),
      .sll_code(sll_code),
      .slli_code(slli_code),
      .srl_code(srl_code),
      .srli_code(srli_code),
      .sra_code(sra_code),
      .srai_code(srai_code),
      .stw_code(stw_code),
      .sth_code(sth_code),
      .stb_code(stb_code),
      .ldw_code(ldw_code),
      .ldh_code(ldh_code),
      .ldb_code(ldb_code),
      .ldhu_code(ldhu_code),
      .ldbu_code(ldbu_code),
      .beq_code(beq_code),
      .bne_code(bne_code),
      .blt_code(blt_code),
      .bge_code(bge_code),
      .bltu_code(bltu_code),
      .bgeu_code(bgeu_code),
      .b_code(b_code),
      .bl_code(bl_code),
      .jirl_code(jirl_code),
      .nop_code(nop_code),
      .halt_code(halt_code),
      .add_inst(add_inst),
      .addi_inst(addi_inst),
      .sub_inst(sub_inst),
      .lu12i_inst(lu12i_inst),
      .pcaddu12i_inst(pcaddu12i_inst),
      .slt_inst(slt_inst),
      .sltu_inst(sltu_inst),
      .slti_inst(slti_inst),
      .sltui_inst(sltui_inst),
      .and_inst(and_inst),
      .andi_inst(andi_inst),
      .or_inst(or_inst),
      .ori_inst(ori_inst),
      .nor_inst(nor_inst),
      .xor_inst(xor_inst),
      .xori_inst(xori_inst),
      .sll_inst(sll_inst),
      .slli_inst(slli_inst),
      .srl_inst(srl_inst),
      .srli_inst(srli_inst),
      .sra_inst(sra_inst),
      .srai_inst(srai_inst),
      .stw_inst(stw_inst),
      .sth_inst(sth_inst),
      .stb_inst(stb_inst),
      .ldw_inst(ldw_inst),
      .ldh_inst(ldh_inst),
      .ldb_inst(ldb_inst),
      .ldhu_inst(ldhu_inst),
      .ldbu_inst(ldbu_inst),
      .beq_inst(beq_inst),
      .bne_inst(bne_inst),
      .blt_inst(blt_inst),
      .bge_inst(bge_inst),
      .bltu_inst(bltu_inst),
      .bgeu_inst(bgeu_inst),
      .b_inst(b_inst),
      .bl_inst(bl_inst),
      .jirl_inst(jirl_inst),
      .nop_inst(nop_inst),
      .halt_inst(halt_inst)
    )
    Decoder_inst (
      .Instruction(instruction_queue[0]),  
      .rk(rk),
      .rj(rj),
      .rd(rd),
      .imm(imm),
      .control_bus(control_bus)
    );


    DCache # (
      .Offset_len(Offset_len)
    )
    DCache_inst (
      .clk(clk),
      .rstn(rstn),
      .DCache_wdata(DCache_wdata),  
      .DCache_addr(alu_res_EX_MEM),
      .mem_read(mem_read_EX_MEM),
      .mem_write(mem_write_EX_MEM),
      .d_rready(d_rready),
      .d_wready(d_wready),
      .mem_rdata(mem_rdata),
      .byte_write(byte_write),          
      .half_word_write(half_word_write),
      .word_write(word_write),          
      .mem_read_valid(mem_read_valid),
      .d_rvalid(d_rvalid),
      .d_wvalid(d_wvalid),
      .d_waddr(d_waddr),
      .d_raddr(d_raddr),
      .DCache_rdata(DCache_rdata),
      .DCache_miss_stop(DCache_miss),
      .d_wdata(d_wdata)
    );

    ICache # (
      .Offset_len(Offset_len)
    )
    ICache_inst (
      .clk(clk),
      .rstn(rstn),
      .ICache_addr(ICache_addr),
      .mem_rdata(mem_rdata),
      .branch_enable(branch_enable),
      .i_rready(i_rready),
      .ICache_miss(ICache_miss),
      .ICache_rdata(ICache_rdata),
      .i_addr(i_addr),
      .i_rvalid(i_rvalid),
      .task_full(task_full),
      .instruction_pc(instruction_pc)
    );

    Arbiter # (
      .Offset_len(Offset_len)
    )
    Arbiter_inst (
      .base_ram_data(base_ram_data),
      .base_ram_addr(base_ram_addr),
      .base_ram_be_n(base_ram_be_n),
      .base_ram_ce_n(base_ram_ce_n),
      .base_ram_oe_n(base_ram_oe_n),
      .base_ram_we_n(base_ram_we_n),
      .ext_ram_data(ext_ram_data),
      .ext_ram_addr(ext_ram_addr),
      .ext_ram_be_n(ext_ram_be_n),
      .ext_ram_ce_n(ext_ram_ce_n),
      .ext_ram_oe_n(ext_ram_oe_n),
      .ext_ram_we_n(ext_ram_we_n),
      .clk(clk),
      .rstn(rstn),
      .i_rvalid(i_rvalid),
      .i_addr(i_addr),
      .d_rvalid(d_rvalid),
      .d_wvalid(d_wvalid),
      .d_raddr(d_raddr),
      .d_waddr(d_waddr),
      .d_wdata(d_wdata),
      .mem_rdata(mem_rdata),
      .d_rready(d_rready),
      .d_wready(d_wready),
      .i_rready(i_rready),
      .i_rinterrupt(i_rinterrupt)
    );

    wire i_rvalid;
    wire [31:0] i_addr;
    wire d_rvalid;
    wire d_wvalid;
    wire [31:0] d_waddr;
    wire [31:0] d_raddr;
    wire [(1 << (Offset_len + 3))-1:0] d_wdata;
    wire [(1 << (Offset_len + 3))-1:0] mem_rdata;
    wire d_rready;
    wire d_wready;
    wire i_rready;

    //前递模块
    //alu_src1和alu_src2的选择
    //alu_src1
    always @(*) begin
      if( control_bus_ID_EX == pcaddu12i_inst  |
          control_bus_ID_EX == jirl_inst       |
          control_bus_ID_EX == bl_inst         |
          control_bus_ID_EX == b_inst
        ) 
      begin
        alu_src1 = pc_ID_EX;
      end
      else begin
        if (rf_src1_ID_EX == 0) begin
          alu_src1 = 0;
        end
        else begin          
          if(rf_src1_ID_EX == rd_EX_MEM && rf_we_EX_MEM) begin
            alu_src1 = alu_res_EX_MEM;
          end
          else if(rf_src1_ID_EX == rd_MEM_WB_pipeline1 && !mem_read_MEM_WB_pipeline1 && rf_we_MEM_WB_pipeline1) begin //当数据在DCache对应的流水线上且不是从缓存读出时，为alu计算写回结果
            alu_src1 = alu_res_MEM_WB_pipeline1;
          end
          else if(rf_src1_ID_EX == rd_MEM_WB_pipeline2 && !mem_read_MEM_WB_pipeline2 && rf_we_MEM_WB_pipeline2) begin
            alu_src1 = alu_res_MEM_WB_pipeline2;
          end
          else if(rf_src1_ID_EX == rd_MEM_WB && rf_we_MEM_WB) begin
            alu_src1 = rf_wdata;
          end
          else if(rf_src1_ID_EX == writeback_reg && rf_we_reg) begin
            alu_src1 = reg_writeback_data;
          end
          else begin
            alu_src1 = rf_src1_rdata_ID_EX;
          end
        end
      end
    end

    //alu_src2
    always @(*) begin
        if(   control_bus_ID_EX == addi_inst        |
              control_bus_ID_EX == lu12i_inst       |
              control_bus_ID_EX == pcaddu12i_inst   |
              control_bus_ID_EX == srai_inst        |
              control_bus_ID_EX == slli_inst        |
              control_bus_ID_EX == srli_inst        |
              control_bus_ID_EX == sltui_inst       |
              control_bus_ID_EX == slti_inst        |
              control_bus_ID_EX == andi_inst        |
              control_bus_ID_EX == ori_inst         |
              control_bus_ID_EX == xori_inst        |
              control_bus_ID_EX == b_inst           |
              control_bus_ID_EX == bl_inst          |
              control_bus_ID_EX == jirl_inst        |
              control_bus_ID_EX == stw_inst         |
              control_bus_ID_EX == stb_inst         |
              control_bus_ID_EX == sth_inst         |
              control_bus_ID_EX == ldb_inst         |
              control_bus_ID_EX == ldh_inst         |
              control_bus_ID_EX == ldw_inst         |
              control_bus_ID_EX == ldbu_inst        |
              control_bus_ID_EX == ldhu_inst
          ) 
        begin
          alu_src2 = imm_ID_EX;
        end
        else begin
          if (rf_src2_ID_EX == 0) begin
            alu_src2 = 0;
          end
          else begin          
            if(rf_src2_ID_EX == rd_EX_MEM && rf_we_EX_MEM ) begin
              alu_src2 = alu_res_EX_MEM;
            end
            else if(rf_src2_ID_EX == rd_MEM_WB_pipeline1 && !mem_read_MEM_WB_pipeline1 && rf_we_MEM_WB_pipeline1) begin //当数据在DCache对应的流水线上且不是从缓存读出时，为alu计算写回结果
              alu_src2 = alu_res_MEM_WB_pipeline1;
            end
            else if(rf_src2_ID_EX == rd_MEM_WB_pipeline2 && !mem_read_MEM_WB_pipeline2 && rf_we_MEM_WB_pipeline2) begin
              alu_src2 = alu_res_MEM_WB_pipeline2;
            end
            else if(rf_src2_ID_EX == rd_MEM_WB && rf_we_MEM_WB) begin
              alu_src2 = rf_wdata;
            end
            else if(rf_src2_ID_EX == writeback_reg && rf_we_reg) begin
              alu_src2 = reg_writeback_data;
            end
            else begin
              alu_src2 = rf_src2_rdata_ID_EX;
            end
          end
        end
    end
    
    //rf_wdata
    always @(*) begin
      if(rd_MEM_WB == 0) begin
        rf_wdata = 0;
      end
      else
        if(mem_read_MEM_WB) begin
          case(control_bus_MEM_WB)
            ldw_inst: begin
              rf_wdata = dmem_rdata_MEM_WB;
            end
            ldh_inst:begin
              case(alu_res_MEM_WB[1]) 
                1'b0:   rf_wdata = {{16{dmem_rdata_MEM_WB[15]}},  dmem_rdata_MEM_WB[15:0]};
                1'b1:   rf_wdata = {{16{dmem_rdata_MEM_WB[31]}},  dmem_rdata_MEM_WB[31:16]};
              endcase
            end
            ldb_inst:begin
              case(alu_res_MEM_WB[1:0])
                2'd0:   rf_wdata = {{24{dmem_rdata_MEM_WB[7]}},   dmem_rdata_MEM_WB[7:0]};
                2'd1:   rf_wdata = {{24{dmem_rdata_MEM_WB[15]}},  dmem_rdata_MEM_WB[15:8]};
                2'd2:   rf_wdata = {{24{dmem_rdata_MEM_WB[23]}},  dmem_rdata_MEM_WB[23:16]};
                2'd3:   rf_wdata = {{24{dmem_rdata_MEM_WB[31]}},  dmem_rdata_MEM_WB[31:24]};
              endcase
            end
            ldbu_inst:begin
              case(alu_res_MEM_WB[1:0])
                2'd0:   rf_wdata = {{24{1'b0}}, dmem_rdata_MEM_WB[7:0]};
                2'd1:   rf_wdata = {{24{1'b0}}, dmem_rdata_MEM_WB[15:7]};
                2'd2:   rf_wdata = {{24{1'b0}}, dmem_rdata_MEM_WB[23:16]};
                2'd3:   rf_wdata = {{24{1'b0}}, dmem_rdata_MEM_WB[31:24]};
              endcase
            end
            ldhu_inst:begin
              case(alu_res_MEM_WB[1]) 
                1'b0:   rf_wdata = {{16{1'b0}}, dmem_rdata_MEM_WB[15:0]};
                1'b1:   rf_wdata = {{16{1'b0}}, dmem_rdata_MEM_WB[31:16]};
              endcase
            end
            default: rf_wdata = 0;
          endcase
        end
        else begin
          rf_wdata = alu_res_MEM_WB;
        end
    end
  
    assign pc_enable = (((task_count < (1 << Queue_count_len) - 1) & !ICache_miss) | branch_enable | branch_enable_reg); //在ICache上升沿时迭代

    //ID_EX
    always @(posedge clk) begin
      if(!rstn) begin
        control_bus_ID_EX <= nop_inst;
      end
      else begin
        if(!DCache_miss & !load_use_stop) begin  //命中
          if(task_count == 0 | branch_enable) begin //任务数
            control_bus_ID_EX <= nop_inst;
          end
          else begin  //如果在branch_count不为0时
            control_bus_ID_EX <= control_bus;
          end
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        mem_read_ID_EX <= 0;
      end 
      else begin
        if(!DCache_miss & !load_use_stop) begin
          if(task_count == 0 | branch_enable) begin
            mem_read_ID_EX <= 0;
          end
          else begin
            mem_read_ID_EX <= mem_read;
          end
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        mem_write_ID_EX <= 0;
      end 
      else begin
        if(!DCache_miss & !load_use_stop) begin
          if(task_count == 0 | branch_enable) begin
            mem_write_ID_EX <= 0;
          end
          else begin
            mem_write_ID_EX <= mem_write;
          end
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        rf_src1_ID_EX <= 0;
      end
      else begin
        if(!DCache_miss & !load_use_stop) begin
          if(task_count == 0 | branch_enable) begin
            rf_src1_ID_EX <= 0;
          end
          else begin
            rf_src1_ID_EX <= rf_src1;
          end
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        rf_src2_ID_EX <= 0;
      end
      else begin
        if(!DCache_miss & !load_use_stop) begin
          if(task_count == 0 | branch_enable) begin
            rf_src2_ID_EX <= 0;
          end
          else begin
            rf_src2_ID_EX <= rf_src2;
          end
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        rd_ID_EX <= 0;
      end
      else begin
        if(!DCache_miss & !load_use_stop) begin
          if(task_count == 0 | branch_enable) begin
            rd_ID_EX <= 0;
          end
          else begin
            rd_ID_EX <= rd;
          end
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        imm_ID_EX <= 0;
      end
      else begin
        if(!DCache_miss & !load_use_stop) begin
          if(task_count == 0 | branch_enable) begin
            imm_ID_EX <= 0;
          end
          else begin
            imm_ID_EX <= imm;
          end
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        rf_src1_rdata_ID_EX <= 0;
      end
      else begin
        if(!DCache_miss & !load_use_stop) begin
          if(task_count == 0 | branch_enable) begin
            rf_src1_rdata_ID_EX <= 0;
          end
          else begin
              rf_src1_rdata_ID_EX <= rf_src1_rdata;
          end
        end
        else begin
          if(rf_src1_ID_EX == writeback_reg & rf_we_reg & load_use_stop) begin
            rf_src1_rdata_ID_EX <= reg_writeback_data;
          end
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        rf_src2_rdata_ID_EX <= 0;
      end
      else begin
        if(!DCache_miss & !load_use_stop) begin
          if(task_count == 0 | branch_enable) begin
            rf_src2_rdata_ID_EX <= 0;
          end
          else begin
            rf_src2_rdata_ID_EX <=rf_src2_rdata;
          end
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        rf_we_ID_EX <= 0;
      end
      else begin
        if(!DCache_miss & !load_use_stop) begin
          if(task_count == 0 | branch_enable) begin
            rf_we_ID_EX <= 0;
          end
          else begin
            rf_we_ID_EX <= rf_write;
          end
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        alu_ctrl_ID_EX <= 0;
      end
      else begin
        if(!DCache_miss & !load_use_stop) begin
          if(task_count == 0 | branch_enable) begin
            alu_ctrl_ID_EX <= 0;
          end
          else begin
            alu_ctrl_ID_EX <= alu_ctrl;
          end
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        pc_ID_EX <= 0;
      end
      else begin
        if(!DCache_miss & !load_use_stop) begin
          if(task_count == 0 | branch_enable) begin
            pc_ID_EX <= 0;
          end
          else begin
            pc_ID_EX <= instruction_pc_queue[0]; //有可能DCache_miss了，但是ICache_miss还在取指，导致地址不对应，感觉要像任务队列一样给一个pc队列
          end
        end
      end
    end
    

    //EX_MEM
    always @(posedge clk) begin
      if(!rstn) begin
        control_bus_EX_MEM <= nop_inst;
      end
      else begin
        if(!DCache_miss) begin  //执行跳转指令后，跳转指令和两个阶段的空指令往下流，毕竟跳转指令还是有写入寄存器堆的情况(如bl指令)
          control_bus_EX_MEM <= control_bus_ID_EX;
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        alu_res_EX_MEM <= 0;
      end
      else begin
        if(!DCache_miss) begin
          alu_res_EX_MEM <= alu_res ;
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        mem_read_EX_MEM <= 0;
      end
      else begin
        if(!DCache_miss) begin
          mem_read_EX_MEM <= mem_read_ID_EX;
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        rf_we_EX_MEM <= 0;
      end
      else begin
        if(!DCache_miss) begin
          rf_we_EX_MEM <= rf_we_ID_EX;
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        rd_EX_MEM <= 0;
      end
      else begin
        if(!DCache_miss) begin
          rd_EX_MEM <= rd_ID_EX;
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        rf_src2_rdata_EX_MEM <= 0;
      end
      else begin
        if(!DCache_miss) begin
          rf_src2_rdata_EX_MEM <= rf_src2_rdata_ID_EX;
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        mem_write_EX_MEM <= 0;
      end
      else begin
        if(!DCache_miss) begin
          mem_write_EX_MEM <= mem_write_ID_EX;
        end
      end
    end

    //MEM_WB
    always @(posedge clk) begin
      if(!rstn) begin
        control_bus_MEM_WB <= nop_inst;
        control_bus_MEM_WB_pipeline1 <= nop_inst;
        control_bus_MEM_WB_pipeline2 <= nop_inst;
      end
      else begin
        if(!DCache_miss) begin
          control_bus_MEM_WB_pipeline1 <= control_bus_EX_MEM;
          control_bus_MEM_WB_pipeline2 <= control_bus_MEM_WB_pipeline1;
          control_bus_MEM_WB <= control_bus_MEM_WB_pipeline2;
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        dmem_rdata_MEM_WB <= 0;
      end
      else begin
        if(!DCache_miss) begin
          dmem_rdata_MEM_WB <= DCache_rdata;
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        alu_res_MEM_WB <= 0;
        alu_res_MEM_WB_pipeline1 <= 0;
        alu_res_MEM_WB_pipeline2 <= 0;
      end
      else begin
        if(!DCache_miss) begin
          alu_res_MEM_WB_pipeline1 <= alu_res_EX_MEM;
          alu_res_MEM_WB_pipeline2 <= alu_res_MEM_WB_pipeline1;
          alu_res_MEM_WB <= alu_res_MEM_WB_pipeline2;
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        mem_read_MEM_WB <= 0;
        mem_read_MEM_WB_pipeline1 <= 0;
        mem_read_MEM_WB_pipeline2 <= 0;
      end
      else begin
        if(!DCache_miss) begin
          mem_read_MEM_WB_pipeline1 <= mem_read_EX_MEM;
          mem_read_MEM_WB_pipeline2 <= mem_read_MEM_WB_pipeline1;
          mem_read_MEM_WB <= mem_read_MEM_WB_pipeline2;
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        rf_we_MEM_WB <= 0;
        rf_we_MEM_WB_pipeline1 <= 0;
        rf_we_MEM_WB_pipeline2 <= 0;
      end
      else begin
        if(!DCache_miss) begin
          rf_we_MEM_WB_pipeline1 <= rf_we_EX_MEM;
          rf_we_MEM_WB_pipeline2 <= rf_we_MEM_WB_pipeline1;
          rf_we_MEM_WB <= rf_we_MEM_WB_pipeline2;
        end
      end
    end

    always @(posedge clk) begin
      if(!rstn) begin
        rd_MEM_WB <= 0;
        rd_MEM_WB_pipeline1 <= 0;
        rd_MEM_WB_pipeline2 <= 0;
      end
      else begin
        if(!DCache_miss) begin
          rd_MEM_WB_pipeline1 <= rd_EX_MEM;
          rd_MEM_WB_pipeline2 <= rd_MEM_WB_pipeline1;
          rd_MEM_WB <= rd_MEM_WB_pipeline2;
        end
      end
    end   

    always @(posedge clk) begin
      if(!rstn | (branch_enable & !load_use_stop)) begin
        task_count <= 0;
      end
      else begin
        if(~|branch_count) begin
          if(task_count == 0 & !ICache_miss & ~|branch_count) begin  
            task_count <= 1;
          end
          else if(task_count == (1 << Queue_count_len) - 1 && !DCache_miss & !load_use_stop) begin
            task_count <= task_count - 1;
          end
          else if((!ICache_miss & !DCache_miss & !load_use_stop) | (ICache_miss & load_use_stop & !DCache_miss)) begin
            task_count <= task_count;
          end
          else if(ICache_miss & !DCache_miss & !load_use_stop) begin
            if(task_count > 0) begin
              task_count <= task_count - 1;
            end
          end
          else if(!ICache_miss & (DCache_miss | (!DCache_miss & DCache_miss_reg) | load_use_stop) & ~|branch_count) begin
            if(task_count < (1 << Queue_count_len) - 1) begin
              task_count <= task_count + 1;
            end
          end 
          
        end
      end
    end

    always @(posedge clk) begin //下降沿不该更新
      integer i;
      if(!rstn | (branch_enable & !load_use_stop)) begin
        for(i = 0; i < (1 << Queue_count_len); i++) begin
          instruction_queue[i] <= 0;
        end
      end
      else begin
        if(!ICache_miss & task_count == 0) begin
          instruction_queue[task_count] <= ICache_rdata;
        end
        else if(!ICache_miss & !DCache_miss & !load_use_stop) begin 
          for(i = 0; i < task_count - 1; i++) begin
            instruction_queue[i] <= instruction_queue[i + 1];
          end
          instruction_queue[task_count - 1] <= ICache_rdata;
        end
        else if(ICache_miss & !DCache_miss & !load_use_stop) begin //ICache_miss 
          if(task_count > 0) begin
            for(i = 0; i < task_count - 1; i++) begin
              instruction_queue[i] <= instruction_queue[i + 1];
            end
          end
        end
        else if(!ICache_miss & (DCache_miss | (!DCache_miss & DCache_miss_reg) | load_use_stop) & ~|branch_count) begin
          if(task_count < (1 << Queue_count_len) - 1) begin
            instruction_queue[task_count] <= ICache_rdata;
          end
        end
      end
    end
    
    always @(posedge clk) begin
      integer i;
      if(!rstn | (branch_enable & !load_use_stop)) begin     //branch时丢弃延迟槽所有的指令对应的pc
        for(i = 0; i < (1 << Queue_count_len); i++) begin
          instruction_pc_queue[i] <= 0;
        end
      end
      else begin
        if(!ICache_miss & task_count == 0) begin
          instruction_pc_queue[task_count] <= instruction_pc;
        end
        else if(!ICache_miss & !DCache_miss & !load_use_stop) begin 
          for(i = 0; i < task_count - 1; i++) begin
            instruction_pc_queue[i] <= instruction_pc_queue[i + 1];
          end
          instruction_pc_queue[task_count - 1] <= instruction_pc;
        end
        else if(ICache_miss & !DCache_miss & !load_use_stop) begin //ICache_miss 
          if(task_count > 0) begin
            for(i = 0; i < task_count - 1; i++) begin
              instruction_pc_queue[i] <= instruction_pc_queue[i + 1];
            end
          end
        end
        else if(!ICache_miss & (DCache_miss | (!DCache_miss & DCache_miss_reg) | load_use_stop)) begin
          if(task_count < (1 << Queue_count_len) - 1) begin
            instruction_pc_queue[task_count] <= instruction_pc;
          end
        end
      end
    end

    always @(posedge clk) begin
      ICache_miss_reg <= ICache_miss;
      DCache_miss_reg <= DCache_miss;
    end

    always @(posedge clk) begin
      reg_writeback_data <= rf_wdata;
    end

    always @(posedge clk) begin
      writeback_reg <= rd_MEM_WB;
    end

    always @(posedge clk) begin
      if(!rstn) begin
        branch_count <= 0;
      end
      else begin
        if(branch_enable) begin
          branch_count <= 2'd1;
        end
        else begin
          if(|branch_count) begin
            branch_count <= branch_count - 1;
          end
        end 
      end
    end

    always @(posedge clk) begin
      rf_we_reg <= rf_we_MEM_WB;
    end

    //考虑写入数据存储器的数据相关
    always @(posedge clk) begin
      if(!rstn) begin
          DCache_wdata <= 0;
      end
      else begin
          if(rd_ID_EX == rd_EX_MEM && rf_we_EX_MEM) begin
            DCache_wdata <= alu_res_EX_MEM;
          end
          else if(rd_ID_EX == rd_MEM_WB_pipeline1 && rf_we_MEM_WB_pipeline1) begin
            DCache_wdata <= alu_res_MEM_WB_pipeline1;
          end
          else if(rd_ID_EX == rd_MEM_WB_pipeline2 && rf_we_MEM_WB_pipeline2) begin
            DCache_wdata <= alu_res_MEM_WB_pipeline2;
          end
          else if(rd_ID_EX == rd_MEM_WB && rf_we_MEM_WB) begin
            DCache_wdata <= alu_res_MEM_WB;
          end
          else if(rd_ID_EX == writeback_reg && rf_we_reg) begin
            DCache_wdata <= reg_writeback_data;
          end
          else begin
            DCache_wdata <= rf_src2_rdata_ID_EX;
          end
      end
  end

  always @(posedge clk) begin
    branch_enable_reg <= branch_enable;
  end

  always @(posedge clk) begin
    load_use_stop_reg <= load_use_stop;
  end

  always @(posedge clk) begin
    if(!rstn) begin
      exe_instruction_count <= 0;
    end
    else begin
      if(control_bus_MEM_WB != nop_inst) begin
        exe_instruction_count <= exe_instruction_count + 1;
      end
    end
  end
  endmodule
