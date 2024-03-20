`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/06 19:34:10
// Design Name: 
// Module Name: DIF
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


module DIF(
    input clk, rstn,
    input flag_rx ,  //1-scan的指令/数据 准备好了 0-没有
    input [31:0] din_rx,
    input ack_rx, ack_tx,
    output reg req_rx, req_tx ,
    output reg [31:0] dout_tx,
    output reg type_tx,
    output reg data_mode//如果为0，传输数据；如果为1，传输指令
    );
    assign type_tx = 0;
    assign data_mode = 0;
    reg mode;
    reg mode_pre;
    reg flag_rx_pre;
    reg [15:0] w_add, r_add;
    reg [31:0] data;
    reg [31:0] da_rdata, IP_rdata , rf_data,da_rwdata,IP_rwdata;
    reg IP_we=0, da_we;
    reg sign;
    reg [6:0] reg_ascii,ip_ascii,da_ascii;
    wire [31:0] dpo1,dpo2;
    reg [4:0] reg_raddr;
    reg flag_rx_pre2;
    reg [31:0] din_rx_pre;
    reg [3:0] R_sequence;
    reg [2:0] R_inner_count;
    wire [31:0] rf_dout_data;   
    reg ack_tx_pre;

    IP_memory  mem1 (
        .a(w_add),          // input wire [15 : 0] a
        .d(data),           // input wire [31 : 0] d
        .dpra(r_add),       // input wire [15 : 0] dpra
        .clk(clk),          // input wire clk
        .we(IP_we),         // input wire we
        .spo(IP_rwdata),    // output wire [31 : 0] spo
        .dpo(IP_rdata)      // output wire [31 : 0] dpo
      );
      data_memory  mem2 (
        .a(w_add),          // input wire [15 : 0] a
        .d(data),           // input wire [31 : 0] d
        .dpra(r_add),       // input wire [15 : 0] dpra
        .clk(clk),          // input wire clk
        .we(da_we),         // input wire we
        .spo(da_rwdata),    // output wire [31 : 0] spo
        .dpo(da_rdata)      // output wire [31 : 0] dpo
      );

    
    register_file # (
      .ADDR_WIDTH(5),
      .DATA_WIDTH(32)
    )
    register_file_inst (
      .clk(clk),
      .ra0(reg_raddr),
      .ra1(0),
      .rd0(rf_data),
      .rd1(rf_dout_data),
      .wa(0),
      .wd(0),
      .we(0)
    );
    reg ack_tx_pre2;
    reg [5:0] R_State;

//******R命令状态机**************************************************************************************************
    //R命令输出序列计数器
    counter # (
      .WIDTH(6),
      .RST_VLU(0)
    )
    R_counter (
      .clk(clk),
      .rstn(rstn),
      .pe(~mode && ~|R_State && flag_rx_pre2 && din_rx == 32'h02000000),//R命令到来时置数
      .ce(|R_State && ~|R_sequence && ~ack_tx && ack_tx_pre), //TODONE
      .din(32),
      .q(R_State)
    );
    
    //单个寄存器的输出状态机
    counter # (
      .WIDTH(4),
      .RST_VLU(0)
    )
    R_State_count (
      .clk(clk),
      .rstn(rstn),
      .pe((R_State>1 || ( din_rx_pre != 32'h02000000 && din_rx == 32'h02000000 && ~mode)) && ~|R_sequence && ack_tx),//处于R命令输出状态且输出完了一个寄存器内容时则进行置数，准备下一个寄存器信息的输出
      .ce(R_State && ~ack_tx && ack_tx_pre && R_sequence),//非零时一直递减计数               **需要增加tx接收到后的响应才进行计数的条件
      .din(13),//总共十二个状态 1-"R" 2-寄存器的编号十位上的数字，如果没有则为空"\0"，有则为该位上的数字"1"、"2"、"3" 3-寄存器的编号个位上的数字"0"、"1"、"2"、"3"、"4"、"5"、"6"、"7"、"8"、"9"
                            // 4-"=" 5-"R[7]" 6-"R[6]" 7-"R[5]" 8-"R[4]" 9-"-" 10-"R[3]" 11-"R[2]" 12-"R[1]" 13-"R[0]" 14-"\n"
      .q(R_sequence)
    );
    
    //寄存器内部8个hex数据读取计数器
    counter # (
      .WIDTH(3),
      .RST_VLU(0)
    )
    R_inner_data(
        .clk(clk),
        .rstn(rstn),
        .pe((R_State>1 || ( din_rx_pre != 32'h02000000 && din_rx == 32'h02000000 && ~mode))&&~|R_inner_count && ack_tx),//R命令持续期间且数据读取计数器为0时置数
        .ce(|R_inner_count && ack_tx && R_sequence < 10 && R_sequence > 0 && R_sequence != 5),//tx响应之后读下四位数据
        .din(7),
        .q(R_inner_count)
    );
    
    
    //reg_raddr寄存器读地址的更新
    always @(posedge clk)begin
        if(~rstn)begin
            reg_raddr<=0;
        end
        else begin
            if( R_State && R_sequence==1 && ack_tx)//如果R命令的输出没结束且结束了当前地址数据的输出，地址自增
            begin
                reg_raddr<=reg_raddr+1;
            end
        end
    end
    //寄存器内部读取数据
    reg [3:0] reg_hex;

    always@(*)begin
        case(R_inner_count)
            7:reg_hex=rf_data[31:28];
            6:reg_hex=rf_data[27:24];
            5:reg_hex=rf_data[23:20];
            4:reg_hex=rf_data[19:16];
            3:reg_hex=rf_data[15:12];
            2:reg_hex=rf_data[11:8];
            1:reg_hex=rf_data[7:4];
            0:reg_hex=rf_data[3:0];
        endcase
    end

    //对寄存器中数据的译码
    H2C_5  H2C_5_inst (
      .din(reg_hex),
      .ascii_num(reg_ascii)
    );
//***************I[a]命令状态机***************************************************************************************
//输出来自于spo,需要改变r_add来读取内容

    reg [4:0] I_State;//22个状态
    reg [2:0] I_inner_count;//指令内部hex计数器
    reg [3:0] I_inner_hex_data;
    
    counter # (
      .WIDTH(5),
      .RST_VLU(0)
    )
    I_a (
        .clk(clk),
        .rstn(rstn),
        .pe(din_rx[31:24]==8'h01 && ~mode && ~|I_State && flag_rx_pre),//接收到I指令后置数
        .ce(|I_State&&~ack_tx&&ack_tx_pre),//tx响应之后进入下个状态
        .din(22),
        .q(I_State)
    );
    counter # (
      .WIDTH(3),
      .RST_VLU(0)
    )
    I_inner_counter (
        .clk(clk),
        .rstn(rstn),
        .pe(din_rx[31:24]==8'h01 && ~|I_State),//接收到I指令后置数
        .ce(I_State > 0 && I_State < 10 && I_State != 6 && |I_inner_count && ack_tx_pre2 && ~ack_tx_pre),//当状态机准备输出指令数据且没输完指令数据时
        .din(7),
        .q(I_inner_count)
    );

    always@(posedge clk)begin
        ack_tx_pre2 <= ack_tx_pre;
    end
    always@(*)begin
        case(I_inner_count)
            7:I_inner_hex_data=IP_rdata[31:28];
            6:I_inner_hex_data=IP_rdata[27:24];
            5:I_inner_hex_data=IP_rdata[23:20];
            4:I_inner_hex_data=IP_rdata[19:16];
            3:I_inner_hex_data=IP_rdata[15:12];
            2:I_inner_hex_data=IP_rdata[11:8];
            1:I_inner_hex_data=IP_rdata[7:4];
            0:I_inner_hex_data=IP_rdata[3:0];
        endcase
    end

    always@(posedge clk)begin
        ack_tx_pre<=ack_tx;
    end
    H2C_5  H2C_IP (
      .din(I_inner_hex_data),
      .ascii_num(ip_ascii)
    );
//*******************D[a]命令*******************************************
    reg [4:0] D_State;//22个状态
    reg [2:0] D_inner_count;//指令内部hex计数器
    reg [3:0] D_inner_hex_data;
    counter # (
      .WIDTH(5),
      .RST_VLU(0)
    )
    D_mM (
        .clk(clk),
        .rstn(rstn),
        .pe(din_rx[31:24]==8'h05 && ~mode && ~|D_State && flag_rx_pre),//接收到I指令后置数
        .ce(D_State&&~ack_tx&&ack_tx_pre),//tx响应之后进入下个状态
        .din(22),
        .q(D_State)
    );
    counter # (
      .WIDTH(3),
      .RST_VLU(0)
    )
    D_inner_counter (
        .clk(clk),
        .rstn(rstn),
        .pe(din_rx[31:24]==8'h05 && ~|D_State),//接收到D指令后置数
        .ce(D_State>0&&D_State<10&&D_State!=6&&|D_inner_count&&ack_tx_pre2&&~ack_tx_pre),//当状态机准备输出指令数据且没输完指令数据时
        .din(7),
        .q(D_inner_count)
    );

    always@(*)begin
        case(D_inner_count)
            7:D_inner_hex_data=da_rdata[31:28];
            6:D_inner_hex_data=da_rdata[27:24];
            5:D_inner_hex_data=da_rdata[23:20];
            4:D_inner_hex_data=da_rdata[19:16];
            3:D_inner_hex_data=da_rdata[15:12];
            2:D_inner_hex_data=da_rdata[11:8];
            1:D_inner_hex_data=da_rdata[7:4];
            0:D_inner_hex_data=da_rdata[3:0];
        endcase
    end

    H2C_5  DA (
      .din(D_inner_hex_data),
      .ascii_num(da_ascii)
    );
    
       
    always @(*)begin
        if(din_rx[31:24]==8'h01||din_rx[31:24]==8'h05)//I或D
        begin
            r_add=din_rx[7:0];//读地址赋值为操作数对应地址
        end
        else begin
            r_add=0;
        end
    end
    //********************************LD命令*********************************************************
    reg LD_State,LI_State;
    //LD_State的更新
    always@(posedge clk)begin
        if(!rstn)begin
            LD_State <= 0; 
        end
        else begin
            if(din_rx == {8'h03,24'h0} && ~mode)begin
                LD_State <= 1;
            end
            else begin
                if( din_rx == 32'hffffffff && mode )begin
                    LD_State <= 0 ;//eof
                end
            end
        end
    end

    //LI_State的更新
    always@(posedge clk)begin
        if(!rstn)begin
            LI_State <= 0; 
        end
        else begin
            if(din_rx == {8'h04,24'h0} && ~mode)begin
                LI_State <= 1;
            end
            else begin
                if( din_rx == 32'hffffffff && mode )begin
                    LI_State <= 0 ;//eof
                end
            end
        end
    end

    //da_we的更新
    always@(posedge clk)begin
        if(!rstn)begin
            da_we <= 0;
        end
        else begin
            if(din_rx == {8'h03,24'h0} && ~mode)begin
                da_we <= 1;
            end
            else begin
                if(din_rx == 32'hffffffff && mode )begin
                    da_we <= 0;
                end
            end
        end
    end

    //IP_we的更新
    always@(posedge clk)begin
        if(!rstn)begin
            IP_we <= 0;
        end
        else begin
            if(din_rx == {8'h04,24'h0} && ~mode )begin
                IP_we <= 1;
            end
            else begin
                if(din_rx == 32'hffffffff && mode )begin
                    IP_we <= 0;
                end
            end
        end
    end

    //w_add的更新
    always@(posedge clk)begin
        if(!rstn)begin
            w_add <= 16'hffff;
        end
        else begin
            if((din_rx_pre == {8'h03,24'h0} || din_rx_pre == {8'h04,24'h0} ) && ~mode)begin
                w_add <= 0; //遇到LD和LI指令默认从0地址开始
            end
            else if((LD_State || LI_State) && ack_rx && mode &&flag_rx_pre)begin
                w_add <= w_add + 1;  //每个周期存一个字节的数据，存好后下一周期往后移
            end
        end
    end
    //dout_tx
    always@(posedge clk)begin
        if(!rstn)begin
            dout_tx<=32'h0;
        end
        else begin
            if(R_State)begin//R命令:输出各寄存器的信息，此时输出的type_tx改为字节模式
                case(R_sequence)
                    4'hD:dout_tx<={25'h0,7'h52};//R
                    4'hC:begin
                        if(R_State>22)begin
                            dout_tx<=32'h0;//十位为0
                        end
                        else if(R_State>12)begin
                            dout_tx<={25'h0,7'h31};//十位为1
                        end
                        else if(R_State>2)begin
                            dout_tx<={25'h0,7'h32};//十位为2
                        end
                        else begin
                            dout_tx<={25'h0,7'h33};//十位为3
                        end
                    end
                    4'hB:begin
                        case(R_State%10)
                            2:begin
                                dout_tx<={25'h0,7'h30};//个位为0  
                            end 
                            1:begin
                                dout_tx<={25'h0,7'h31};//个位为1
                            end
                            0:begin
                                dout_tx<={25'h0,7'h32};//个位为2
                            end
                            9:begin
                                dout_tx<={25'h0,7'h33};//个位为3
                            end
                            8:begin
                                dout_tx<={25'h0,7'h34};//个位为4
                            end
                            7:begin
                                dout_tx<={25'h0,7'h35};//个位为5
                            end
                            6:begin
                                dout_tx<={25'h0,7'h36};//个位为6
                            end
                            5:begin
                                dout_tx<={25'h0,7'h37};//个位为7
                            end
                            4:begin
                                dout_tx<={25'h0,7'h38};//个位为8
                            end
                            3:begin
                                dout_tx<={25'h0,7'h39};//个位为9
                            end
                        endcase
                    end
                    4'hA:dout_tx<={25'h0,7'h3D};// "="
                    4'h5:dout_tx<={25'h0,7'h20};// "-"
                    4'hF:;//违规状态，不做任何操作
                    4'hE:;
                    4'h0:dout_tx<={25'h0,7'h2D};//" "
                    default:dout_tx<={25'h0,reg_ascii};// "R[7]",ascii依赖于地址的选择
                endcase
            end
            else if(I_State != 0)begin
                case(I_State)
                    5'd22:begin
                        dout_tx<={25'h0,7'h49};//I
                    end
                    5'd21:begin
                        dout_tx<={25'h0,7'h5F};//_
                    end
                    5'd20:begin
                        dout_tx<={25'h0,r_add[7]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd19:begin
                        dout_tx<={25'h0,r_add[6]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd18:begin
                        dout_tx<={25'h0,r_add[5]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd17:begin
                        dout_tx<={25'h0,r_add[4]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd16:begin
                        dout_tx<={25'h0,7'h5F};//"_"
                    end
                    5'd15:begin
                        dout_tx<={25'h0,r_add[3]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd14:begin
                        dout_tx<={25'h0,r_add[2]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd13:begin
                        dout_tx<={25'h0,r_add[1]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd12:begin
                        dout_tx<={25'h0,r_add[0]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd11:begin
                        dout_tx<={25'h0,r_add[7]?7'h31:7'h3A};//":"
                    end
                    5'd6:begin
                        dout_tx<={25'h0,7'h2D};//"-"
                    end
                    5'd1:begin
                        dout_tx<={25'h0,7'h0a};//"\n"
                    end
                    default: dout_tx<={25'h0,ip_ascii};//内存数据
                endcase
            end
            else if(D_State)begin
                case(D_State)
                    5'd22:begin
                        dout_tx<={25'h0,7'h44};//I
                    end
                    5'd21:begin
                        dout_tx<={25'h0,7'h5F};//_
                    end
                    5'd20:begin
                        dout_tx<={25'h0,r_add[7]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd19:begin
                        dout_tx<={25'h0,r_add[6]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd18:begin
                        dout_tx<={25'h0,r_add[5]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd17:begin
                        dout_tx<={25'h0,r_add[4]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd16:begin
                        dout_tx<={25'h0,7'h5F};//"_"
                    end
                    5'd15:begin
                        dout_tx<={25'h0,r_add[3]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd14:begin
                        dout_tx<={25'h0,r_add[2]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd13:begin
                        dout_tx<={25'h0,r_add[1]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd12:begin
                        dout_tx<={25'h0,r_add[0]?7'h31:7'h30};//为1则拼1，为0则拼0
                    end
                    5'd11:begin
                        dout_tx<={25'h0,r_add[7]?7'h31:7'h3A};//":"
                    end
                    5'd6:begin
                        dout_tx<={25'h0,7'h2D};//"-"
                    end
                    5'd1:begin
                        dout_tx<={25'h0,7'h0a};//"\n"
                    end
                    default: dout_tx<={25'h0,da_ascii};//内存数据
                endcase
            end
        end
    end

    //req_rx
    always @(posedge clk, negedge rstn) begin
        if( !rstn ) begin
            req_rx <= 1'b1;
        end
        else if( req_rx == 1'b1 && flag_rx == 1'b1 ) begin 
            req_rx <= 1'b0;
        end
        else if( req_rx == 1'b0 ) begin
            if(~|D_State&&~|I_State&&~|R_State)begin//如果输出完毕
                req_rx<=1'b1;
            end
        end
    end    
    
    //req_tx
    always@(posedge clk)begin
        if(~rstn)begin
            req_tx<=0;
        end
        else begin
            if(D_State||R_State||I_State)begin
                req_tx<=1;
            end
            else begin//三个命令都没有接收到则没有向外的请求
                if(~|R_State&&~|I_State&&~|D_State)begin
                    req_tx<=0;
                end
            end
        end
    end

    //mode的更新,0-指令,1-数据
    always@(posedge clk)begin
        if(!rstn)begin
            mode <= 0;
        end
        else begin
            if(!mode && (din_rx == 32'h04000000 || din_rx == 32'h 03000000))begin
                mode <= 1;
            end
            else if( mode && din_rx == 32'hffffffff )begin
                mode <= 0;
            end
        end
    end

    //data的更新
    always@(posedge clk)begin
        if(!rstn)begin
            data <= 0;
        end
        else begin
            if( mode_pre && ~flag_rx && flag_rx_pre)begin
                data <= din_rx;
            end
        end
    end

    //flag_rx_pre的更新
    always@(posedge clk)begin
        flag_rx_pre <= flag_rx;
    end

    //flag_rx_pre2的更新
    always@(posedge clk)begin
        flag_rx_pre2 <= flag_rx_pre;
    end

    always@(posedge clk)begin
        mode_pre <= mode;
    end

    always@(posedge clk)begin
        if(!rstn)begin
            din_rx_pre <= 0;
        end
        else begin
            if(flag_rx)begin
                din_rx_pre <= din_rx;
            end
        end
    end
endmodule
