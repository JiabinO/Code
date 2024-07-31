`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/07 15:59:08
// Design Name: 
// Module Name: DCache
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
`define IDLE 3'b000
`define MISS 3'b001
`define WRITE 3'b010
`define READ 3'b011
`define REFILL 3'b100
`define WAIT 3'b101


module DCache
    #(parameter Offset_len = 6)
    (
        input                                           clk, rstn,
        input        [31                            :0] DCache_wdata,       // 需要处理st.b、st.h指令
        input        [31                            :0] DCache_addr,
        input                                           mem_read,           // cpu读请求
        input                                           mem_write,          // cpu写请求
        input                                           d_rready,           // 仲裁器的DCache读请求响应完毕
        input                                           d_wready,           // 仲裁器的DCache写请求响应完毕
        input        [(1 << (3 + Offset_len)) - 1   :0] mem_rdata,          // 从仲裁器读到的数据
        input                                           byte_write,         // 写字节
        input                                           half_word_write,    // 写半字
        input                                           word_write,         // 写字
        output  reg                                     mem_read_valid,     // 发送给CPU的读，用于选择数据，原来输入的mem_read由于延后了两个周期，可能没法保持
        output  reg                                     d_rvalid,           // 发送给仲裁器的读请求有效
        output  reg                                     d_wvalid,           // 发送给仲裁器的写请求有效
        output  reg  [31                            :0] d_waddr,            // 发送给仲裁器的DCache写地址
        output  reg  [31                            :0] d_raddr,            // 发送给仲裁器的DCache读地址
        output  reg  [31                            :0] DCache_rdata,       // 发送给CPU的读数据
        output  reg                                     DCache_miss_stop,   // 发送给CPU的miss信号
        output  reg  [(1 << (3 + Offset_len)) - 1   :0] d_wdata             // 发送给仲裁器写入内存的数据
    );

    //容量为8KB, 两路组相连，每路4KB = 2^(Offset_len-2) 字 * 2^(12 - Offset_len)
    //address: [     31:12      |    11:Offset_len    |    Offset_len - 1:0    ]
    //                Tag                index                   offset
    
    reg  [31:0]                             DCache_miss_count;
    reg  [(1 << (3 + Offset_len)) - 1:0]    DCache_rdata_block;
    reg                                     data_restore;
    reg                                     DCache_miss_reg;
    reg  [2:0]                              state;
    reg  [31:0]                             DCache_addr_reg;
    reg  [31:0]                             DCache_addr_reg0;
    wire [11 - Offset_len:0]                index = DCache_addr[11:Offset_len];
    wire [19:0]                             tag1, tag2;
    reg                                     tag1_we, tag2_we;
    reg  [19:0]                             tag1_reg, tag2_reg;
    wire [19:0]                             tag = DCache_addr_reg[31:12];
    reg  [(1 << Offset_len) - 1:0]          dirty1;      //记录Cache块是否被修改
    reg  [(1 << Offset_len) - 1:0]          dirty2;
    reg  [1:0]                              hit;        
    reg                                     way1_we;
    reg                                     way2_we;
    reg  [31                         :0]    DCache_wdata_reg;
    reg  [31:0]                             DCache_wdata_reg0;
    wire [(1 << (3 + Offset_len)) - 1:0]    way1_rdata;
    wire [(1 << (3 + Offset_len)) - 1:0]    way2_rdata;
    reg  [(1 << (3 + Offset_len)) - 1:0]    way1_rdata_reg;
    reg  [(1 << (3 + Offset_len)) - 1:0]    way2_rdata_reg;
    reg  [(1 << (3 + Offset_len)) - 1:0]    miss_store_way1_rdata_reg; //保存miss时已经读出的数据
    reg  [(1 << (3 + Offset_len)) - 1:0]    miss_store_way2_rdata_reg; //保存miss时已经读出的数据
    reg  [19:0]                             miss_store_tag1_reg;
    reg  [19:0]                             miss_store_tag2_reg;
    reg  [(1 << (12 - Offset_len)) - 1:0]   last_used_way;
    reg  [(1 << (3 + Offset_len)) - 1:0]    write_data;
    wire [(1 << (3 + Offset_len)) - 1:0]    processed_data;
    reg  [(1 << (3 + Offset_len)) - 1:0]    way_select_data;
    reg  [(1 << (3 + Offset_len)) - 1:0]    origin_data;
    reg                                     dirty;
    reg                                     d_rready_reg;
    reg                                     d_wready_reg;
    reg                                     mem_read_reg;
    reg                                     mem_read_reg0;
    reg                                     mem_write_reg;
    reg                                     mem_write_reg0;
    reg                                     byte_write_reg;
    reg                                     byte_write_reg0;
    reg                                     half_word_write_reg;
    reg                                     half_word_write_reg0;
    reg                                     word_write_reg;
    reg                                     word_write_reg0;
    reg                                     DCache_miss;
    reg  [31                          :0]   miss_addr;
    wire [11 - Offset_len             :0]   mux_index; 
    wire [11 - Offset_len             :0]   index_reg;
    wire [Offset_len - 1              :0]   offset_reg;
    wire restrict_test;
    //忽略低四位，为的是取完整个包含目标内容的块(16*32)的全部位
    assign          index_reg = DCache_addr_reg[11:Offset_len];
    assign          offset_reg = DCache_addr_reg[Offset_len - 1:0];
    assign          DCache_miss = ~|hit & (mem_read_reg | mem_write_reg);
    assign          dirty = !last_used_way[index_reg] ? dirty1[index_reg] : dirty2[index_reg];          //由于last_used_way会在IDLE且DCache_miss的状态下修改，在MISS阶段刚好是反过来的
    assign          hit = {DCache_addr_reg[31:12] == tag2_reg, DCache_addr_reg[31:12] == tag1_reg} ;

    always @(*) begin
        if(((DCache_addr_reg == 32'hbfd003fc | DCache_addr_reg == 32'hbfd003f8) & (mem_read_reg | mem_write_reg))) begin
            d_raddr = DCache_addr_reg;
        end
        else begin
            d_raddr = miss_addr & 32'hffffffc0;
        end
    end
    //读未命中时，需要从内存读出miss_addr的内容；写未命中时，如果块是脏的，则先将脏块写回，然后读出miss_addr的内容，最后再进行插入
    assign          d_waddr = DCache_addr_reg[31:0]& 32'hffffffc0; 
    assign          mem_read_valid = mem_read_reg;
    //如果上次使用了1路，则这次替换2路，否则使用1路
    assign          mux_index = DCache_miss | state == `WAIT ? index_reg : index;
    assign          restrict_test = ((((DCache_addr_reg[22:20] == 3'd4 & DCache_addr_reg[8:0] >= 0 & DCache_addr_reg[8:0] <= 9'h100)) | (DCache_addr_reg >= 32'h80100000 & DCache_addr_reg <= 32'h803fffff)) & mem_write_reg) | (DCache_addr_reg == 32'hbfd003fc | DCache_addr_reg == 32'hbfd003f8/*要加上这个情况，因为串口是实时变化的，有可能变动后，Cache里的内容与其不一致，因此需要默认为miss，每次都访存进行确认*/); 
    assign          DCache_miss_stop = DCache_miss | (restrict_test & state != `WAIT);

    always @(posedge clk) begin
        if(!rstn) begin
            DCache_miss_count <= 0;
        end
        else begin
            if(state == `MISS) begin
                DCache_miss_count <= DCache_miss_count + 1;
            end
        end
    end
    //tag 要写回，地址选择需要依赖DCache是否miss的条件，若miss，则选择DCache_addr_reg的高20位，用于写回；否则选择Dcache_addr的高二十位，用于读取新的tag
    ICache_single_port_bram # (     //写优先块式存储器
        .RAM_WIDTH(20),
        .RAM_DEPTH(1 << (12 - Offset_len))
    )
    Tag1 (
        .addra(mux_index),
        .dina(DCache_addr_reg[31:12]),
        .clka(clk),
        .wea(tag1_we),
        .douta(tag1)
    );

    ICache_single_port_bram # (     //写优先块式存储器
        .RAM_WIDTH(20),
        .RAM_DEPTH(1 << (12 - Offset_len))
    )
    Tag2 (
        .addra(mux_index),
        .dina(DCache_addr_reg[31:12]),
        .clka(clk),
        .wea(tag2_we),
        .douta(tag2)
    );

    dual_port_bram_byte_write # (
        .NB_COL(1 << Offset_len),
        .COL_WIDTH(8),
        .RAM_DEPTH(1 << (12 - Offset_len))
    )
    way1 (
        .addra(index_reg),
        .addrb(index),
        .dina(write_data),
        .clka(clk),
        .wea({{(1 << Offset_len){way1_we}}}),
        .doutb(way1_rdata)
    );

    dual_port_bram_byte_write # (
        .NB_COL(1 << Offset_len),           //offset
        .COL_WIDTH(8),                      //byte
        .RAM_DEPTH(1 << (12 - Offset_len))  //index
    )
    way2 (
        .addra(index_reg),
        .addrb(index),
        .dina(write_data),
        .clka(clk),
        .wea({{(1 << Offset_len){way2_we}}}),
        .doutb(way2_rdata)
    );

    insert_data # (
        .Offset_len(Offset_len)
    )
    insert_data_inst (
        .offset(offset_reg),
        .origin_data(origin_data),
        .inserted_data(DCache_wdata_reg),
        .byte_write(byte_write_reg),
        .half_word_write(half_word_write_reg),
        .word_write(word_write_reg),
        .processed_data(processed_data)
    );

    DCache_rdata_mux # (
        .Offset_len(Offset_len)
    )
    DCache_rdata_mux_inst (
        .DCache_rdata_block(DCache_rdata_block),
        .offset(offset_reg),
        .mux_rdata(DCache_rdata)
    );

    // 需要对数据和tag进行重定向，否则连续写入同一块仍然会找不到
    always @(posedge clk) begin
        if (!rstn) begin
            state <= `IDLE; 
        end
        else begin
            if (state == `IDLE & (DCache_miss | restrict_test)) begin  //0x80400000-0x80400100写穿透
                state <= `MISS;  
            end 
            else if (state == `MISS) begin
                if(mem_read_reg) begin
                    state <= `READ;
                end
                else begin
                    state <= `WRITE;
                end
            end
            else if (state == `WRITE) begin
                if((((!dirty & (d_rready & !d_rready_reg)) || (dirty & (d_wready & !d_wready_reg))) & !restrict_test) | (restrict_test & d_wready & !d_wready_reg)) begin  //如果数据未被污染，则先等待从内存读出数据，然后对数据进行插入，才到REFILL阶段；否则需要等待写回主存然后才REFILL
                    state <= `REFILL;
                end
            end
            else if (state == `READ) begin
                if(((!dirty & d_rready & !d_rready_reg) || (dirty & d_wready & !d_wready_reg) & !restrict_test) | (restrict_test & d_rready & !d_rready_reg)) begin
                    state <= `REFILL;
                end 
                // 原来index的数据没有被污染时，只需等待仲裁器读完毕；
                // 而被污染时，则需要等待仲裁器写回脏数据、读出新数据均完毕才能到下一阶段。
                // 而仲裁器的处理优先级是d_r > d_w，所以只需要等待d_w的上升沿
            end
            else if (state == `REFILL) begin
                state <= `WAIT;
            end
            else if (state == `WAIT) begin
                state <= `IDLE;
            end
        end
    end

    //tag1_we和tag2_we的维护, REFILL时进行
    always @(posedge clk) begin
        if(!rstn) begin
            tag1_we <= 0;
            tag2_we <= 0;
        end
        else begin
            if(state == `REFILL) begin
                if(!last_used_way[index_reg]) begin
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

    
    always @(posedge clk) begin     
        if(!rstn) begin
            last_used_way <= 0;
        end
        else begin
            if(state == `IDLE & !DCache_miss & (mem_read_reg | mem_write_reg)) begin                     //如果hit，则last_used_way改为hit的
                if (hit[0]) begin
                    last_used_way[index_reg] <= 0;
                end
                else if (hit[1]) begin
                    last_used_way[index_reg] <= 1;
                end
            end
            else if(state == `IDLE & DCache_miss) begin                               //如果不hit，则改为上次未被使用的
                last_used_way[index_reg] <= !last_used_way[index_reg];
            end
        end
    end

    //way1_we、way2_we
    always @(posedge clk) begin
        if(!rstn) begin
            way1_we <= 0;
            way2_we <= 0;
        end
        else begin
            if(state == `REFILL & (!restrict_test | DCache_miss)) begin
                if(!last_used_way[index_reg]) begin
                    way1_we <= 1;
                end
                else begin
                    way2_we <= 1;
                end
            end
            else if ((state == `IDLE | (state == `WAIT)) & !DCache_miss & mem_write_reg0) begin
                if(DCache_addr_reg0[31:12] == tag2) begin
                    way2_we <= 1;
                end
                else if(DCache_addr_reg0[31:12] == tag1) begin
                    way1_we <= 1;
                end
            end
            else begin
                way1_we <= 0;
                way2_we <= 0;
            end
        end
    end

    //DCache_rdata的维护
    always @(posedge clk) begin
        if(!rstn) begin
            DCache_rdata_block <= 0;
        end
        else begin
            if(DCache_miss | ((DCache_addr_reg == 32'hbfd003fc | DCache_addr_reg == 32'hbfd003f8) & mem_read_reg)) begin  
                if(mem_read_reg & d_rready & !d_rready_reg) begin  //读未命中，选择从仲裁器中返回的数据
                    DCache_rdata_block <= mem_rdata;  
                end
                else if(mem_write_reg) begin    //写未命中，则先加载目标地址原来的数据内容，并在原来数据内容上进行插入数据
                    DCache_rdata_block <= processed_data;
                end    
            end
            else begin  
                if(mem_read_reg0) begin  //如果下一个是读请求
                    if(data_restore) begin
                        if(DCache_addr_reg0[11:Offset_len] == index_reg) begin  //如果刚刚写回
                            DCache_rdata_block <= write_data;
                        end
                        else if(DCache_addr_reg0[31:12] == miss_store_tag1_reg) begin //第一路命中
                            DCache_rdata_block <= miss_store_way1_rdata_reg;
                        end
                        else if(DCache_addr_reg0[31:12] == miss_store_tag2_reg)begin  //第二路命中
                            DCache_rdata_block <= miss_store_way2_rdata_reg;
                        end
                    end
                    else begin
                        if(DCache_addr_reg0[31:12] == tag1) begin
                            DCache_rdata_block <= way1_rdata;   
                        end
                        else if(DCache_addr_reg0[31:12] == tag2) begin
                            DCache_rdata_block <= way2_rdata;
                        end
                    end
                end
                else if(mem_write_reg) begin    //写命中
                    DCache_rdata_block <= processed_data;
                end
            end
        end
    end

    //d_rvalid
    always @(posedge clk) begin
        if(!rstn) begin
            d_rvalid <= 0;
        end
        else begin
            if(state == `MISS) begin   //写请求未命中：1 写请求命中：0 读请求未命中：1 读请求命中：0
                d_rvalid <= 1;
            end
            else if(d_rready && !d_rready_reg) begin
                d_rvalid <= 0;
            end
        end
    end
    
    //d_wvalid
    always @(posedge clk) begin
        if(!rstn) begin
            d_wvalid <= 0;
        end
        else begin
            if (restrict_test & d_wready & !d_wready_reg) begin
                d_wvalid <= 0;
            end
            else if(restrict_test & state == `MISS) begin
                if(!mem_read_reg) begin
                    d_wvalid <= 1;
                end
                else begin
                    d_wvalid <= 0;
                end
            end
            else if(state == `MISS & mem_write_reg) begin
                if(dirty) begin            //访存miss,如果对应数据被污染则需要将污染数据写回到主存
                   d_wvalid <= 1; 
                end
            end
            else if(d_wready & !d_wready_reg) begin 
                d_wvalid <= 0;
            end
        end
    end
    
    //dirty的维护
    always @(posedge clk) begin
        //初始化
        integer i;
        if(!rstn) begin
            for(i = 0; i < (1 << Offset_len); i++) begin    
                dirty1[i] <= 0;
                dirty2[i] <= 0;
            end
        end
        else begin
            if(state == `REFILL || (state == `IDLE && mem_write_reg && !DCache_miss)) begin
                if(hit[0]) begin
                    dirty1[index_reg] <= 1;
                end
                else if(hit[1]) begin
                    dirty2[index_reg] <= 1; 
                end
                else begin
                    if(!last_used_way[index_reg]) begin
                        dirty1[index_reg] <= 1;
                    end
                    else begin
                        dirty2[index_reg] <= 1;
                    end
                end
            end
        end
        
    end

    //d_wdata：
    //当写未命中且dirty时，需要将原来dirty的数据写回
    always @(posedge clk) begin
        if(!rstn) begin
            d_wdata <= 0;
        end
        else begin
            if(restrict_test) begin
                d_wdata <= processed_data;
            end
            else if(state == `MISS & mem_write_reg & dirty) begin
                d_wdata <= way_select_data;
            end
        end
    end
    
    //origin_data:
    //当命中时，被插入的数据为hit的一路输出的数据
    //当未命中时，被插入的数据是从仲裁器读到的数据
    always @(posedge clk) begin
        if(!rstn) begin
            origin_data <= 0;
        end
        else begin
            if((state == `WRITE | state == `READ) & d_rready & !d_rready_reg) begin 
                origin_data <= mem_rdata;
            end
            else if((state == `WAIT | state == `IDLE) & mem_write_reg) begin   //如果上个周期写的是这个地址，则更新为最新写入的数据
                if(DCache_addr_reg0[31:Offset_len] == DCache_addr_reg[31:Offset_len]) begin
                    origin_data <= write_data;
                end
            end
            else if(state == `IDLE & !DCache_miss) begin
                if(DCache_addr_reg0[31:12] == tag2) //如果tag相同，选择上个周期读出的新数据
                    origin_data <= way2_rdata;
                else if(DCache_addr_reg0[31:12] == tag1) 
                    origin_data <= way1_rdata;
                else
                    origin_data <= way_select_data;
            end
        end
    end

    //write_data
    always @(*) begin
        //写命中时，写入数据拼入块行中
        //写未命中时，需要先加载index所在的块行的所有数据，然后再插入新加入的数据
        //读命中时，无需更改
        //读未命中时，只需将从仲裁器读到的数据写入
        if(state == `IDLE & !DCache_miss) begin
            write_data = processed_data;
        end
        else if(state == `WAIT) begin
            if(mem_read_reg) begin
                write_data = mem_rdata;                
            end
            else if(mem_write_reg) begin
                write_data = processed_data;
            end
            else begin
                write_data = 0;
            end
        end 
        else begin
            write_data = 0;
        end
    end

    //way_select_data
    //当命中时，选择命中的那一路
    //当未命中时，选择最近未被使用的那一路
    //用于写回到Cache和更新DCache_rdata
    always @(*) begin
        if(!DCache_miss) begin  //写命中
            if(hit[1]) begin
                way_select_data = way2_rdata_reg;
            end
            else begin
                way_select_data = way1_rdata_reg;
            end
        end
        else if(DCache_miss) begin      //未命中
            if(!last_used_way[index]) begin
                way_select_data = way1_rdata_reg;
            end
            else begin
                way_select_data = way2_rdata_reg;
            end
        end
        else begin
            way_select_data = 0;
        end
    end

    always @(posedge clk) begin         //当阻塞时不更新，直至操作完成
        if(!rstn) begin
            mem_read_reg <= 0;
        end
        if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) 
            mem_read_reg <= mem_read_reg0;
    end

    always @(posedge clk) begin
        if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) 
            mem_read_reg0 <= mem_read;
    end
    always @(posedge clk) begin
        if(!rstn) begin
            mem_write_reg <= 0;
        end
        if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) 
            mem_write_reg <= mem_write_reg0;
    end

    always @(posedge clk) begin
        if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) 
            mem_write_reg0 <= mem_write;
    end

    always @(posedge clk) begin
        d_rready_reg <= d_rready;
    end

    always @(posedge clk) begin
        d_wready_reg <= d_wready;
    end
    
    always @(posedge clk) begin
        if(!rstn) begin
            way1_rdata_reg <= 0;
            way2_rdata_reg <= 0;
        end
        else begin
            if(state == `WAIT) begin
                if(mem_read_reg) begin
                    if(!last_used_way[index]) begin
                        way1_rdata_reg <= mem_rdata;
                    end
                    else begin
                        way2_rdata_reg <= mem_rdata;
                    end
                end
                else begin
                    if(!last_used_way[index]) begin
                        way1_rdata_reg <= write_data;
                    end
                    else begin
                        way2_rdata_reg <= write_data;
                    end
                end 
            end
            else begin  //写命中
                way1_rdata_reg <= way1_rdata;
                way2_rdata_reg <= way2_rdata;
            end
        end
    end

    always @(posedge clk) begin
        if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) begin
            word_write_reg0 <= word_write;
        end
    end

    always @(posedge clk) begin
        if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) begin
            word_write_reg <= word_write_reg0;
        end
    end

    always @(posedge clk) begin
        if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) begin
            half_word_write_reg0 <= half_word_write;
        end
    end
    
    always @(posedge clk) begin
        if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) begin
            half_word_write_reg <= half_word_write_reg0;
        end
    end

    always @(posedge clk) begin
        if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) begin
            byte_write_reg0 <= byte_write;
        end
    end

    always @(posedge clk) begin
        if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) begin
            byte_write_reg <= byte_write_reg0;
        end
    end

    always @(posedge clk) begin
        if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) begin
            DCache_wdata_reg0 <= DCache_wdata;
        end
    end

    always @(posedge clk) begin
        if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) begin
            DCache_wdata_reg <= DCache_wdata_reg0;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            tag1_reg <= 0;
            tag2_reg <= 0;
        end
        else begin
            if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) begin
                if(DCache_addr_reg0[11:Offset_len] == index_reg & (mem_read_reg | mem_write_reg)) begin
                    tag1_reg <= tag1_reg;
                    tag2_reg <= tag2_reg;
                end
                else begin
                    tag1_reg <= data_restore ? miss_store_tag1_reg : tag1;
                    tag2_reg <= data_restore ? miss_store_tag2_reg : tag2;
                end
            end
            else if(state == `REFILL) begin //要在读取完成后将对应的tag修改，不然走不动
                if(!last_used_way[index_reg]) begin
                    tag1_reg <= tag;
                end
                else begin
                    tag2_reg <= tag;
                end
            end
        end
    end

    //miss_addr
    always @(posedge clk) begin
        if(!rstn) begin
            miss_addr <= 0;
        end
        else begin
            if(state == `IDLE & DCache_miss) begin
                miss_addr <= DCache_addr_reg;
            end
        end
    end

    //DCache_addr_reg0
    always @(posedge clk) begin
        if(!rstn) begin
            DCache_addr_reg0 <= 0;
        end
        else begin
            if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) begin
                DCache_addr_reg0 <= DCache_addr;
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            DCache_addr_reg <= 0;
        end
        else begin
            if((!DCache_miss & !restrict_test) | (restrict_test & state == `WAIT)) begin
                DCache_addr_reg <= DCache_addr_reg0;
            end
        end
    end

    always @(posedge clk) begin
        if(state == `IDLE && (DCache_miss | (restrict_test & (mem_read_reg | mem_write_reg)))) begin
            miss_store_way1_rdata_reg <= way1_rdata;
            miss_store_way2_rdata_reg <= way2_rdata;
            miss_store_tag1_reg <= tag1;
            miss_store_tag2_reg <= tag2;
        end
    end

    always @(posedge clk) begin
        DCache_miss_reg <= DCache_miss;
    end

    assign data_restore = (DCache_miss_reg & !DCache_miss) | (restrict_test & state == `WAIT);
endmodule