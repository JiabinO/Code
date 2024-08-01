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
`define SERIEL_STATUS_ADDR 32'hbfd003fc
`define SERIEL_BUFFER_ADDR 32'hbfd003f8
`define UNCACHE_WRITE_BEGIN_ADDR 32'h80100000
`define UNCACHE_WRITE_END_ADDR 32'h807fffff

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
    
    reg  [(1 << (3 + Offset_len)) - 1   :0] DCache_rdata_block;
    reg  [2                             :0] state;
    reg  [31                            :0] DCache_addr_reg;
    reg  [31                            :0] DCache_addr_reg0;
    reg                                     tag1_we;
    reg                                     tag2_we;
    reg  [19                            :0] tag1_reg;
    reg  [19                            :0] tag2_reg;
    reg  [(1 << Offset_len) - 1         :0] dirty1;      
    reg  [(1 << Offset_len) - 1         :0] dirty2;
    reg                                     way1_we;
    reg                                     way2_we;
    reg  [31                            :0] DCache_wdata_reg;
    reg  [31                            :0] DCache_wdata_reg0;
    reg  [(1 << (3 + Offset_len)) - 1   :0] way1_rdata_reg;
    reg  [(1 << (3 + Offset_len)) - 1   :0] way2_rdata_reg;
    reg  [(1 << (12 - Offset_len)) - 1  :0] last_used_way;
    reg  [(1 << (3 + Offset_len)) - 1   :0] write_data;
    reg  [(1 << (3 + Offset_len)) - 1   :0] origin_data;                // 被插入的数据
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
    reg  [(1 << (3 + Offset_len)) - 1   :0] d_mem_rdata;
    reg                                     write_uncache_have_read;    // uncache写已经从仲裁器获取了待插入的数据
    reg  [(1 << (3 + Offset_len)) - 1   :0] inserted_data_reg;
    reg  [31                            :0] DCache_wdata_restore;  
    reg  [19                            :0] tag1_restore;
    reg  [19                            :0] tag2_restore;
    reg  [(1 << (3 + Offset_len)) - 1   :0] way1_rdata_restore;
    reg  [(1 << (3 + Offset_len)) - 1   :0] way2_rdata_restore;
    
    wire [11 - Offset_len               :0] index;
    wire [19                            :0] tag1;
    wire [19                            :0] tag2;
    wire [19                            :0] tag_reg;    
    wire [1                             :0] hit;        
    wire [(1 << (3 + Offset_len)) - 1   :0] way1_rdata;
    wire [(1 << (3 + Offset_len)) - 1   :0] way2_rdata;
    wire [(1 << (3 + Offset_len)) - 1   :0] inserted_data;
    wire                                    dirty;
    wire                                    restrict_test_reg0;
    wire [11 - Offset_len               :0] mux_index; 
    wire [11 - Offset_len               :0] index_reg;
    wire [Offset_len - 1                :0] offset_reg;
    wire                                    restrict_test;
    wire                                    read_uncache;
    wire                                    read_uncache_reg0;
    wire                                    write_uncache;
    wire                                    write_uncache_reg0;
    wire [1                             :0] hit_reg0;
    wire                                    pipeline_enable;
    wire                                    seriel_buffer_write;


    assign tag_reg              = DCache_addr_reg[31:12];
    assign index                = DCache_addr[11:Offset_len];
    assign pipeline_enable      = (state == `IDLE & !(DCache_miss | read_uncache | write_uncache | seriel_buffer_write)) | state == `WAIT;
    assign hit_reg0             = {DCache_addr_reg0[31:12] == (state == `WAIT ? tag2_restore : tag2), DCache_addr_reg0[31:12] == (state == `WAIT ? tag1_restore : tag1)};   // 50156
    assign read_uncache_reg0    = (DCache_addr_reg0 == `SERIEL_BUFFER_ADDR | DCache_addr_reg0 == `SERIEL_STATUS_ADDR) & mem_read_reg0;
    assign write_uncache_reg0   = ((DCache_addr_reg0 >= `UNCACHE_WRITE_BEGIN_ADDR & DCache_addr_reg0 <= `UNCACHE_WRITE_END_ADDR) | DCache_addr_reg0 == `SERIEL_BUFFER_ADDR) & mem_write_reg0;
    assign read_uncache         = (DCache_addr_reg == `SERIEL_BUFFER_ADDR | DCache_addr_reg == `SERIEL_STATUS_ADDR) & mem_read_reg;  // 由于串口可以被外部改变，因此每次读都需要读取外设
    assign write_uncache        = (DCache_addr_reg >= `UNCACHE_WRITE_BEGIN_ADDR & DCache_addr_reg <= `UNCACHE_WRITE_END_ADDR) & mem_write_reg;     
    assign index_reg            = DCache_addr_reg[11:Offset_len];
    assign offset_reg           = DCache_addr_reg[Offset_len - 1:0];
    assign DCache_miss          = ~|hit & (mem_read_reg | mem_write_reg);
    assign dirty                = !last_used_way[index_reg] ? dirty1[index_reg] : dirty2[index_reg];                                              
    assign hit                  = {DCache_addr_reg[31:12] == tag2_reg, DCache_addr_reg[31:12] == tag1_reg} ;
    assign restrict_test_reg0   = ((DCache_addr_reg0 >= 32'h80100000 & DCache_addr_reg0 <= 32'h807fffff) & mem_write_reg0) | (DCache_addr_reg0 == 32'hbfd003fc | DCache_addr_reg0 == 32'hbfd003f8);
    assign d_waddr              = DCache_addr_reg[31:0] & 32'hffffffc0; 
    assign DCache_miss_stop     = !pipeline_enable;
    assign seriel_buffer_write  = mem_write_reg & (DCache_addr_reg == `SERIEL_BUFFER_ADDR);
    /*
        DCache状态机：

        IDLE:   1. 读命中且CACHE -> IDLE (流水线流动)
                2. 写命中且CACHE -> IDLE (we需要reg0级判断 tag1 == DCache_addr_reg0 | tag2 == DCache_addr_reg0 置为1， 写数据通过 insert 模块获取)
                3. 读命中且UNCACHE -> MISS (流水线暂停)
                4. 写命中且UNCACHE -> MISS (流水线暂停)
                5. 读未命中且CACHE -> MISS (流水线暂停)
                6. 写未命中且CACHE -> MISS (流水线暂停)
                7. 读串口 -> MISS
                8. 写串口 -> WRITE
            
        MISS:   1. mem_read_reg & !read_uncache -> 判断脏位:
                    i. 不脏，从仲裁器直接，等待 d_rready & !d_rready_reg，然后写回Cache，dirty 标记为0， 需要将 d_rvalid 置为1   -> READ
                    ii.脏，如果是串口，则不写回主存,否则先写回主存；再等待 d_rready & !d_rready_reg， 然后写回Cache，dirty 标记为0，需要将 d_wvalid 和 d_rvalid 同时置为1 -> WRITE
                2. mem_read_reg & read_uncache -> 等待 d_rready & !d_rready_reg，直接读出，不写回Cache，dirty 不用改，需要将 d_rvalid 置为1 -> READ
                3. mem_write_reg & !write_uncache -> 判断是否写串口：
                    (1) 写串口: 直接跳到READ，不进行写回
                    (2) 不写串口： -> 判断是否为脏:
                        i. 不脏，等待仲裁器 d_rready & !d_rready_reg， 然后写回Cache，使用insert模块，dirty 标记为1，需要将 d_rvalid 置为1  -> READ
                        ii. 脏，先把脏数据写回，等待d_rready & !d_rready_reg 时，将数据从仲裁器取出，使用insert模块获取要写的数据，dirty 标记为1，需要将 d_wvalid 和 d_rvalid同时置为1 -> WRITE
                4. mem_write_reg & write_uncache -> 判断脏位：
                    i. 不脏，等待仲裁器 d_rready & !d_rready_reg， 获取仲裁器数据，然后通过insert模块写入缓存的同时，将d_wdata更新，需要同时置起 d_rvalid -> READ
                    ii. 脏，等待仲裁器 d_wready & !d_wready_reg, 进入READ状态，获取仲裁器数据，又重新进入WRITE状态，使用insert模块写入缓存，最后写回缓存 -> WRITE

        WRITE:  1. !write_uncache & mem_write_reg -> READ 写未命中，且刚刚把脏数据写进缓存，需要读数据，然后使用insert模块写回缓存
                2. !read_uncache & mem_read_reg -> READ 读未命中，且刚刚把脏数据写进缓存，需要读数据，然后把数据写回缓存
                3. write_uncache & !write_uncache_have_read -> READ uncache写刚刚把脏数据写回，需要读数据，然后再次进入写状态将数据写穿透
                4. write_uncache & write_uncache_have_read -> REFILL uncache写刚刚写穿透了，把数据写回缓存

        READ:   1. write_uncache -> WRITE  刚刚读完数据，使用 insert 模块更新写数据，进入WRITE写穿透
                2. mem_read_reg & !read_uncache -> REFILL 读完数据且需要写回缓存，进入REFILL
                3. mem_write_reg & !write_uncache -> REFILL 读完数据，使用 insert 更新写回数据，进入REFILL


        REFILL: 写回tag和way，更新dirty，更新最近使用记录

        WAIT: 等待写回并读出正常
    */

    dual_port_bram_byte_write # (
        .NB_COL(1),
        .COL_WIDTH(20),
        .RAM_DEPTH(1 << (12 - Offset_len))
    )
    Tag1 (
        .addra(index_reg),
        .addrb(index),
        .dina(tag_reg),
        .clka(clk),
        .wea(tag1_we),
        .doutb(tag1)
    );

    dual_port_bram_byte_write # (
        .NB_COL(1),
        .COL_WIDTH(20),
        .RAM_DEPTH(1 << (12 - Offset_len))
    )
    Tag2 (
        .addra(index_reg),
        .addrb(index),
        .dina(tag_reg),
        .clka(clk),
        .wea(tag2_we),
        .doutb(tag2)
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
        .addra(index_reg),                  //写端口
        .addrb(index),                      //读端口
        .dina(write_data),                  //写数据
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
        .inserted_data(DCache_wdata_reg),   // CPU要插入的字
        .byte_write(byte_write_reg),
        .half_word_write(half_word_write_reg),
        .word_write(word_write_reg),
        .processed_data(inserted_data)      // 插入后块存储器一行的内容
    );

    DCache_rdata_mux # (
        .Offset_len(Offset_len)
    )
    DCache_rdata_mux_inst (
        .DCache_rdata_block(DCache_rdata_block),
        .offset(offset_reg),
        .mux_rdata(DCache_rdata)
    );

    // state
    always @(posedge clk) begin
        if (!rstn) begin
            state <= `IDLE; 
        end
        else begin
            if (state == `IDLE & (DCache_miss | read_uncache | (DCache_addr_reg == `SERIEL_BUFFER_ADDR & mem_write_reg))) begin  // write_uncache 但是
                state <= `MISS;  
            end 
            else if (state == `IDLE & !DCache_miss & write_uncache) begin
                state <= `WRITE;
            end
            else if (state == `MISS) begin
                if(!dirty | read_uncache | (seriel_buffer_write)) begin
                    state <= `READ;
                end
                else if(dirty) begin
                    state <= `WRITE;
                end
            end
            else if (state == `WRITE) begin
                if(d_wready & !d_wready_reg) begin
                    if( (mem_write_reg & !write_uncache & DCache_addr_reg != `SERIEL_BUFFER_ADDR    )|  // 写未命中且有脏数据，脏数据写回后进入READ读取内存
                        (write_uncache & !write_uncache_have_read                                   )|  // 写未命中且有脏数据，脏数据写回后进入READ读取内存
                        (mem_read_reg & !read_uncache                                               ))  // 读未命中且有脏数据，脏数据写回后进入READ读取内存
                    begin
                        state <= `READ;
                    end
                    else if(write_uncache_have_read & write_uncache & !seriel_buffer_write) begin
                        state <= `REFILL;
                    end
                    else if(seriel_buffer_write) begin
                        state <= `WAIT;
                    end
                end
                    
            end
            else if (state == `READ) begin
                if(d_rready & !d_rready_reg) begin
                    if(write_uncache | (seriel_buffer_write)) begin
                        state <= `WRITE;
                    end
                    else if((mem_read_reg & !read_uncache   )|  // 读取完数据，可以写回到缓存
                            (mem_write_reg & !write_uncache ))  // 读取完数据，可以通过 insert 模块获取数据写回到缓存
                    begin
                        state <= `REFILL;
                    end 
                    else if(read_uncache) begin                 // 读uncache不写回
                        state <= `WAIT;
                    end   
                end
            end
            else if (state == `REFILL) begin
                state <= `WAIT;
            end
            else if (state == `WAIT) begin
                state <= `IDLE;
            end
        end
    end

    //tag1_we, tag2_we
    always @(posedge clk) begin
        if(!rstn) begin
            tag1_we <= 0;
            tag2_we <= 0;
        end
        else begin
            if(state == `REFILL & DCache_miss) begin
                if(last_used_way[index_reg]) begin
                    tag1_we <= 1;                   // 上次使用的如果是2路，则这次使用1路
                end 
                else begin
                    tag2_we <= 1;                   // 上次使用的如果是1路，则这次使用2路
                end
            end
            else begin
                tag1_we <= 0;
                tag2_we <= 0;
            end
        end
    end

    // LRU简化版计数器，last_used_way数组
    always @(posedge clk) begin     
        if(!rstn) begin
            last_used_way <= 0;
        end
        else begin
            if(state == `IDLE & (mem_read_reg | mem_write_reg)) begin                     //如果hit，则last_used_way改为hit的
                if (hit[0]) begin
                    last_used_way[index_reg] <= 0;      // 如果使用到DCache且命中，则将其更新为命中的那一路
                end
                else if (hit[1]) begin
                    last_used_way[index_reg] <= 1;
                end
            end
            else if(state == `REFILL) begin             // 如果不hit，则改为上次未被使用的
                last_used_way[index_reg] <= !last_used_way[index_reg];
            end
        end
    end

    //way1_we, way2_we
    always @(posedge clk) begin
        if(!rstn) begin
            way1_we <= 0;
            way2_we <= 0;
        end
        else begin
            if(state == `REFILL) begin 
                if(!DCache_miss) begin
                    if(hit[0]) begin
                        way1_we <= 1;
                    end
                    else begin
                        way2_we <= 1;
                    end
                end
                else begin
                    if(last_used_way[index_reg]) begin
                        way1_we <= 1;
                    end
                    else begin
                        way2_we <= 1;
                    end
                end
            end
            else if ((state == `IDLE | state == `WAIT) & mem_write_reg0 & !write_uncache_reg0) begin
                if(hit_reg0[1]) begin
                    way2_we <= 1;
                end
                else if(hit_reg0[0]) begin
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
            if(state == `READ & d_rready & !d_rready_reg & read_uncache) begin  // read_uncache 的输出， WAIT时期更新出来
                DCache_rdata_block <= mem_rdata;
            end
            else if(state == `REFILL) begin                                     // miss 或者 write_uncache 的输出，也是WAIT时期更新出来
                if(mem_read_reg) begin
                    DCache_rdata_block <= d_mem_rdata;                          // 从仲裁器读出的数据(从READ状态过来的)
                end
                else if(mem_write_reg) begin
                    if(write_uncache) begin
                        DCache_rdata_block <= inserted_data;                    // 写入cache的数据是插入后的数据(从READ状态过来的)
                    end
                    else begin
                        DCache_rdata_block <= d_wdata;                          // write_uncache 最后写入仲裁器的数据就是最新读出的数据(从WRITE状态过来的)
                    end
                end
            end
            else if(state == `WAIT) begin
                if(DCache_addr_reg[31:Offset_len] == DCache_addr_reg0[31:Offset_len]) begin // 如果 WAIT 读的块和下一个周期读的块是一样的
                    if(!read_uncache & !read_uncache_reg0) begin                            // 如果二者都不是uncache读
                        DCache_rdata_block <= DCache_rdata_block;
                    end
                end
                else begin
                    if(hit_reg0[1]) begin
                        DCache_rdata_block <= way2_rdata_restore;
                    end
                    else if(hit_reg0[0]) begin
                        DCache_rdata_block <= way1_rdata_restore;                           // 22122946
                    end     
                end
            end                                                                             // 未恢复数据
            else if(state == `IDLE) begin
                if(!(DCache_miss | read_uncache | write_uncache) | state == `WAIT) begin    // 如果不进入MISS状态，数据需要更新
                    if(DCache_addr_reg[31:Offset_len] == DCache_addr_reg0[31:Offset_len]) begin  
                        if(mem_write_reg) begin                                             // 如果刚刚写进来，则更新最近写进来的数据
                            DCache_rdata_block <= write_data;
                        end
                        else begin
                            DCache_rdata_block <= DCache_rdata_block;                       // 如果不写，则选择刚刚读出的一行数据
                        end
                    end 
                    else begin
                        if(hit_reg0[1]) begin
                            DCache_rdata_block <= way2_rdata;
                        end
                        else if(hit_reg0[0]) begin
                            DCache_rdata_block <= way1_rdata;
                        end
                    end
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
            if(state == `MISS & (!dirty | read_uncache | seriel_buffer_write)) begin   
                d_rvalid <= 1;
            end
            else if(state == `WRITE & d_wready & !d_wready_reg) begin           // 22098870 出现写串口数据时 write_uncache_have_read未正确置起，且valid不在ready沿变化
                if( (mem_write_reg & !write_uncache)              |
                    ((write_uncache & !write_uncache_have_read)   |
                    (mem_read_reg   & !read_uncache)              )) begin
                    d_rvalid <= 1;
                end
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
            if(state == `MISS) begin
                if(dirty & !read_uncache) begin         // 读穿透不需要写
                    d_wvalid <= 1;
                end
            end
            else if(state == `READ) begin
                if((write_uncache | (seriel_buffer_write)) & d_rready & !d_rready_reg) begin
                    d_wvalid <= 1;
                end
            end
            else if(state == `IDLE & !DCache_miss & write_uncache) begin
                d_wvalid <= 1;
            end
            else begin
                if(d_wready & !d_wready_reg) begin
                    d_wvalid <= 0;
                end
            end
        end
    end
    
    //dirty1, dirty2 脏位维护
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
            if(state == `REFILL) begin                      // 未命中或uncache时
                if(mem_read_reg & !read_uncache) begin
                    if(last_used_way[index_reg]) begin      // 读数据，与主存相同，脏位清零
                        dirty1[index_reg] <= 0;
                    end
                    else begin
                        dirty2[index_reg] <= 0;
                    end
                end
                else if(mem_write_reg) begin
                    if(write_uncache) begin                 // 写穿透，与主存相同，脏位清零
                        if(last_used_way[index_reg]) begin     
                            dirty1[index_reg] <= 0;
                        end
                        else begin
                            dirty2[index_reg] <= 0;
                        end
                    end
                    else begin
                        if(last_used_way[index_reg]) begin  // 写回写分配，与主存不同，脏位置为1
                            dirty1[index_reg] <= 1;
                        end
                        else begin
                            dirty2[index_reg] <= 1;
                        end
                    end
                end
            end
        end
        
    end

    //d_wdata
    always @(posedge clk) begin
        if(!rstn) begin
            d_wdata <= 0;
        end
        else begin
            if(state == `MISS & dirty) begin        // 如果脏，则写回数据首先是原来缓存的内容
                if(last_used_way[index_reg]) begin  // 选择最近未被使用的那一路
                    d_wdata <= way1_rdata_reg;
                end
                else begin
                    d_wdata <= way2_rdata_reg;
                end
            end
            else if(state == `READ & (write_uncache | (seriel_buffer_write)) & d_rready & !d_rready_reg) begin   // 如果写穿透刚刚读完了数据并且完成insert
                d_wdata <= inserted_data;
            end
            else if(state == `IDLE & !DCache_miss & write_uncache) begin
                d_wdata <= inserted_data;
            end
        end
    end
    
    // origin_data
    always @(*) begin
        if(state == `READ & mem_write_reg & d_rready & !d_rready_reg) begin             // READ阶段生成inserted_data
            origin_data = mem_rdata;
        end
        else if(state == `IDLE & mem_write_reg & |hit) begin
            if(hit[1]) begin
                origin_data = way2_rdata_reg;
            end
            else begin
                origin_data = way1_rdata_reg;
            end
        end
    end

    // write_data
    // 写命中时，写入数据拼入块行中
    // 写未命中时，需要先加载index所在的块行的所有数据，然后再插入新加入的数据
    // 读命中时，无需更改
    // 读未命中时，只需将从仲裁器读到的数据写入
    always @(*) begin
        if(state == `WAIT) begin
            if(mem_read_reg) begin
                write_data = d_mem_rdata;
            end
            else begin                      
                if(write_uncache) begin
                    write_data = d_wdata;
                end
                else begin
                    write_data = inserted_data_reg;
                end
            end
        end
        else if(state == `IDLE) begin
            if(mem_write_reg & write_uncache & |hit) begin
                write_data = inserted_data;
            end
        end
        else begin
            write_data = 0;
        end
    end

    always @(posedge clk) begin         //当阻塞时不更新，直至操作完成
        if(!rstn) begin
            mem_read_reg <= 0;
        end
        if(pipeline_enable) 
            mem_read_reg <= mem_read_reg0;
    end

    always @(posedge clk) begin
        if(pipeline_enable) 
            mem_read_reg0 <= mem_read;
    end
    always @(posedge clk) begin
        if(!rstn) begin
            mem_write_reg <= 0;
        end
        if(pipeline_enable) 
            mem_write_reg <= mem_write_reg0;
    end

    always @(posedge clk) begin
        if(pipeline_enable) 
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
            if(state == `REFILL) begin
                if(last_used_way[index]) begin
                    way1_rdata_reg <= write_data;
                end
                else begin
                    way2_rdata_reg <= write_data;
                end
            end
            else if(pipeline_enable) begin
                if(state == `IDLE & mem_write_reg & !write_uncache & |hit) begin
                    if(DCache_addr_reg0[31:Offset_len] == DCache_addr_reg) begin
                        if(hit[0]) begin
                            way1_rdata_reg <= write_data;
                        end
                        else begin
                            way2_rdata_reg <= write_data;
                        end
                    end
                end
                else begin                          // WAIT 3441110 reg的内容更新错误，更成没有写入之前的数据
                    way1_rdata_reg <= way1_we ? d_wdata : way1_rdata;
                    way2_rdata_reg <= way2_we ? d_wdata : way2_rdata;
                end
            end
        end
    end

    always @(posedge clk) begin
        if(pipeline_enable) begin
            word_write_reg0 <= word_write;
        end
    end

    always @(posedge clk) begin
        if(pipeline_enable) begin
            word_write_reg <= word_write_reg0;
        end
    end

    always @(posedge clk) begin
        if(pipeline_enable) begin
            half_word_write_reg0 <= half_word_write;
        end
    end
    
    always @(posedge clk) begin
        if(pipeline_enable) begin
            half_word_write_reg <= half_word_write_reg0;
        end
    end

    always @(posedge clk) begin
        if(pipeline_enable) begin
            byte_write_reg0 <= byte_write;
        end
    end

    always @(posedge clk) begin
        if(pipeline_enable) begin
            byte_write_reg <= byte_write_reg0;
        end
    end

    always @(posedge clk) begin
        if(pipeline_enable) begin
            DCache_wdata_reg0 <= state == `WAIT ? DCache_wdata_restore : DCache_wdata;  //4200662 从stop状态下恢复时reg0无法更新正确(更新到一个周期之后stop的地址的写数据)
        end
    end

    always @(posedge clk) begin
        if(pipeline_enable) begin
            DCache_wdata_reg <= DCache_wdata_reg0;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            tag1_reg <= 0;
            tag2_reg <= 0;
        end
        else begin
            if(state == `REFILL & DCache_miss) begin        
                if(last_used_way[index_reg]) begin
                    tag1_reg <= tag_reg;
                end
                else begin
                    tag2_reg <= tag_reg;
                end
            end
            else if(pipeline_enable) begin
                if(state == `WAIT) begin
                    if(tag1_we & DCache_addr_reg0[11:Offset_len] == index_reg) begin
                        tag1_reg <= tag_reg;
                    end
                    else if(tag2_we & DCache_addr_reg0[11:Offset_len] == index_reg) begin
                        tag2_reg <= tag_reg;
                    end
                    else begin
                        tag1_reg <= tag1_restore;       
                        tag2_reg <= tag2_restore;
                    end 
                end
                else begin
                    tag1_reg <= tag1;
                    tag2_reg <= tag2;
                end
                
            end
        end
    end

    // d_raddr
    always @(posedge clk) begin
        if(!rstn) begin
            d_raddr <= 0;
        end
        else begin
            if(state == `MISS) begin
                if(read_uncache | (seriel_buffer_write)) begin
                    d_raddr <= DCache_addr_reg;
                end
                else if(!dirty) begin
                    d_raddr <= DCache_addr_reg & 32'hffffffc0;
                end
            end
            else if(state == `WRITE & d_wready & !d_wready_reg) begin
                if(write_uncache & !write_uncache_have_read) begin
                    if(DCache_addr_reg == `SERIEL_BUFFER_ADDR | DCache_addr_reg == `SERIEL_STATUS_ADDR) begin
                        d_raddr <= DCache_addr_reg;
                    end
                    else begin
                        d_raddr <= DCache_addr_reg & 32'hffffffc0;
                    end
                end
                else if((mem_write_reg & !write_uncache) |
                        (mem_read_reg  & !read_uncache ))
                    d_raddr <= DCache_addr_reg & 32'hffffffc0;
            end
        end
    end

    //DCache_addr_reg0
    always @(posedge clk) begin
        if(!rstn) begin
            DCache_addr_reg0 <= 0;
        end
        else begin
            if(pipeline_enable) begin
                DCache_addr_reg0 <= DCache_addr;
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            DCache_addr_reg <= 0;
        end
        else begin
            if(pipeline_enable) begin
                DCache_addr_reg <= DCache_addr_reg0;
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            d_mem_rdata <= 0;
        end
        else begin
            if(d_rready & !d_rready_reg) begin
                d_mem_rdata <= mem_rdata;
            end
        end
    end

    // write_uncache_have_read
    // 功能：用于WRITE状态转向READ(当uncache_write未读时)和转向REFILL(当uncache_write读完时)
    always @(posedge clk) begin
        if(!rstn) begin
            write_uncache_have_read <= 0;
        end
        else begin
            if(state == `MISS & !dirty & write_uncache) begin   
                // 如果uncache的写判断不为脏，则待会儿插入完数据可直接写回缓存
                write_uncache_have_read <= 1;   
            end
            else if(state == `WRITE & write_uncache & !write_uncache_have_read & d_wready & !d_wready_reg) begin
                // 如果是uncache的写判断为脏，先进入WRITE把脏数据写回，然后再将插入完的数据写回
                write_uncache_have_read <= 1;
            end
            else if(state == `WRITE & write_uncache_have_read & d_wready & !d_wready_reg) begin    
                // 如果已经从仲裁器读出过，则将标志清零，并转到写回阶段
                write_uncache_have_read <= 0;
            end
            else if(state == `IDLE & write_uncache & !DCache_miss) begin
                write_uncache_have_read <= 1;
            end
            else if(state == `MISS & seriel_buffer_write) begin
                write_uncache_have_read <= 1;
            end
        end 
    end

    always @(posedge clk) begin
        if(state == `READ & mem_write_reg & !write_uncache & d_rready & !d_rready_reg) begin
            inserted_data_reg <= inserted_data;
        end
    end
    
    always @(posedge clk) begin
        if(!rstn) begin
            DCache_wdata_restore <= 0;
        end
        else begin
            if(state == `IDLE & !pipeline_enable) begin
                DCache_wdata_restore <= DCache_wdata;
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            tag1_restore <= 0;
            tag2_restore <= 0;
            way1_rdata_restore <= 0;
            way2_rdata_restore <= 0;
        end
        else begin  // 因为tag的出来在停顿的第一个周期，需要等一个周期  
            if(state == `IDLE & !pipeline_enable) begin //22114359
                tag1_restore <= tag1;
                tag2_restore <= tag2;
                way1_rdata_restore <= way1_rdata;
                way2_rdata_restore <= way2_rdata;
            end
        end
    end
endmodule