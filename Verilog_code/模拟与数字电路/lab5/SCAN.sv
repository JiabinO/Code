`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/29 19:35:55
// Design Name: 
// Module Name: SCAN
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

//默认指令长度为8位，数据长度为16位
//规定地址宽度为8，接收操作数只用接受2次
module SCAN#(parameter DATAWIDTH = 32,
                       S1=8'hC4,//D
                       S2=8'hC9,//I
                       S3=8'hCC,//L
                       S4=8'hD2//R
                       //最高位为结束位1，需要修正
                    //    D_I=8'h05,//D的操作码
                    //    I_I=8'h01,//I的操作码
                    //    R_I=8'h02,//R的操作码
                    //    LD_I=8'h03,//LD的操作码
                    //    LI_I=8'h04//LI的操作码
                       )(
    input [7:0] d_rx,
    input vld_rx,req_rx,clk,rstn,
    output reg flag_rx,rdy_rx,ack_rx,
    output reg [DATAWIDTH-1:0] din_rx
    );
    reg mode;            //传入的是数据还是指令 0-指令 1-数据
    reg mode_pre;
    reg [DATAWIDTH-1:0] RxW;
    reg [1:0] operand_bit_count;
    reg [3:0] byte_count;
    wire [3:0] hex_out;

    reg [7:0] d_rx_pre;
    reg [7:0] vld_rx_pre2;
    reg [1:0] operand_bit_count_pre;
    reg [7:0] true_d_rx_pre;
    reg vld_rx_pre,data_pre;
    //输入8位数据(2个16进制数据)的时候要用到译码器
    c2h  c2h_inst (
      .ascii_num(d_rx[6:0]),
      .dout(hex_out)
    );


    //接收操作数(8位宽地址)的时候用到的字符计数器
    counter # (
      .WIDTH(2),//由于一次传一个十六进制数(4bits)，所以只需要2次就能接收完8bits的数据
      .RST_VLU(0)
    )
    operand_bit_counter(
      .clk(clk),
      .rstn(rstn),
      .pe(ack_rx&&vld_rx_pre&&(d_rx==S1||d_rx==S2)&&(true_d_rx_pre!=S3)),//需要传输8位操作数(当前接收到了D和I)且响应CPU的请求后置数
      .ce(vld_rx&&|operand_bit_count && ~mode),//当一个数据准备好了才计数
      .din(2),
      .q(operand_bit_count)
    );
    //计数器为1的下一个周期才是完整两个周期，bit_count=0的当个周期做事
    /*将文件中的指令或数据输入到存储器-每DATAWIDTH位就发送一次数据或指令*/
    //接收数据时用到的字符计数器，使用16进制，接收32位，只需要8次就能接收完
    counter # (
        .WIDTH(4),
        .RST_VLU(0)
      )
      byte_counter (
        .clk(clk),
        .rstn(rstn),
        .pe(ack_rx&&vld_rx&&((((d_rx_pre == 8'hC4 || d_rx_pre == 8'hC9) && true_d_rx_pre == 8'hCC)&&~mode) || (d_rx!=8'h8D && mode && ~|byte_count))),//需要传输32位数据(LD、LI)且响应CPU的请求后置数 
        .ce(vld_rx && |byte_count && d_rx != 8'h8A && d_rx != 8'h8D && mode),//不为回车换行符时计数
        .din(7),
        .q(byte_count)
      );
    //计数器为1时传输完32位数据，byte_count=0之后处于空数据状态
    
    always@(posedge clk)begin
        operand_bit_count_pre <= operand_bit_count;
    end
    
    always@(posedge clk)begin
        if(!rstn)begin
            true_d_rx_pre <= 0;
        end
        else begin
            if(vld_rx)begin
                true_d_rx_pre <= d_rx_pre;
            end
        end
    end
    always@(posedge clk)begin
        if(~rstn)begin
            d_rx_pre<=0;
        end
        else if(vld_rx)begin
            d_rx_pre<=d_rx;
        end
    end

    //rdy_rx的更新
    always@(*)begin
        if(!rstn)begin
            rdy_rx<=1;//准备好接受数据
        end
        else begin
            if(req_rx)begin//只有CPU需要数据时才接收数据，其余时候一概不理
                rdy_rx<=1;
            end
            else begin
                rdy_rx<=0;
            end
        end
    end

    //RxW的更新
    always@(posedge clk)begin
        if(!rstn)begin
            RxW <= 32'h0;
        end
        else begin         
            if(vld_rx_pre)begin
                case(d_rx)
                S1:begin//当前接收到的操作是D
                    if(true_d_rx_pre==S3)begin//如果上一个操作符为L，则输出LD指令
                        RxW<={8'h03,24'h0};
                    end
                    else //操作为D
                    begin
                        RxW<={8'h0,8'h05,16'h0};//等待操作数左移完毕
                    end
                end
                S2:begin
                    if(true_d_rx_pre == S3)begin//如果上一个操作符为L，则输出LI指令
                        RxW<={8'h04,24'h0};
                    end
                    else begin//操作为I
                        RxW<={8'h0,8'h01,16'h0};//等待操作数左移完毕
                    end
                end 
                S4:begin//操作为R
                    RxW<={8'h02,24'h0};  
                end
                S3:;//操作为L，什么都不干
                8'hA0:;//输入为空格
                default:begin//输进来是数据或操作数，如果计数器不为0，进行左移
                    if(~mode && |operand_bit_count_pre)begin //指令D和I输入操作数的过程
                        RxW <= {RxW[27:0],hex_out};
                    end
                    else if(!(d_rx == 8'h8D && true_d_rx_pre == 8'h8D) && mode)begin //数据
                        if(mode_pre == 0)begin  //从指令到数据的第一位清零并进位
                            RxW <= {28'h0,hex_out};
                        end
                        else begin
                            if( d_rx != 8'h8D ) RxW <= {RxW[27:0],hex_out};
                        end
                    end
                    else begin
                        RxW <= 32'hffffffff; //eof标志
                    end 
                end
                endcase
            end
        end
    end
    //确定状态机：
    //当输入为I、D时，等待操作码存进去再发
    //当输入为D、I时，发送对应的操作码(LD、LI、D、I)
    //还有当输进来是数字(数据)时，需要对计数器进行更新
    
    //ack_rx的更新
    always@(posedge clk)begin
        if(!rstn)begin
            ack_rx<=1;//默认未响应
        end
        else begin
            if(req_rx)begin//来需求就响应
                ack_rx<=1;
            end
            else begin//当需求没了就
                
            end
        end
    end

    always@(posedge clk)begin
        vld_rx_pre<=vld_rx;
        data_pre <= ~|operand_bit_count && ~|byte_count;
        vld_rx_pre2<=vld_rx_pre;
    end
    //flag_rx的更新
    always@(posedge clk)begin
        if(!rstn)begin
            flag_rx<=0;//默认为8位
        end
        else begin
            if(flag_rx&&req_rx)begin//在数据准备好且CPU发送请求的下个周期数据传输完毕，则标记为无数据
                flag_rx<=0;
            end
            else if(~|operand_bit_count&&~|byte_count&&(~data_pre || (~mode && vld_rx)))begin//计数器为1时数据准备完毕
                flag_rx<=1;
            end
        end
    end

    //din_rx的更新
    always@(posedge clk)begin
        if(!rstn)begin
            din_rx<=0;
        end
        else begin
            if(vld_rx_pre2)begin
                if(~|operand_bit_count_pre &&~|byte_count)begin//如果接收操作数完毕则将移位寄存器的值赋给输出端口
                    din_rx <= RxW;
                end
                if(true_d_rx_pre == 8'hCC && (d_rx == 8'hC4 || d_rx == 8'hC9))begin//LD或LI时将对应指令传入
                    din_rx <= RxW;
                end
                if(true_d_rx_pre == 8'h8D && d_rx == 8'h8D)begin//eof       
                    din_rx <= RxW;
                end
            end
        end
    end

    //mode_pre的更新
    always@(posedge clk)begin
        if(!rstn)begin
            mode_pre <= 0;
        end
        else begin
            if(vld_rx_pre)begin
                mode_pre <= mode ;
            end
        end
    end
    //mode的更新
    always@(posedge clk)begin
        if(!rstn)begin
            mode <= 0;
        end
        else begin
            if( true_d_rx_pre == 8'hCC && (d_rx == 8'hC4 || d_rx == 8'hC9) )begin
                mode <= 1;
            end
            else if( true_d_rx_pre == 8'h8D && d_rx == 8'h8D )begin//连续两个回车代表结束
                mode <= 0;
            end
        end
    end
endmodule

//指令分为两类，一类需要加宽下次发送的宽度：Ba(a为16进制8位地址)、Da(a为16进制8位地址)、Ia(a为16进制8位地址)
    //             另一类不需要加宽：B(显示所有断点地址)、T(逐步执行)、G(连续执行)、H(停止执行，能打断G)、P(输出数据通路状态)、R(查看寄存器堆内容)、LD、LI
    //目前只实现D、I、R、LD、LI、
    //指令暂定的码为：
    // D:8'h00       I:8'h01     R:8'h02     LD:8'h03        LI:8'h04