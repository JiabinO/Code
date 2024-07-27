`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/10 19:55:00
// Design Name: 
// Module Name: Arbiter
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


module Arbiter
    #(parameter Offset_len = 6)
    (
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
        output wire ext_ram_we_n,       //ExtRAM写使能，低有效

        input               clk, rstn, 
        //ICache
        input               i_rvalid,
        input       [31:0]  i_addr,
        input               i_rinterrupt,
        
        //DCache
        input               d_rvalid,
        input               d_wvalid,
        input       [31:0]  d_raddr,
        input       [31:0]  d_waddr,
        input       [(1 << (Offset_len + 3)) - 1:0] d_wdata,
        output  reg [(1 << (Offset_len + 3)) - 1:0] mem_rdata,
        output  reg         d_rready,
        output  reg         d_wready,
        output  reg         i_rready,
        
        //串口
        input wire rxd,
        output reg txd
    );

    reg [(1 << (Offset_len + 3)) - 1:0] shift_buffer;
    reg [Offset_len - 2:0]   buf_shift_count;
    reg [1:0]   state;
    reg [31:0]  read_address;
    wire[31:0]  Base_rdata;
    wire[31:0]  Ext_rdata;
    reg [31:0]  write_data;
    reg [31:0]  mux_read_data;
    reg         Base_we;
    reg         Ext_we;
    reg         d_rvalid_reg;
    reg         d_wvalid_reg;
    reg         i_rvalid_reg;
    reg         d_rvalid_reg_hold;
    reg         d_wvalid_reg_hold;
    reg         i_rvalid_reg_hold;
    reg [31:0]  write_address;
    wire [31:0] operation_address;
    reg [7:0]   seriel_status_reg;   //串口状态寄存器
    reg         seriel_sel;
    reg [7:0]   seriel_data_reg;     //串口读和写字节寄存器

    reg [(1 << (Offset_len + 3)) - 1:0] seriel_mem_reg;

    assign seriel_mem_reg = {{30{1'b0}},ext_uart_ready,!ext_uart_busy,{24{1'b0}},seriel_data_reg, {((1 << (Offset_len + 3)) - 64){1'b0}}};
    assign seriel_sel = d_raddr == 32'hbfd003c0;
    assign seriel_status_reg = {6'h0, {ext_uart_ready}, {!ext_uart_busy}};

    //直连串口接收发送演示，从直连串口收到的数据再发送出去
    wire [7:0] ext_uart_rx;
    reg  [7:0] ext_uart_buffer, ext_uart_tx;
    wire ext_uart_ready, ext_uart_clear, ext_uart_busy;
    reg ext_uart_start, ext_uart_avai;
        
    assign number = ext_uart_buffer;

    async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //接收模块，9600无检验位
    ext_uart_r(
        .clk(clk),                        //外部时钟信号
        .RxD(rxd),                        //外部串行信号输入
        .RxD_data_ready(ext_uart_ready),  //数据接收到标志
        .RxD_clear(ext_uart_clear),       //清除接收标志
        .RxD_data(ext_uart_rx)            //接收到的一字节数据
    );

    assign ext_uart_clear = ext_uart_ready; //收到数据的同时，清除标志，因为数据已取到ext_uart_buffer中
    // always @(posedge clk) begin //接收到缓冲区ext_uart_buffer
    //     if(ext_uart_ready)begin
    //         ext_uart_buffer <= ext_uart_rx;
    //         ext_uart_avai <= 1;
    //     end else if(!ext_uart_busy && ext_uart_avai)begin 
    //         ext_uart_avai <= 0;
    //     end
    // end
    // always @(posedge clk) begin //将缓冲区ext_uart_buffer发送出去
    //     if(!ext_uart_busy && ext_uart_avai)begin 
    //         ext_uart_tx <= ext_uart_buffer;
    //         ext_uart_start <= 1;
    //     end else begin 
    //         ext_uart_start <= 0;
    //     end
    // end

    //ext_uart_tx 在st.b命令触发后更新ext_uart_tx为刚刚存储的数据
    always @(posedge clk) begin
        if(!rstn) begin
            ext_uart_tx <= 0;
            ext_uart_start <= 0;
        end
        else begin
            if(state == 3 & seriel_sel & buf_shift_count == 5'h01) begin
                ext_uart_tx <= d_wdata[(1 << (Offset_len + 3)) - 57:(1 << (Offset_len + 3)) - 64];
                ext_uart_start <= 1;
            end
            else begin
                if(!ext_uart_busy) begin    //start持续到发送器有空闲响应才置为0
                    ext_uart_start <= 0;
                end
            end
        end
    end
    
    async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发送模块，9600无检验位
    ext_uart_t(
        .clk(clk),                    //外部时钟信号
        .TxD(txd),                    //串行信号输出
        .TxD_busy(ext_uart_busy),     //发送器忙状态指示
        .TxD_start(ext_uart_start),   //开始发送信号
        .TxD_data(ext_uart_tx)        //待发送的数据
    );

    assign mux_read_data = read_address[22] ? ext_ram_data : base_ram_data;
    assign operation_address = state == 3 ? write_address : read_address;
    assign base_ram_oe_n = !base_ram_we_n;
    assign ext_ram_oe_n = !ext_ram_we_n;
    assign base_ram_data = base_ram_we_n ?  32'hzzzzzzzz /*we失效时为input的读数据*/: write_data;
    assign ext_ram_data = ext_ram_we_n ? 32'hzzzzzzzz /*we失效时为input的读数据*/: write_data;
    assign base_ram_addr = operation_address[21:2];
    assign ext_ram_be_n = 0;
    assign base_ram_be_n = 0;
    assign ext_ram_addr = operation_address[21:2];
    assign base_ram_ce_n = operation_address[22];
    assign ext_ram_ce_n = !base_ram_ce_n;
    assign base_ram_we_n = !Base_we;
    assign ext_ram_we_n = !Ext_we;    
    
    //暂定这里的base和ext用的是分布式存储器，到时候接到发布包再继续改
    //优先级：ir > dr > dw
    always @(posedge clk) begin
        if(!rstn) begin
            state <= 0;
        end
        else begin
            if(state == 0) begin
                if(i_rvalid_reg_hold) begin
                    state <= 1;     //ir
                end
                else if(d_rvalid_reg_hold) begin
                    state <= 2;
                end
                else if(d_wvalid_reg_hold) begin
                    state <= 3;
                end
            end
            else if(state == 1 ) begin
                if(i_rinterrupt) begin
                    state <= 0;
                end
                else if(buf_shift_count == 0) begin
                    if(d_rvalid_reg_hold) begin
                        state <= 2;
                    end
                    else if(d_wvalid_reg_hold) begin
                        state <= 3;
                    end
                    else begin
                        state <= 0;
                    end
                end
            end
            else if(state == 2 && buf_shift_count == 0) begin
                if(i_rvalid_reg_hold) begin
                    state <= 1;
                end
                else if(d_wvalid_reg_hold) begin    
                    state <= 3;
                end
                else begin
                    state <= 0;
                end
            end
            else if(state == 3 && buf_shift_count == 0) begin
                if(i_rvalid_reg_hold) begin
                    state <= 1;
                end
                else if(d_rvalid_reg_hold) begin
                    state <= 2;
                end
                else begin
                    state <= 0;
                end
            end
        end
    end

    //buf_shift_count
    always @(posedge clk) begin     //置数逻辑：某个hold_reg的上升沿
        if(!rstn) begin
            buf_shift_count <= 0;
        end
        else begin
            if(i_rinterrupt) begin
                buf_shift_count <= 0;
            end
            else if(|buf_shift_count) begin
                buf_shift_count <= buf_shift_count - 1;
            end
            // else if(!i_rvalid_reg_hold) begin
            //     if(d_rvalid_reg_hold & d_raddr == 32'hbfd003c0) begin       //串口直接读出数据，不需要计数读取
            //         buf_shift_count <= 0;
            //     end 
            //     else if(d_wvalid_reg_hold & d_waddr == 32'hbfd003c0) begin  //串口直接写数据，不需要计数写入
            //         buf_shift_count <= 0;
            //     end
            // end
            else if((state == 0 && (i_rvalid_reg_hold || d_rvalid_reg_hold || d_wvalid_reg_hold))) begin
                buf_shift_count <= (1 << (Offset_len - 2));
            end
            else if((state == 1 && buf_shift_count == 0 && (d_rvalid_reg_hold || d_wvalid_reg_hold))) begin
                if((d_rvalid_reg_hold & d_raddr == 32'hbfd003c0) | (!d_rvalid_reg_hold & d_wvalid_reg_hold & d_waddr == 32'hbfd003c0)) begin
                    buf_shift_count <= 1;
                end
                else begin
                    buf_shift_count <= (1 << (Offset_len - 2));
                end
            end
            else if((state == 2 && buf_shift_count == 0 && (i_rvalid_reg_hold || d_wvalid_reg_hold))) begin
                if(i_rvalid_reg_hold) begin
                    buf_shift_count <= (1 << (Offset_len - 2));
                end
                else begin
                    if(d_wvalid_reg_hold & d_waddr == 32'hbfd003c0) begin
                        buf_shift_count <= 1;
                    end 
                    else begin
                        buf_shift_count <= (1 << (Offset_len - 2));
                    end
                end
            end
            else if((state == 3 && buf_shift_count == 0 && (i_rvalid_reg_hold || d_rvalid_reg_hold))) begin
                if(i_rvalid_reg_hold) begin
                    buf_shift_count <= (1 << (Offset_len - 2));
                end
                else begin
                    if(d_rvalid_reg_hold & d_raddr == 32'hbfd003c0) begin
                        buf_shift_count <= 1;
                    end 
                    else begin
                        buf_shift_count <= (1 << (Offset_len - 2));
                    end
                end
            end
        end
    end

    

    //shift_buffer
    //高位存放高地址数据
    always @(posedge clk) begin
        if(!rstn) begin
            shift_buffer <= 0;
        end
        else begin
            if(|buf_shift_count) begin
                shift_buffer <= {shift_buffer[(1 << Offset_len + 3) - 33:0], mux_read_data};
            end
        end
    end

    //read_address
    always @(*) begin
        if(state == 1) begin
            read_address = i_addr + 4 * buf_shift_count - 4;
        end
        else begin
            read_address = d_raddr + 4 * buf_shift_count - 4;
        end
    end

    reg [Offset_len-1+2:0] shifted_buf_shift_count;  // 4 * buf_shift_count 的结果位宽是 Offset_len-1 + 2 位
    reg [32:0] extended_write_address;              // d_waddr + shifted_buf_shift_count 的结果可能是 33 位

    always @(*) begin
        shifted_buf_shift_count = buf_shift_count << 2;  // 相当于乘以 4
        extended_write_address = {1'b0, d_waddr} + shifted_buf_shift_count;
        write_address = extended_write_address[31:0];    // 取低 32 位
    end
    //mem_rdata
    always @(posedge clk) begin
        if(!rstn) begin
            mem_rdata <= 0;
        end
        else begin
            if((state == 1 || state == 2) && buf_shift_count == 0) begin
                if(state == 2 & seriel_sel) begin
                    mem_rdata <= {{24{1'b0}},seriel_status_reg, {24{1'b0}}, seriel_data_reg, {{((1 << Offset_len + 3) - 64){1'b0}}}};
                end
                else begin
                    mem_rdata <= shift_buffer;
                end
            end
        end
    end

    //write_data
    mux_write_data # (
        .Offset_len(Offset_len),
        .Segment_width(32)
    )
    mux_write_data_inst (
        .buf_shift_count(buf_shift_count),
        .d_wdata(d_wdata),
        .write_data_mux(write_data)
    );

    //i_rready
    always @(posedge clk) begin
        if(!rstn) begin
            i_rready <= 1;
        end
        else begin
            if(i_rvalid_reg_hold) begin
                i_rready <= 0; 
            end
            else if(state == 1 && buf_shift_count == 0) begin
                i_rready <= 1;
            end
        end
    end

    //d_rready
    always @(posedge clk) begin
        if(!rstn) begin
            d_rready <= 1;
        end
        else begin
            if(d_rvalid_reg_hold) begin
                d_rready <= 0;
            end
            else if(state == 2 && buf_shift_count == 0) begin
                d_rready <= 1;
            end
        end
    end

    //d_wready
    always @(posedge clk) begin
        if(!rstn) begin
            d_wready <= 1;
        end
        else begin
            if(d_wvalid_reg_hold) begin
                d_wready <= 0;
            end
            else if(state == 3 && buf_shift_count == 0) begin
                d_wready <= 1;
            end
        end
    end

    //Basewe与Extwe
    always @(posedge clk) begin
        if(!rstn) begin
            Ext_we <= 0;
            Base_we <= 0;
        end
        else begin  //写请求时才对存储器进行写
            if( ((state == 0 && !i_rvalid_reg_hold && !d_rvalid_reg_hold)   || 
                (state == 1 && buf_shift_count == 0 && !d_rvalid_reg_hold)  || 
                (state == 2 && buf_shift_count == 0 && !i_rvalid_reg_hold)) &&
                d_wvalid_reg_hold)  begin
                if(!seriel_sel) begin
                    if(d_waddr[22]) begin
                        Ext_we <= 1;
                    end
                    else begin
                        Base_we <= 1;
                    end
                end
            end
            else if(state == 3 && buf_shift_count == 0) begin
                Ext_we <= 0;
                Base_we <= 0;
            end
        end
    end

    always @(posedge clk) begin
        i_rvalid_reg <= i_rvalid;
    end

    always @(posedge clk) begin
        d_rvalid_reg <= d_rvalid;
    end

    always @(posedge clk) begin
        d_wvalid_reg <= d_wvalid;
    end

    always @(posedge clk) begin
        if(!rstn) begin
            i_rvalid_reg_hold <= 0;
        end
        else begin
            if(i_rinterrupt) begin
                i_rvalid_reg_hold <= 0;
            end
            else if(i_rvalid & !i_rvalid_reg) begin //当仲裁器不是空闲状态时，将中间接收到的valid信号存下来
                i_rvalid_reg_hold <= 1;
            end
            else if (state == 1) begin  //该信号被处理，清空接收到的信号
                i_rvalid_reg_hold <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            d_rvalid_reg_hold <= 0;
        end
        else begin
            if(d_rvalid & !d_rvalid_reg) begin
                d_rvalid_reg_hold <= 1;
            end
            else if (state == 2) begin  //该信号被处理，清空接收到的信号
                d_rvalid_reg_hold <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            d_wvalid_reg_hold <= 0;
        end
        else begin
            if(d_wvalid & !d_wvalid_reg) begin
                d_wvalid_reg_hold <= 1;
            end
            else if (state == 3) begin  //该信号被处理，清空接收到的信号
                d_wvalid_reg_hold <= 0;
            end
        end
    end


    always @(posedge clk) begin
        if(state == 3 & seriel_sel) begin      //st.b写入的内容
            seriel_data_reg <= d_wdata[(1 << (Offset_len + 3)) - 57:(1 << (Offset_len + 3)) - 64];
        end
        else if(ext_uart_ready) begin          //串口读到的内容
            seriel_data_reg <= ext_uart_rx;
        end
    end
endmodule
