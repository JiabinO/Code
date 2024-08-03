`timescale 1ns / 1ps
module tb;

wire clk_50M, clk_11M0592;

reg clock_btn = 0;         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
reg reset_btn = 0;         //BTN6手动复位按钮开关，带消抖电路，按下时为1

reg[3:0]  touch_btn;  //BTN1~BTN4，按钮开关，按下时为1
reg[31:0] dip_sw;     //32位拨码开关，拨到“ON”时为1

wire[15:0] leds;       //16位LED，输出时1点亮
wire[7:0]  dpy0;       //数码管低位信号，包括小数点，输出1点亮
wire[7:0]  dpy1;       //数码管高位信号，包括小数点，输出1点亮

wire txd;  //直连串口发送端
wire rxd;  //直连串口接收端

wire[31:0] base_ram_data; //BaseRAM数据，低8位与CPLD串口控制器共享
wire[19:0] base_ram_addr; //BaseRAM地址
wire[3:0] base_ram_be_n;  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
wire base_ram_ce_n;       //BaseRAM片选，低有效
wire base_ram_oe_n;       //BaseRAM读使能，低有效
wire base_ram_we_n;       //BaseRAM写使能，低有效

wire[31:0] ext_ram_data; //ExtRAM数据
wire[19:0] ext_ram_addr; //ExtRAM地址
wire[3:0] ext_ram_be_n;  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
wire ext_ram_ce_n;       //ExtRAM片选，低有效
wire ext_ram_oe_n;       //ExtRAM读使能，低有效
wire ext_ram_we_n;       //ExtRAM写使能，低有效

wire [22:0]flash_a;      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
wire [15:0]flash_d;      //Flash数据
wire flash_rp_n;         //Flash复位信号，低有效
wire flash_vpen;         //Flash写保护信号，低电平时不能擦除、烧写
wire flash_ce_n;         //Flash片选信号，低有效
wire flash_oe_n;         //Flash读使能信号，低有效
wire flash_we_n;         //Flash写使能信号，低有效
wire flash_byte_n;       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

//Windows需要注意路径分隔符的转义，例如"D:\\foo\\bar.bin"
parameter BASE_RAM_INIT_FILE = "D:\\github_doc\\Code\\Verilog_code\\LoongArch_competition\\master\\asm\\supervisor_la\\supervisor_la\\kernel\\test_kernel.bin"; //BaseRAM初始化文件，请修改为实际的绝对路径
parameter EXT_RAM_INIT_FILE = "D:\\github_doc\\Code\\Verilog_code\\LoongArch_competition\\master\\asm\\supervisor_la\\supervisor_la\\kernel\\ext_data.bin";    //ExtRAM初始化文件，请修改为实际的绝对路径
parameter FLASH_INIT_FILE = "/tmp/kernel.elf";    //Flash初始化文件，请修改为实际的绝对路径
`define instruction_len 33
reg [7:0] TxD_data;
reg       TxD_start;
reg [6:0] instruction_count;
reg [31:0] instruction_list [0:`instruction_len - 1];
reg [31:0] instruction_len;
reg [1:0] circular_count;
reg [31:0]address;
reg [31:0]RunD_address;
reg [31:0]RunG_address;
reg [31:0]instruction_len_times_4;
reg [31:0]search_address;
reg [31:0]search_len;
initial begin
    instruction_len = 32'h4;
    //fibonacci
    // instruction_list[0]     = 32'h0280040c;
    // instruction_list[1]     = 32'h0280040D;
    // instruction_list[2]     = 32'h15008004;
    // instruction_list[3]     = 32'h02808085;
    // instruction_list[4]     = 32'h0010358E;
    // instruction_list[5]     = 32'h028001AC;
    // instruction_list[6]     = 32'h028001CD;
    // instruction_list[7]     = 32'h2980008E;
    // instruction_list[8]     = 32'h02801084;
    // instruction_list[9]     = 32'h5FFFEC85;
    // instruction_list[10]    = 32'h4C000020;
    //stream
    // instruction_list[0]  = 32'h15002004;
    // instruction_list[1]  = 32'h15008005;
    // instruction_list[2]  = 32'h038c0006;
    // instruction_list[3]  = 32'h00101886;    
    // instruction_list[4]  = 32'h2880008c;
    // instruction_list[5]  = 32'h298000ac;
    // instruction_list[6]  = 32'h02801084;
    // instruction_list[7]  = 32'h028010a5;
    // instruction_list[8]  = 32'h5ffff086;
    // instruction_list[9]  = 32'h4c000020;
    //matrix
    instruction_list[0 ]  = 32'h15008004;
    instruction_list[1 ]  = 32'h15008205;
    instruction_list[2 ]  = 32'h15008406;
    instruction_list[3 ]  = 32'h03800807;
    instruction_list[4 ]  = 32'h00150014;
    instruction_list[5 ]  = 32'h58006e87;
    instruction_list[6 ]  = 32'h00408a8c;
    instruction_list[7 ]  = 32'h0040a68e;
    instruction_list[8 ]  = 32'h0010308c;
    instruction_list[9 ]  = 32'h001038ae;
    instruction_list[10]  = 32'h0015000d;
    instruction_list[11]  = 32'h58004da7;
    instruction_list[12]  = 32'h28800193;
    instruction_list[13]  = 32'h0040a5a8;
    instruction_list[14]  = 32'h001020c8;
    instruction_list[15]  = 32'h001501d0;
    instruction_list[16]  = 32'h0015000f;
    instruction_list[17]  = 32'h580029e7;
    instruction_list[18]  = 32'h028005ef;
    instruction_list[19]  = 32'h28800211;
    instruction_list[20]  = 32'h28800112;
    instruction_list[21]  = 32'h001c4671;
    instruction_list[22]  = 32'h02801108;
    instruction_list[23]  = 32'h02801210;
    instruction_list[24]  = 32'h00104651;
    instruction_list[25]  = 32'h29bff111;
    instruction_list[26]  = 32'h53ffdfff;
    instruction_list[27]  = 32'h028005ad;
    instruction_list[28]  = 32'h0288018c;
    instruction_list[29]  = 32'h53ffbbff;
    instruction_list[30]  = 32'h02800694;
    instruction_list[31]  = 32'h53ff9bff;
    instruction_list[32]  = 32'h4c000020;
    RunD_address = 32'h80100000;
    RunG_address = 32'h80100000;
    search_address = 32'h80400000;
    search_len = 32'h300;
    instruction_len_times_4 = `instruction_len << 2;
end

async_transmitter #(.ClkFrequency(50000000),.Baud(384000)) async_transmitter_inst (
    .clk(clk_50M),
    .TxD_start(TxD_start),
    .TxD_data(TxD_data),
    .TxD(rxd),
    .TxD_busy(TxD_busy)
  );

initial begin
    TxD_start = 0;
    TxD_data = 8'h0;
    instruction_count = 0;
    circular_count = 3;
    address = 32'h80100000;
    // //lab2
    // #347690 TxD_start = 1;
    // TxD_data = 8'h54;
    // #20 TxD_start = 0;
    // lab3
    #1080450                        // 与波特率有关，得测一测，等待串口输入的时间
    repeat(`instruction_len) begin  // 串口输入用户程序
        TxD_start = 1;
        TxD_data = 8'h41;           // A
        #20 TxD_start = 0;

        repeat(4) begin             // 地址发送
            #32920 TxD_start = 1;   
            circular_count = circular_count + 1;
            case(circular_count)
                0: TxD_data = address[7:0];
                1: TxD_data = address[15:8];
                2: TxD_data = address[23:16];
                3: TxD_data = address[31:24];
            endcase
            #20 TxD_start = 0;
        end
        address = address + 4;

        repeat(4) begin             // 长度发送
            #32920 TxD_start = 1;
            circular_count = circular_count + 1;
            case(circular_count)
                0: TxD_data = instruction_len[7:0];
                1: TxD_data = instruction_len[15:8];
                2: TxD_data = instruction_len[23:16];
                3: TxD_data = instruction_len[31:24];
            endcase
            #20 TxD_start = 0;
        end
        
        repeat(4) begin             // 指令发送
            #32920 TxD_start = 1;
            circular_count = circular_count + 1;
            case(circular_count)
                0: TxD_data = instruction_list[instruction_count][7:0];
                1: TxD_data = instruction_list[instruction_count][15:8];
                2: TxD_data = instruction_list[instruction_count][23:16];
                3: TxD_data = instruction_list[instruction_count][31:24];
            endcase
            #20 TxD_start = 0;
        end

        #32920 instruction_count = instruction_count + 1;
    end

    // #32920 TxD_start = 1;
    // TxD_data = 8'h44;               // D 查看用户区间内存
    // #20 TxD_start = 0;

    // repeat(4) begin                 // 长度发送
    //     #32920 TxD_start = 1;
    //     circular_count = circular_count + 1;
    //     case(circular_count)
    //         0: TxD_data = RunD_address[7:0];
    //         1: TxD_data = RunD_address[15:8];
    //         2: TxD_data = RunD_address[23:16];
    //         3: TxD_data = RunD_address[31:24];
    //     endcase
    //     #20 TxD_start = 0;
    // end

    // repeat(4) begin                 // 长度发送
    //     #32920 TxD_start = 1;
    //     circular_count = circular_count + 1;
    //     case(circular_count)
    //         0: TxD_data = instruction_len_times_4[7:0];
    //         1: TxD_data = instruction_len_times_4[15:8];
    //         2: TxD_data = instruction_len_times_4[23:16];
    //         3: TxD_data = instruction_len_times_4[31:24];
    //     endcase
    //     #20 TxD_start = 0;
    // end
    // // #1094540 //stream
    // #3547320 // matrix
    // // #1197340 //fibonacci
    TxD_data = 8'h47;       // G， 时间需要调
    TxD_start = 1;
    #20     TxD_start = 0;

    repeat(4) begin                 // 用户程序运行地址发送
        #32920 TxD_start = 1;
        circular_count = circular_count + 1;
        case(circular_count)
            0: TxD_data = RunD_address[7:0];
            1: TxD_data = RunD_address[15:8];
            2: TxD_data = RunD_address[23:16];
            3: TxD_data = RunD_address[31:24];
        endcase
        #20 TxD_start = 0;
    end

    // #159400
    // TxD_start = 1;
    // TxD_data = 8'h44;               // D 查看用户区间内存
    // #20 TxD_start = 0;

    // repeat(4) begin                 // 长度发送
    //     #32920 TxD_start = 1;
    //     circular_count = circular_count + 1;
    //     case(circular_count)
    //         0: TxD_data = search_address[7:0];
    //         1: TxD_data = search_address[15:8];
    //         2: TxD_data = search_address[23:16];
    //         3: TxD_data = search_address[31:24];
    //     endcase
    //     #20 TxD_start = 0;
    // end

    // repeat(4) begin                 // 长度发送
    //     #32920 TxD_start = 1;
    //     circular_count = circular_count + 1;
    //     case(circular_count)
    //         0: TxD_data = search_len[7:0];
    //         1: TxD_data = search_len[15:8];
    //         2: TxD_data = search_len[23:16];
    //         3: TxD_data = search_len[31:24];
    //     endcase
    //     #20 TxD_start = 0;
    // end
end


//     #3958950 TxD_data = 8'h47;// G
//     TxD_start = 1;
//     #20 TxD_start = 0;
//     #95000 TxD_data = 8'h00;
//     TxD_start = 1;
//     #20 TxD_start = 0;
//     #95000 TxD_data = 8'h00;
//     TxD_start = 1;
//     #20 TxD_start = 0;
//     #95000 TxD_data = 8'h10;
//     TxD_start = 1;
//     #20 TxD_start = 0;
//     #95000 TxD_data = 8'h80;  // 地址
//     TxD_start = 1;
//     #20 TxD_start = 0;

//     #299100 TxD_data = 8'h44;  // D
//     TxD_start = 1;
//     #20 TxD_start = 0;
//     #95000 TxD_data = 8'h00;
//     TxD_start = 1;
//     #20 TxD_start = 0;
//     #95000 TxD_data = 8'h00;
//     TxD_start = 1;
//     #20 TxD_start = 0;
//     #95000 TxD_data = 8'h40;
//     TxD_start = 1;
//     #20 TxD_start = 0;
//     #95000 TxD_data = 8'h80;  // 地址
//     TxD_start = 1;
//     #20 TxD_start = 0;

//     #95000 TxD_data = 8'h20;
//     TxD_start = 1;
//     #20 TxD_start = 0;
//     #95000 TxD_data = 8'h00;
//     TxD_start = 1;
//     #20 TxD_start = 0;
//     #95000 TxD_data = 8'h00;
//     TxD_start = 1;
//     #20 TxD_start = 0;
//     #95000 TxD_data = 8'h00;  // 长度
//     TxD_start = 1;
//     #20 TxD_start = 0;

// end
// assign rxd = 1'b1; //idle state

initial begin 
    //在这里可以自定义测试输入序列，例如：
    dip_sw = 32'h2;
    touch_btn = 0;
    reset_btn = 1;
    #100;
    reset_btn = 0;
    for (integer i = 0; i < 20; i = i+1) begin
        #100; //等待100ns
        clock_btn = 1; //按下手工时钟按钮
        #100; //等待100ns
        clock_btn = 0; //松开手工时钟按钮
    end
end

// 待测试用户设计
thinpad_top dut(
    .clk_50M(clk_50M),
    .clk_11M0592(clk_11M0592),
    .clock_btn(clock_btn),
    .reset_btn(reset_btn),
    .touch_btn(touch_btn),
    .dip_sw(dip_sw),
    .leds(leds),
    .dpy1(dpy1),
    .dpy0(dpy0),
    .txd(txd),
    .rxd(rxd),
    .base_ram_data(base_ram_data),
    .base_ram_addr(base_ram_addr),
    .base_ram_ce_n(base_ram_ce_n),
    .base_ram_oe_n(base_ram_oe_n),
    .base_ram_we_n(base_ram_we_n),
    .base_ram_be_n(base_ram_be_n),
    .ext_ram_data(ext_ram_data),
    .ext_ram_addr(ext_ram_addr),
    .ext_ram_ce_n(ext_ram_ce_n),
    .ext_ram_oe_n(ext_ram_oe_n),
    .ext_ram_we_n(ext_ram_we_n),
    .ext_ram_be_n(ext_ram_be_n),
    .flash_d(flash_d),
    .flash_a(flash_a),
    .flash_rp_n(flash_rp_n),
    .flash_vpen(flash_vpen),
    .flash_oe_n(flash_oe_n),
    .flash_ce_n(flash_ce_n),
    .flash_byte_n(flash_byte_n),
    .flash_we_n(flash_we_n)
);
// 时钟源
clock osc(
    .clk_11M0592(clk_11M0592),
    .clk_50M    (clk_50M)
);

// BaseRAM 仿真模型
sram_model base1(/*autoinst*/
            .DataIO(base_ram_data[15:0]),
            .Address(base_ram_addr[19:0]),
            .OE_n(base_ram_oe_n),
            .CE_n(base_ram_ce_n),
            .WE_n(base_ram_we_n),
            .LB_n(base_ram_be_n[0]),
            .UB_n(base_ram_be_n[1]));
sram_model base2(/*autoinst*/
            .DataIO(base_ram_data[31:16]),
            .Address(base_ram_addr[19:0]),
            .OE_n(base_ram_oe_n),
            .CE_n(base_ram_ce_n),
            .WE_n(base_ram_we_n),
            .LB_n(base_ram_be_n[2]),
            .UB_n(base_ram_be_n[3]));
// ExtRAM 仿真模型
sram_model ext1(/*autoinst*/
            .DataIO(ext_ram_data[15:0]),
            .Address(ext_ram_addr[19:0]),
            .OE_n(ext_ram_oe_n),
            .CE_n(ext_ram_ce_n),
            .WE_n(ext_ram_we_n),
            .LB_n(ext_ram_be_n[0]),
            .UB_n(ext_ram_be_n[1]));
sram_model ext2(/*autoinst*/
            .DataIO(ext_ram_data[31:16]),
            .Address(ext_ram_addr[19:0]),
            .OE_n(ext_ram_oe_n),
            .CE_n(ext_ram_ce_n),
            .WE_n(ext_ram_we_n),
            .LB_n(ext_ram_be_n[2]),
            .UB_n(ext_ram_be_n[3]));
// Flash 仿真模型
x28fxxxp30 #(.FILENAME_MEM(FLASH_INIT_FILE)) flash(
    .A(flash_a[1+:22]), 
    .DQ(flash_d), 
    .W_N(flash_we_n),    // Write Enable 
    .G_N(flash_oe_n),    // Output Enable
    .E_N(flash_ce_n),    // Chip Enable
    .L_N(1'b0),    // Latch Enable
    .K(1'b0),      // Clock
    .WP_N(flash_vpen),   // Write Protect
    .RP_N(flash_rp_n),   // Reset/Power-Down
    .VDD('d3300), 
    .VDDQ('d3300), 
    .VPP('d1800), 
    .Info(1'b1));

initial begin 
    wait(flash_byte_n == 1'b0);
    $display("8-bit Flash interface is not supported in simulation!");
    $display("Please tie flash_byte_n to high");
    $stop;
end

// 从文件加载 BaseRAM
initial begin 
    reg [31:0] tmp_array[0:1048575];
    integer n_File_ID, n_Init_Size;
    n_File_ID = $fopen(BASE_RAM_INIT_FILE, "rb");
    if(!n_File_ID)begin 
        n_Init_Size = 0;
        $display("Failed to open BaseRAM init file");
    end else begin
        n_Init_Size = $fread(tmp_array, n_File_ID);
        n_Init_Size /= 4;
        $fclose(n_File_ID);
    end
    $display("BaseRAM Init Size(words): %d",n_Init_Size);
    for (integer i = 0; i < n_Init_Size; i++) begin
        base1.mem_array0[i] = tmp_array[i][24+:8];
        base1.mem_array1[i] = tmp_array[i][16+:8];
        base2.mem_array0[i] = tmp_array[i][8+:8];
        base2.mem_array1[i] = tmp_array[i][0+:8];
    end
end

// 从文件加载 ExtRAM
initial begin 
    reg [31:0] tmp_array[0:1048575];
    integer n_File_ID, n_Init_Size;
    n_File_ID = $fopen(EXT_RAM_INIT_FILE, "rb");
    if(!n_File_ID)begin 
        n_Init_Size = 0;
        $display("Failed to open ExtRAM init file");
    end else begin
        n_Init_Size = $fread(tmp_array, n_File_ID);
        n_Init_Size /= 4;
        $fclose(n_File_ID);
    end
    $display("ExtRAM Init Size(words): %d",n_Init_Size);
    for (integer i = 0; i < n_Init_Size; i++) begin
        ext1.mem_array0[i] = tmp_array[i][24+:8];
        ext1.mem_array1[i] = tmp_array[i][16+:8];
        ext2.mem_array0[i] = tmp_array[i][8+:8];
        ext2.mem_array1[i] = tmp_array[i][0+:8];
    end
end
endmodule
