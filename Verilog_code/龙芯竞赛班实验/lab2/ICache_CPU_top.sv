
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/10 17:01:31
// Design Name: 
// Module Name: Cache_CPU_top
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


module Cache_CPU_top#(parameter add_code        = 17'h00020,
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
                halt_code       = 32'h80000000,
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
                add_op          = 5'h0,
                addi_op         = 5'h1,
                sub_op          = 5'h2,
                lu12i_op        = 5'h3,
                pcaddu12i_op    = 5'h4,
                slt_op          = 5'h5,
                sltu_op         = 5'h6,
                slti_op         = 5'h7,
                sltui_op        = 5'h8,
                and_op          = 5'h9,
                or_op           = 5'ha,
                nor_op          = 5'hb,
                xor_op          = 5'hc,
                andi_op         = 5'hd,
                ori_op          = 5'he,
                xori_op         = 5'hf,
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
                ADDR_WIDTH      = 5, 
                DATA_WIDTH      = 32,
                branch_beq      = 3'h1,
                branch_bne      = 3'h2,
                branch_blt      = 3'h3,
                branch_bge      = 3'h4,
                branch_bltu     = 3'h5,
                branch_bgeu     = 3'h6,
                branch_direct   = 3'h7 )
    (
        input clk, rstn
    );
    
    reg                     valid;
    //PC
    wire                    pc_mux;
    wire                    pc_enable;
    wire    [31:0]          address_adder;
    wire    [31:0]          pc;
    
    //Decoder
    reg     [31:0]          Instruction_IF_ID;
    wire    [31:0]          Instruction_IF ;
    wire    [4:0]           rk;
    wire    [4:0]           rj;
    wire    [4:0]           rd;
    wire    [5:0]           control_bus;
    reg     [5:0]           control_bus_ID_EX;
    //register_file
    wire [DATA_WIDTH -1:0]  rd0;
    wire [DATA_WIDTH -1:0]  rd1;
  
    //Imm_gen
    wire [31:0]             imm;
    wire [31:0]             pc_jump;

    //Branch
    wire [2:0]              branch_type;
    wire [31:0]             alu_res;
    wire                    branch_enable;
    
    //Alu
    wire [31:0]             Op1;
    wire [31:0]             Op2;
    wire [4:0]              Ctrl;

    //Control
    wire [4:0]              alu_ctrl;
    wire                    mem_read;
    wire                    mem_write;
    wire                    mem_to_reg;
    wire                    alu_src1;
    wire                    alu_src2;
    wire                    rf_write;
  
    //ForwardUnit
    reg  [4:0]              rd_ID_EX;

    wire [1:0]              afwd;
    wire [1:0]              bfwd;
  
    //HazardUnit
    reg                     mem_read_ID_EX;
    wire                    fStall;
    wire                    eFlush;
    
    wire [31:0]             mem_read_data;
    reg  [31:0]             pipe_pc_IF_ID;
    reg  [31:0]             pipe_pc_ID_EX;
    reg                     branch_enable_IF;
    
    //ID_EX
    reg  [31:0]             rj_data_ID_EX;
    reg  [31:0]             rk_data_ID_EX;
    reg  [4:0]              rj_ID_EX;
    reg  [4:0]              rk_ID_EX;
    reg                     mem_write_ID_EX;
    reg                     mem_to_reg_ID_EX;
    reg  [4:0]              alu_ctrl_ID_EX;
    reg                     writeback_ID_EX;
    reg                     alu_src1_ID_EX;
    reg                     alu_src2_ID_EX;
    reg  [31:0]             imm_ID_EX;
    //EX_MEM
    reg                     mem_write_EX_MEM;
    reg                     mem_to_reg_EX_MEM;
    reg                     writeback_EX_MEM;
    reg  [31:0]             alu_res_EX_MEM;
    reg                     mem_read_EX_MEM;
    reg  [4:0]              rd_EX_MEM;
    reg  [31:0]             mem_write_data_EX_MEM;
    reg  [5:0]              control_bus_EX_MEM;
    //MEM_WB
    reg                     writeback_MEM_WB;
    reg  [31:0]             alu_res_MEM_WB;
    reg  [4:0]              rd_MEM_WB;
    reg  [31:0]             wb_reg_data;        //记录需要使用的数据在下个时钟上升沿才存入寄存器堆的数据
    reg                     reg_written;        //进行了寄存器堆的写，下个周期数据将更新
    reg  [4:0]              last_written_reg;   //记录上一个写入的寄存器
    reg  [31:0]             wb_data_mux;
    reg  [31:0]             mem_read_data_reg;
    wire [4:0]              ra1       = (control_bus == bne_inst | control_bus == beq_inst | control_bus == blt_inst | control_bus == bge_inst | control_bus == bltu_inst | control_bus == bgeu_inst | control_bus == stb_inst | control_bus == sth_inst | control_bus == stw_inst) ? rd          : rk; 
    wire [4:0]              rs2_ID_EX = (control_bus_ID_EX == bne_inst | control_bus_ID_EX == beq_inst | control_bus_ID_EX == blt_inst | control_bus_ID_EX == bge_inst | control_bus_ID_EX == bltu_inst | control_bus_ID_EX == bgeu_inst) ? rd_ID_EX    : rk_ID_EX; 
    reg  [2:0]              branch_type_ID_EX;
    reg                     mem_to_reg_MEM_WB ;
    reg  [5:0]              control_bus_MEM_WB;
    reg  [31:0]             mem_write_data;
    reg                     init;
    wire                    ICache_ready;
    reg                     ICache_ready_reg;
    // reg  [1:0]              branch_count;
    assign                  Ctrl = alu_ctrl_ID_EX;
    assign                  pc_mux = branch_enable;
    
    // always @(posedge clk) begin
    //     if(!rstn) begin
    //         branch_count <= 0;
    //     end
    //     else begin
    //         if(branch_enable) begin
    //             branch_count <= 2;
    //         end
    //         else if(|branch_count)begin
    //             branch_count <= branch_count - 1;
    //         end
    //     end
    // end
    
    //pc计算完需要对指令Flush
    address_adder  address_adder_inst (
        .pc(pipe_pc_ID_EX),
        .imm(imm_ID_EX),
        .control_bus_ID_EX(control_bus_ID_EX),
        .rj_data_ID_EX(rj_data_ID_EX),
        .pc_jump(pc_jump)
    );

    data_memory  data_memory_inst (
        .a(alu_res_EX_MEM[15:0] & 16'hfffc),//低两位不看
        .d(mem_write_data),
        .clk(clk),
        .we(mem_write_EX_MEM),
        .spo(mem_read_data)
    );

    I_Cache  I_Cache_inst (
        .read_address(pc),
        .clk(clk),
        .rstn(rstn),
        .valid(valid),
        .branch(branch_enable),
        .read_instruction(Instruction_IF),
        .ICache_ready(ICache_ready)
    );

    PC  PC_inst (
        .pc_mux(pc_mux),
        .pc_enable(pc_enable),
        .clk(clk),
        .rstn(rstn),
        .address_adder(address_adder),
        .pc(pc)
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
        .nop_inst(nop_inst)
    )
    Decoder_inst (
        .Instruction(Instruction_IF_ID),
        .rk(rk),
        .rj(rj),
        .rd(rd),
        .control_bus(control_bus)
    );
    
    register_file # (
        .ADDR_WIDTH(5),
        .DATA_WIDTH(32)
    )
    register_file_inst (
        .clk(clk),
        .ra0(rj),
        .ra1(ra1),
        .rd0(rd0),
        .rd1(rd1),
        .wa(rd_MEM_WB),
        .wd(wb_data_mux),
        .we(writeback_MEM_WB)
    );
    //写延迟可能导致数据相关冲突

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
        .jirl_op(jirl_op),
        .branch_beq(branch_beq),
        .branch_bne(branch_bne),
        .branch_blt(branch_blt),
        .branch_bge(branch_bge),
        .branch_bltu(branch_bltu),
        .branch_bgeu(branch_bgeu),
        .branch_direct(branch_direct)
    )
    Control_inst (
        .control_bus(control_bus),
        .branch_enable(branch_enable),
        .alu_ctrl(alu_ctrl),
        .branch_type(branch_type),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src1(alu_src1),
        .alu_src2(alu_src2),
        .rf_write(rf_write)
    );

    ForwardingUnit  ForwardingUnit_inst (
        .rs1_ID_EX(rj_ID_EX),
        .rs2_ID_EX(rs2_ID_EX),
        .rd_EX_MEM(rd_EX_MEM),
        .rd_MEM_WB(rd_MEM_WB),
        .writeback_EX_MEM(writeback_EX_MEM),
        .writeback_MEM_WB(writeback_MEM_WB),
        .afwd(afwd),
        .bfwd(bfwd)
    );

    HazardUnit  HazardUnit_inst (
        .rs1_ID(rj),
        .rs2_ID(rk),
        .rd_ID_EX(rd_ID_EX),
        .mem_read_ID_EX(mem_read_ID_EX),
        .fStall(fStall),
        .dStall(dStall),
        .eFlush(eFlush)
    );

    
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
        .Op1(Op1),
        .Op2(Op2),
        .Ctrl(Ctrl),
        .alu_res(alu_res)
    );
    imm_gen # (
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
        .jirl_inst(jirl_inst)
    )
    imm_gen_inst (
        .control_bus(control_bus),
        .instruction(Instruction_IF_ID),
        .imm(imm)
    );


    Branch # (
        .branch_beq(branch_beq),
        .branch_bne(branch_bne),
        .branch_blt(branch_blt),
        .branch_bge(branch_bge),
        .branch_bltu(branch_bltu),
        .branch_bgeu(branch_bgeu),
        .branch_direct(branch_direct)
    )
    Branch_inst (
      .control_bus_ID_EX(control_bus_ID_EX),
      .branch_type(branch_type_ID_EX),
      .alu_res(alu_res[0]),
      .branch_enable(branch_enable)
    );

    //PC
    assign pc_enable = ~fStall & (ICache_ready & ~ICache_ready_reg | branch_enable);
    assign address_adder = pc_jump; 

    //Decoder 
    always @(posedge clk) begin
        if(!rstn) begin
            Instruction_IF_ID <= 0;
        end
        else begin
            if(!fStall)
                if(valid & ICache_ready & ~ICache_ready_reg)
                    Instruction_IF_ID <= Instruction_IF;
            else begin
                Instruction_IF_ID <= 0;                 //等待取指的过程为nop指令
            end     
        end
    end

    //pipe_pc_IF_ID
    always @(posedge clk) begin
        if(!rstn) begin
            pipe_pc_IF_ID <= 0;
        end
        else begin
            if(~fStall) begin
                pipe_pc_IF_ID <= pc ;
            end
            if(branch_enable) begin
                pipe_pc_IF_ID <= pc_jump + 4;
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            branch_enable_IF <= 0;
        end
        else begin
            branch_enable_IF <= branch_enable;
        end
    end

    //ID/EX
    always @(posedge clk) begin
        if(!rstn || branch_enable) begin
            imm_ID_EX <= 0;
        end
        else begin
            imm_ID_EX <= imm;
        end
    end

    always @(posedge clk) begin
        if(!rstn || branch_enable) begin
            alu_src1_ID_EX <= 0;
        end
        else begin
            alu_src1_ID_EX <= alu_src1;
        end
    end

    always @(posedge clk) begin
        if(!rstn || branch_enable) begin
            alu_src2_ID_EX <= 0;
        end
        else begin
            alu_src2_ID_EX <= alu_src2;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            pipe_pc_ID_EX <= 0;
        end
        else begin
            pipe_pc_ID_EX <= branch_enable ? address_adder : pipe_pc_IF_ID;
        end
    end

    always @(posedge clk) begin
        if(!rstn || branch_enable) begin
            rd_ID_EX <= 0;
        end
        else begin
            rd_ID_EX <= rd;
        end
    end

    always @(posedge clk) begin
        if(!rstn || branch_enable) begin
            rj_data_ID_EX <= 0;
        end
        else begin
            rj_data_ID_EX <= rd0;
        end
    end

    always @(posedge clk) begin
        if(!rstn || branch_enable) begin
            rk_data_ID_EX <= 0;
        end
        else begin
            rk_data_ID_EX <= rd1;
        end
    end

    always @(posedge clk) begin
        if(!rstn || branch_enable) begin
            rj_ID_EX <= 0;
        end
        else begin
            rj_ID_EX <= rj;
        end
    end

    always @(posedge clk) begin
        if(!rstn || branch_enable) begin
            rk_ID_EX <= 0;
        end
        else begin
            rk_ID_EX <= rk;
        end
    end

    always @(posedge clk) begin
        if(!rstn || eFlush || branch_enable) begin
            mem_read_ID_EX <= 0;
        end
        else begin
            mem_read_ID_EX <= mem_read;
        end
    end

    always @(posedge clk) begin
        if(!rstn || eFlush || branch_enable) begin
            mem_write_ID_EX <= 0;
        end
        else begin
            mem_write_ID_EX <= mem_write;
        end
    end

    always @(posedge clk) begin
        if(!rstn || branch_enable) begin
            mem_to_reg_ID_EX <= 0;
        end
        else begin
            mem_to_reg_ID_EX <= mem_to_reg;
        end
    end

    always @(posedge clk) begin
        if(!rstn || eFlush || branch_enable) begin
            writeback_ID_EX <= 0;
        end
        else begin
            writeback_ID_EX <= rf_write;
        end
    end

    always @(posedge clk) begin
        if(!rstn || eFlush || branch_enable) begin
            alu_ctrl_ID_EX <= 0;
        end
        else begin
            alu_ctrl_ID_EX <= alu_ctrl;
        end
    end

    always @(posedge clk) begin
        if(!rstn || branch_enable) begin
            branch_type_ID_EX <= 0;
        end
        else begin
            branch_type_ID_EX <= branch_type;
        end
    end

    always @(posedge clk) begin
        if( !rstn | branch_enable | (branch_enable_IF) | fStall) begin
            control_bus_ID_EX <= 6'h27;
        end
        else begin
            control_bus_ID_EX <= control_bus;
        end
    end
    //EX/MEM
    always @(posedge clk) begin
        if(!rstn) begin
            writeback_EX_MEM <= 0;
        end
        else begin
            if(control_bus_ID_EX == 6'h27)
                writeback_EX_MEM <= 0;
            else 
                writeback_EX_MEM <= writeback_ID_EX;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            mem_read_EX_MEM <= 0;
        end
        else begin
            mem_read_EX_MEM <= mem_read_ID_EX;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            mem_to_reg_EX_MEM <= 0;
        end
        else begin
            mem_to_reg_EX_MEM <= mem_to_reg_ID_EX;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            mem_write_EX_MEM <= 0;
        end
        else begin
            mem_write_EX_MEM <= mem_write_ID_EX;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            rd_EX_MEM <= 0;
        end
        else begin
            rd_EX_MEM <= rd_ID_EX;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            alu_res_EX_MEM <= 0;
        end
        else begin
            alu_res_EX_MEM <= alu_res;
        end
    end

    //考虑写入数据存储器的数据相关
    always @(posedge clk) begin
        if(!rstn) begin
            mem_write_data_EX_MEM <= 0;
        end
        else begin
            if(rd_ID_EX == rd_EX_MEM) begin
                mem_write_data_EX_MEM <= alu_res_EX_MEM;
            end
            else if(rd_ID_EX == rd_MEM_WB) begin
                mem_write_data_EX_MEM <= alu_res_MEM_WB;
            end
            else if(rd_ID_EX == last_written_reg) begin
                mem_write_data_EX_MEM <= wb_reg_data;
            end
            else begin
                mem_write_data_EX_MEM <= rk_data_ID_EX;
            end
        end
    end

    
    always @(posedge clk) begin
        if(!rstn) begin
            control_bus_EX_MEM <= 6'h27;
        end
        else begin
            control_bus_EX_MEM <= control_bus_ID_EX;
        end
    end

    //MEM/WB
    always @(posedge clk) begin
        if(!rstn) begin
            rd_MEM_WB <= 0;
        end
        else begin
            rd_MEM_WB <= rd_EX_MEM;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            writeback_MEM_WB <= 0;
        end
        else begin 
            writeback_MEM_WB <= writeback_EX_MEM;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            alu_res_MEM_WB <= 0;
        end
        else begin
            alu_res_MEM_WB <= alu_res_EX_MEM;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            wb_reg_data <= 0;
        end
        else begin
            wb_reg_data <= wb_data_mux;
        end
    end
    
    always @(posedge clk) begin
        if(!rstn) begin
            reg_written <= 0;
        end
        else begin
            reg_written <= writeback_MEM_WB;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            last_written_reg <= 0;
        end
        else begin
            last_written_reg <= rd_MEM_WB;
        end
    end    

    always @(posedge clk) begin
        if(!rstn) begin
            mem_to_reg_MEM_WB <= 0;
        end
        else begin
            mem_to_reg_MEM_WB <= mem_to_reg_EX_MEM;
        end
    end
    
    always @(posedge clk) begin
        if(!rstn) begin
            control_bus_MEM_WB <= nop_inst;
        end
        else begin
            control_bus_MEM_WB <= control_bus_EX_MEM;
        end
    end
    always @(*) begin
        if(mem_to_reg_MEM_WB) begin
            case(control_bus_MEM_WB) 
                ldw_inst:
                    wb_data_mux = mem_read_data_reg;
                ldh_inst: begin
                    case(alu_res_MEM_WB[1]) 
                        1'b0: wb_data_mux = {{16{mem_read_data_reg[15]}},mem_read_data_reg[15:0]};
                        1'b1: wb_data_mux = {{16{mem_read_data_reg[31]}},mem_read_data_reg[31:16]};
                    endcase
                end
                ldb_inst: begin
                    case(alu_res_MEM_WB[1:0])
                        2'd0:   wb_data_mux = {{24{mem_read_data_reg[7]}},mem_read_data_reg[7:0]};
                        2'd1:   wb_data_mux = {{24{mem_read_data_reg[15]}},mem_read_data_reg[15:8]};
                        2'd2:   wb_data_mux = {{24{mem_read_data_reg[23]}},mem_read_data_reg[23:16]};
                        2'd3:   wb_data_mux = {{24{mem_read_data_reg[31]}},mem_read_data_reg[31:24]};
                    endcase
                end
                ldbu_inst: begin
                    case(alu_res_MEM_WB[1:0])
                        2'd0:   wb_data_mux = {{24{1'b0}},mem_read_data_reg[7:0]};
                        2'd1:   wb_data_mux = {{24{1'b0}},mem_read_data_reg[15:7]};
                        2'd2:   wb_data_mux = {{24{1'b0}},mem_read_data_reg[23:16]};
                        2'd3:   wb_data_mux = {{24{1'b0}},mem_read_data_reg[31:24]};
                    endcase
                end
                ldhu_inst:  begin
                    case(alu_res_MEM_WB[1]) 
                        1'b0: wb_data_mux = {{16{1'b0}},mem_read_data_reg[15:0]};
                        1'b1: wb_data_mux = {{16{1'b0}},mem_read_data_reg[31:16]};
                    endcase
                end
                default: wb_data_mux = 0;
            endcase
        end
        else begin
            wb_data_mux = alu_res_MEM_WB;
        end
    end
    always @(*) begin
        if(mem_write_EX_MEM) begin
            case(control_bus_EX_MEM)
                stw_inst: begin
                    mem_write_data = mem_write_data_EX_MEM;
                end
                stb_inst: begin
                    case(alu_res_EX_MEM[1:0]) 
                        2'd0:   mem_write_data = {mem_read_data[31:8],  mem_write_data_EX_MEM[7:0]};
                        2'd1:   mem_write_data = {mem_read_data[31:16], mem_write_data_EX_MEM[7:0], mem_read_data[7:0]};
                        2'd2:   mem_write_data = {mem_read_data[31:24], mem_write_data_EX_MEM[7:0], mem_read_data[15:0]};
                        2'd3:   mem_write_data = {mem_write_data_EX_MEM[7:0], mem_read_data[23:0]};
                    endcase
                end
                sth_inst: begin
                    case(alu_res_EX_MEM[1]) 
                        1'b0:  mem_write_data = {mem_read_data[31:16], mem_write_data_EX_MEM[15:0]};
                        1'b1:  mem_write_data = {mem_write_data_EX_MEM[15:0], mem_read_data[15:0]};
                    endcase
                end
                default : mem_write_data = 0;
            endcase
        end
        else begin
            mem_write_data = 0;
        end
    end
    always @(posedge clk) begin
        mem_read_data_reg <= mem_read_data;
    end

    always @(posedge clk) begin
        ICache_ready_reg <= ICache_ready;
    end
    always @(posedge clk) begin
        if(!rstn) begin
            valid <= 0;
        end
        else begin
            if(!init) begin     //未初始化，则valid初始化
                valid <= 1;
            end
            if(ICache_ready & ~ICache_ready_reg) begin
                valid <= 0;
            end
            else begin
                valid <= 1;
            end
        end
    end
    
    always @(posedge clk) begin
        if(!rstn) begin
            init <= 0;
        end
        else if(!valid) begin
            init <= 1;
        end
    end
    //Alu
    assign Op1 =    alu_src1_ID_EX ?  pipe_pc_ID_EX
                    : 
                    (   reg_written & last_written_reg == rj_ID_EX & rd_MEM_WB != rj_ID_EX ?
                        wb_reg_data :
                        ({32{afwd == 2'd0}} & rj_data_ID_EX) |
                        ({32{afwd == 2'd1}} & wb_data_mux  ) |
                        ({32{afwd == 2'd2}} & alu_res_EX_MEM)
                    )
                    ;
    assign Op2 =    alu_src2_ID_EX ?  imm_ID_EX
                    :  
                    (   reg_written & last_written_reg == rs2_ID_EX & rd_MEM_WB != rs2_ID_EX ?
                        wb_reg_data :
                        ({32{bfwd == 2'd0}} & rk_data_ID_EX) |
                        ({32{bfwd == 2'd1}} & wb_data_mux  ) |
                        ({32{bfwd == 2'd2}} & alu_res_EX_MEM)
                    );

    
endmodule
