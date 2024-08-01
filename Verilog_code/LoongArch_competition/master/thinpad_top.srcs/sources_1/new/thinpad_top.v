`default_nettype none

module thinpad_top
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
            mulw_code       = 17'h00038,
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
            mulw_inst       = 6'h29,
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
            mulw_op         = 5'h1e,
            Offset_len      = 6  ,
            Queue_count_len = 4
)
(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入（备用，可不用）

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

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

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区
);

/* =========== Demo code begin =========== */

// PLL分频示例
wire locked, clk_10M, clk_20M;
pll_example clock_gen 
 (
  // Clock in ports
  .clk_in1(clk_50M),  // 外部时钟输入
  // Clock out ports
  .clk_out1(clk_10M), // 时钟输出1，频率在IP配置界面中设置
  .clk_out2(clk_20M), // 时钟输出2，频率在IP配置界面中设置
  // Status and control signals
  .reset(reset_btn), // PLL复位输入
  .locked(locked)    // PLL锁定指示输出，"1"表示时钟稳定，
                     // 后级电路复位信号应当由它生成（见下）
 );

reg reset_of_clk10M;
// 异步复位，同步释放，将locked信号转为后级电路的复位reset_of_clk10M
always@(posedge clk_10M or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
end

always@(posedge clk_10M or posedge reset_of_clk10M) begin
    if(reset_of_clk10M)begin
        // Your Code
    end
    else begin
        // Your Code
    end
end

CPU_top # (
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
    .mulw_code(mulw_code),
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
    .halt_inst(halt_inst),
    .mulw_inst(mulw_inst),
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
    .mulw_op(mulw_op),
    .Offset_len(Offset_len),
    .Queue_count_len(Queue_count_len)
        )
  CPU_top_inst (
    .clk(clk_50M),
    .rstn(!reset_btn),
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
    .txd(txd),
    .rxd(rxd)
  );
  
// 不使用内存、串口时，禁用其使能信号
// assign base_ram_ce_n = 1'b1;
// assign base_ram_oe_n = 1'b1;
// assign base_ram_we_n = 1'b1;

// assign ext_ram_ce_n = 1'b1;
// assign ext_ram_oe_n = 1'b1;
// assign ext_ram_we_n = 1'b1;

// 数码管连接关系示意图，dpy1同理
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

// 7段数码管译码器演示，将number用16进制显示在数码管上面
wire[7:0] number;
SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0是低位数码管
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1是高位数码管

reg[15:0] led_bits;
assign leds = led_bits;

always@(posedge clock_btn or posedge reset_btn) begin
    if(reset_btn)begin //复位按下，设置LED为初始值
        led_bits <= 16'h1;
    end
    else begin //每次按下时钟按钮，LED循环左移
        led_bits <= {led_bits[14:0],led_bits[15]};
    end
end


//图像输出演示，分辨率800x600@75Hz，像素时钟为50MHz
wire [11:0] hdata;
assign video_red = hdata < 266 ? 3'b111 : 0; //红色竖条
assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //绿色竖条
assign video_blue = hdata >= 532 ? 2'b11 : 0; //蓝色竖条
assign video_clk = clk_50M;
vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(clk_50M), 
    .hdata(hdata), //横坐标
    .vdata(),      //纵坐标
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de)
);
/* =========== Demo code end =========== */

endmodule
