`timescale 1ns / 1ps

`define IDLE 2'b0
`define MISS 2'b1
`define REFILL 2'b10
`define WAIT 2'b11

module ICache
    #(parameter Offset_len = 6)
    (
        input                                       clk, rstn,
        input      [31:0]                           ICache_addr,
        input      [(1 << (3 + Offset_len)) - 1:0]  mem_rdata,
        input                                       i_rready,
        input                                       branch_enable,
        input                                       task_full,
        output reg                                  ICache_miss,
        output reg [31:0]                           ICache_rdata,
        output reg [31:0]                           i_addr,
        output reg                                  i_rvalid,
        output reg [31:0]                           instruction_pc
    );

    //容量为8KB, 两路组相连，每路4KB = 2^(Offset_len-2) 字 * 2^(12 - Offset_len)
    //address: [     31:12      |    11:Offset_len    |    Offset_len - 1:0    ]
    //                Tag                index                   offset
    reg  [31:0]                             ICache_miss_count;
    reg  [31:0]                             ICache_addr_reg;        
    reg  [31:0]                             ICache_addr_reg0;                       
    reg  [1:0]                              state ;
    wire [11 - Offset_len:0]                index = ICache_addr[11:Offset_len];
    wire [Offset_len - 1:0]                 offset_reg = ICache_addr_reg[Offset_len - 1:0];
    wire [11 - Offset_len:0]                index_reg;
    wire [19:0]                             tag_reg = ICache_addr_reg[31:12];
    reg                                     tag1_we, tag2_we;
    wire [19:0]                             tag1, tag2;
    reg  [19:0]                             tag1_reg, tag2_reg;
    reg  [1:0]                              hit;
    wire [(1 << (3 + Offset_len)) - 1:0]    way1_rdata;
    wire [(1 << (3 + Offset_len)) - 1:0]    way2_rdata;
    wire [31:0]                             mux_mem_rdata;
    reg  [31:0]                             mux_output_data;
    reg                                     way1_we;
    reg                                     way2_we;
    reg                                     i_rready_reg;

    wire                                    mem_read_finish = i_rready & !i_rready_reg;
    reg                                     flush_count;
    reg  [(1 << (12 - Offset_len))- 1:0]    last_used_way;
    reg  [(1 << (3 + Offset_len)) - 1  :0]  way1_rdata_reg, way2_rdata_reg;
    wire [11 - Offset_len: 0]               mux_addr;
    reg                                     branch_enable_reg;
    reg                                     branch_enable_reg2;                       
    reg [(1 << (3 + Offset_len)) - 1:0]     way1_rdata_task_full_restore;
    reg [(1 << (3 + Offset_len)) - 1:0]     way2_rdata_task_full_restore;
    reg [19:0]                              tag1_task_full_restore;
    reg [19:0]                              tag2_task_full_restore;
    reg                                     task_full_reg;
    reg [19:0]                              miss_store_tag1_reg;
    reg [19:0]                              miss_store_tag2_reg;
    reg                                     data_restore;
    reg                                     ICache_miss_reg;
    reg [(1 << (3 + Offset_len)) - 1:0]     i_mem_rdata;              
    assign ICache_miss = ~|hit;                                 //当不处于流水线清洗时才有可能是命中 
    assign i_addr = ICache_addr_reg & 32'hffffffc0;   
    assign hit = {tag2_reg == tag_reg, tag1_reg == tag_reg};    //当输入的branch_enable生效时，令其相等？
    assign mux_addr = ICache_miss & !branch_enable & !branch_enable_reg ? ICache_addr_reg[11:Offset_len]: index; 
    assign index_reg = ICache_addr_reg[11 : Offset_len];
    assign instruction_pc = ICache_addr_reg;

    always @(posedge clk) begin
        if(!rstn) begin
            ICache_miss_count <= 0;
        end
        else begin
            if(state == `REFILL ) begin
                ICache_miss_count <= ICache_miss_count + 1;
            end
        end
    end

    ICache_single_port_bram # (     //写优先块式存储器
        .RAM_WIDTH(1 << (Offset_len + 3)),
        .RAM_DEPTH(1 << (12 - Offset_len))
    )
    way1 (
        .addra(mux_addr),   //[11 - Offset_len              :0]
        .dina(i_mem_rdata),   //[(1 << (3 + Offset_len)) - 1  :0]
        .clka(clk),
        .wea(way1_we),      
        .douta(way1_rdata)  //[(1 << (3 + Offset_len)) - 1  :0]
    );

    ICache_single_port_bram # (     //写优先块式存储器
        .RAM_WIDTH(1 << (Offset_len + 3)),
        .RAM_DEPTH(1 << (12 - Offset_len))
    )
    way2 (
        .addra(mux_addr),   //[11 - Offset_len              :0]
        .dina(i_mem_rdata),   //[(1 << (3 + Offset_len)) - 1  :0]
        .clka(clk),
        .wea(way2_we),
        .douta(way2_rdata)  //[(1 << (3 + Offset_len)) - 1  :0]
    );

    ICache_single_port_bram # (     //写优先块式存储器
        .RAM_WIDTH(20),
        .RAM_DEPTH(1 << (12 - Offset_len))
    )
    Tag1 (
        .addra(mux_addr),
        .dina(tag_reg),
        .clka(clk),
        .wea(tag1_we),
        .douta(tag1)
    );

    ICache_single_port_bram # (     //写优先块式存储器
        .RAM_WIDTH(20),
        .RAM_DEPTH(1 << (12 - Offset_len))
    )
    Tag2 (
        .addra(mux_addr),
        .dina(tag_reg),
        .clka(clk),
        .wea(tag2_we),
        .douta(tag2)
    );

    //state 状态机
    always @(posedge clk) begin
        if(!rstn) begin
            state <= 0;         //wait for valid
        end
        else begin
            if (state != `IDLE & branch_enable) begin
                state <= `IDLE;
            end
            else if(state == `IDLE & ICache_miss & !branch_enable & !branch_enable_reg) begin //把回填覆盖了
                state <= `MISS;
            end
            else if (state == `MISS & mem_read_finish) begin
                state <= `REFILL;
            end
            else if (state == `REFILL)begin
                state <= `WAIT;
            end
            else if(state == `WAIT) begin
                state <= `IDLE;
            end
        end
    end


    
    //last_used_way
    always @(posedge clk) begin
        if(!rstn) begin
            last_used_way <= 0;
        end
        else begin
            if(state == `IDLE & (!ICache_miss & !task_full)) begin
                if (hit[0]) begin
                    last_used_way[index_reg] <= 0;
                end
                else if(hit[1]) begin
                    last_used_way[index_reg] <= 1;
                end
            end
            else if(state == `IDLE & ICache_miss) begin
                last_used_way[index_reg] <= !last_used_way[index_reg];
            end
        end
    end
    
    always @(posedge clk) begin
        if(!rstn) begin
            tag1_reg <= 0;
            tag2_reg <= 0;
        end
        else begin
            if((!ICache_miss & !task_full & state == `IDLE) | branch_enable | branch_enable_reg) begin
                if(task_full_reg & !branch_enable & !branch_enable_reg) begin
                 tag1_reg <= tag1_task_full_restore;
                 tag2_reg <= tag2_task_full_restore;
                end
                else begin
                    if(ICache_addr_reg0[11:Offset_len] == index_reg) begin
                        tag1_reg <= tag1_reg;
                        tag2_reg <= tag2_reg;
                    end
                    else begin
                        tag1_reg <= data_restore ? miss_store_tag1_reg : tag1;
                        tag2_reg <= data_restore ? miss_store_tag2_reg : tag2;
                    end
                end
            end
            else if(state == `WAIT) begin //要在读取完成后将对应的tag修改，不然走不动
                if(!last_used_way[index_reg]) begin
                    tag1_reg <= tag_reg;
                end
                else begin
                    tag2_reg <= tag_reg;
                end
            end
        end
    end

    

    //tag1_we和tag2_we的维护
    always @(posedge clk) begin
        if(!rstn) begin
            tag1_we <= 0;
            tag2_we <= 0;
        end
        else begin
            if(state == `REFILL) begin
                if(!last_used_way[index_reg]) begin    //由于last_used_way在IDLE时已经更新，代表这次写入的是1路
                    tag1_we <= 1;
                end
                else begin
                    tag2_we <= 1;
                end
            end
            else begin
                tag1_we <= 0;
                tag2_we <= 0;
            end
        end
    end

    data_mux # (
        .Offset_len(Offset_len),
        .Segment_width(32)
    )
    data_mux_inst (
        .last_used_way(last_used_way[index_reg]),
        .offset(offset_reg),
        .hit(hit),
        .way1_rdata_reg(way1_rdata_reg),
        .way2_rdata_reg(way2_rdata_reg),
        .mux_output_data(mux_output_data)
    );

    mux_mem # (
        .Offset_len(Offset_len),
        .Segment_width(32)
    )
    mux_mem_inst (
        .offset(offset_reg),
        .mem_rdata(i_mem_rdata),
        .mux_mem_rdata(mux_mem_rdata)
    );

    assign ICache_rdata = ICache_miss ? mux_mem_rdata : mux_output_data;
    
    //way1_we, way2_we
    always @(posedge clk) begin
        if(!rstn) begin
            way1_we <= 0;
            way1_we <= 0;
        end
        else begin
            if(state == `REFILL) begin
                if(!last_used_way[index_reg]) begin
                    way1_we <= 1;
                end
                else begin
                    way2_we <= 1;
                end
            end
            else begin
                way1_we <= 0;
                way2_we <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            way1_rdata_reg <= 0;
            way2_rdata_reg <= 0;
        end
        else begin
            if(state == `WAIT) begin
                if(!last_used_way[index_reg]) begin     
                    way1_rdata_reg <= i_mem_rdata;
                end
                else begin
                    way2_rdata_reg <= i_mem_rdata;
                end
            end
            else begin
                if(!task_full) begin
                    if(task_full_reg & !branch_enable_reg) begin
                        way1_rdata_reg <= way1_rdata_task_full_restore; 
                        way2_rdata_reg <= way2_rdata_task_full_restore;
                    end
                    else begin
                        way1_rdata_reg <= way1_rdata;
                        way2_rdata_reg <= way2_rdata;
                    end
                end
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            i_rvalid <= 0;
        end
        else begin
            if (branch_enable | (state == `MISS & mem_read_finish)) begin
                i_rvalid <= 0;
            end
            else if(state == `IDLE & ICache_miss & !branch_enable & !branch_enable_reg) begin
                i_rvalid <= 1;
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            i_rready_reg <= 1;
        end
        else begin
            i_rready_reg <= i_rready;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            ICache_addr_reg0 <= 0;
        end
        else begin
            if((!ICache_miss & !task_full) | branch_enable_reg | branch_enable) begin       //如果取指过程中如果地址是错误的，等待两个周期更新到正确的地址
                ICache_addr_reg0 <= ICache_addr;
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            ICache_addr_reg <= 0;
        end
        else begin
            if((!ICache_miss & !task_full) | branch_enable_reg | branch_enable)begin
                ICache_addr_reg <= ICache_addr_reg0;
            end
        end
    end

    always @(posedge clk) begin
        branch_enable_reg <= branch_enable;
    end

    always @(posedge clk) begin
        if(branch_enable & !branch_enable_reg) begin
            flush_count <= 1;
        end
        else begin
            flush_count <= 0;
        end
    end

    always @(posedge clk) begin
        task_full_reg <= task_full;    
    end

    always @(posedge clk) begin
        if(!task_full_reg & task_full) begin
            tag1_task_full_restore <= tag1;
            tag2_task_full_restore <= tag2;
            way1_rdata_task_full_restore <= way1_rdata;
            way2_rdata_task_full_restore <= way2_rdata;
        end
    end
    
    always @(posedge clk) begin
        ICache_miss_reg <= ICache_miss;
    end


    always @(posedge clk) begin
        if(state == `IDLE && ICache_miss) begin
            miss_store_tag1_reg <= tag1;
            miss_store_tag2_reg <= tag2;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            i_mem_rdata <= 0;
        end
        else begin
            if(i_rready & !i_rready_reg) begin
                i_mem_rdata <= mem_rdata;
            end
        end
    end

    always @(posedge clk) begin
        branch_enable_reg2 <= branch_enable_reg;
    end

    assign data_restore = branch_enable | (!branch_enable_reg & !branch_enable_reg2 & ICache_miss_reg & !ICache_miss);
endmodule  
//22580.4