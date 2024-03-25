`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 17:29:05
// Design Name: 
// Module Name: SRT
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


module SRT
    #(parameter add_op  = 4'h0,
                sub_op  = 4'h1,
                slt_op  = 4'h2,
                sltu_op = 4'h3,
                and_op  = 4'h4,
                or_op   = 4'h5,
                nor_op  = 4'h6,
                xor_op  = 4'h7,
                sll_op  = 4'h8,
                srl_op  = 4'h9,
                sra_op  = 4'hA,
                ass_op  = 4'hB
    )
    (
        input               clk,
        input               rstn,
        input               up,         // 0 - 降序， 1 - 升序
        input               start,      //启动排序
        input               prior,      //查看前一个数据
        input               next,       //查看后一个数据
        output reg          done,       //排序结束标志
        output reg [9:0]    index,      //输出数据序号
        output reg [31:0]   data,       //输出数据
        output reg [31:0]   count       //时钟周期数
    );

    reg             swapped;
    reg             start_reg1;
    reg     [9:0]   count_reg1, count_reg2;
    reg             count_enable; 
    reg             we1, we2;
    reg             flag;
    reg     [31:0]  src0;
    reg     [31:0]  src1;
    wire    [31:0]  res;
    reg     [9:0]   address1, address2;
    reg     [31:0]  write_data1, write_data2;
    wire    [31:0]  read_data1, read_data2;
    reg     [31:0]  zero_data1, zero_data2;
    reg             flag_reg;
    reg             done_reg;
    reg             next_reg, prior_reg;
    data_memory  data_memory_inst (
        .a(address1),                        
        .d(write_data1),
        .clk(clk),
        .we(we1),
        .spo(read_data1)
    );

    sorted_data  sorted_data_inst (
        .a(address2),
        .d(write_data2),
        .clk(clk),
        .we(we2),
        .spo(read_data2)
    );
    
    ALU # (
        .add_op(add_op),
        .sub_op(sub_op),
        .slt_op(slt_op),
        .sltu_op(sltu_op),
        .and_op(and_op),
        .or_op(or_op),
        .nor_op(nor_op),
        .xor_op(xor_op),
        .sll_op(sll_op),
        .srl_op(srl_op),
        .sra_op(sra_op),
        .ass_op(ass_op)
    )
    ALU_inst (
        .src0(src0),
        .src1(src1),
        .op(sltu_op),
        .res(res)
    );

    reg [31:0] max;
    reg [31:0] min;

    assign max      = res[0] ? src1 : src0;
    assign min      = res[0] ? src0 : src1;      

    assign data     = (flag ? read_data2 : read_data1);
    assign we1      = flag_reg & ~done ? 1 : 0;
    assign we2      = ~flag_reg & ~done ? 1 : 0;

    always @(posedge clk) begin
        if(!rstn) begin
            done <= 1;
        end
        else begin
            if(start_reg1 & ~start) begin
                done <= 0;
            end
            else if(~swapped & count_reg1 == 0) begin
                done <= 1;
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            next_reg <= 0;
        end
        else begin
            next_reg <= next;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            prior_reg <= 0;
        end
        else begin
            prior_reg <= prior;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            count_reg2 <= 0;
        end
        else begin
            if(done & ~done_reg) begin
                count_reg2 <= 0;
            end
            else begin
                count_reg2 <= count_reg1;
            end
        end
    end

    always @(posedge clk ) begin
        if (!rstn) begin
            index <= 0;
        end
        else begin
            if(done) begin
                index <= (flag ? address2 : address1);
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            flag_reg <= 0;
        end
        else begin
            flag_reg <= flag;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            done_reg <= 1;
        end
        else begin
            done_reg <= done;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            zero_data1 <= 0;
        end
        else begin
            if(address1 == 0 & ~done) begin
                if(flag == 0) begin         //如果是被读状态，则读出的数据直接时0号地址的数据
                    zero_data1 <= read_data1;
                end
                else begin                  //如果是被写状态，则0号地址的数据应为写入的数据，而非之前数据存储器存储的数据
                    zero_data1 <= up ? min : max;
                end
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            zero_data2 <= 0;
        end
        else begin
            if(address2 == 0 & ~done) begin
                if(flag == 0) begin         
                    zero_data2 <= up ? min : max;
                end
                else begin                 
                    zero_data2 <= read_data2;
                end
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            start_reg1 <= 0;
        end
        else begin
            start_reg1 <= start;
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin     //start下降沿开始计数晚了
            count_reg1 <= 0;
        end
        else begin
            if(done & ~done_reg) begin
                count_reg1 <= 0;
            end
            else if(start_reg1 & ~start) begin
                count_reg1 <= 10'h3fe;
            end
            if(count_enable) begin
                if(count_reg1 == 0 & swapped) begin
                    count_reg1 <= 10'h3ff;
                end
                else begin
                    count_reg1 <= count_reg1 - 1;
                end
            end
        end
    end

    always @(*) begin
        if(~flag_reg) begin
            if(address2 == 10'h3ff) begin
                write_data1 = src1; 
            end
            else begin
                write_data1 = up ? min : max;
            end
        end
        else begin
            if(address1 == 10'h3ff) begin
                write_data1 = src1;
            end
            else begin
                write_data1 = up ? min : max;
            end
        end
    end
    assign write_data2 = write_data1;
    
    //与flag有关
    // always @(posedge clk) begin
    //     if(!rstn) begin
    //         src0 <= read_data1;
    //     end
    //     else begin
    //         if(flag ^ flag_reg) begin
    //             src0 <= flag ? zero_data2 : zero_data1;
    //         end
    //         else if(~flag) begin         //要求flag的转换对应地址的转换
    //             src0 <= read_data1;
    //         end
    //         else begin                  //转换flag时，可能由于另外一个DRAM的写延后一个周期，导致耽误两个周期时间加载第0个数据
    //             src0 <= read_data2;
    //         end
    //     end
    // end

    always @(*) begin
        if(flag ^ flag_reg) begin
            src0 = flag ? zero_data2 : zero_data1;
        end
        else if(~flag) begin
            src0 = read_data1;
        end
        else begin
            src0 = read_data2;
        end
    end


    always @(posedge clk) begin
        if(!rstn) begin
            src1 <= 0;
        end
        else begin
            if((start_reg1 & !start)|(flag ^ flag_reg)) begin       
                src1 <= src0;
            end
            else begin
                src1 <= up ? max : min;
            end
        end
    end

    assign count_enable = ~done & (address1 < 10'h3ff | address2 < 10'h3ff);   //非零就可以计数

    always @(posedge clk) begin
        if(!rstn) begin
            count <= 0;
        end
        else begin
            if(count_enable) begin
                count <= count + 1;
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            swapped <= 0;
        end
        else begin
            if(flag ^ flag_reg & ~done) begin       //遍历过一次待排序数据后，flag进行转换时swapped恢复为0
                swapped <= 0;
            end
            else begin
                if(swapped == 0 & ~done) begin      
                    swapped <= up ? res[0] : (src0 == src1 ? 0 : ~res[0]);
                end
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            flag <= 0;
        end
        else begin
            if(swapped & count_reg2 == 0) begin  //如果发生变化，则调转两个数据存储器的身份。 count_reg1的具体边界条件要再确认一下 TO BE DONE
                flag <= flag ? 0 : 1;
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            address1 <= 0;
        end
        else begin
            if(start_reg1 & ~start) begin
                address1 <= 10'h0;
            end
            else if(flag & ~flag_reg) begin      //转换时
                address1 <= 10'h0;
            end
            else if(flag == 0 & ~done) begin     //读存储器为data_mem时
                if(count_enable) begin
                    address1 <= 10'h3ff - count_reg1;// count_reg1不做限制了，默认全部遍历，不然剩下数据无法复制过去
                end
            end
            else if(flag == 1 & ~done) begin              //写存储器为data_mem时
                if(address2 == 0 ) begin
                    address1 <= 0;
                end
                else begin
                    address1 <= address2 ;
                end
            end
            else begin                          //done，地址变成1
                if(done & ~done_reg) begin
                    address1 <= 0;
                end
                else begin
                    if(prior_reg & ~prior) begin    //下降沿减一
                       address1 <= address1 - 1; 
                    end
                    else if(next_reg & ~next) begin //下降沿加一
                        address1 <= address1 + 1;
                    end
                end
            end
        end
    end

    always @(posedge clk) begin
        if(!rstn) begin
            address2 <= 0;
        end
        else begin
            if(flag == 1 & ~done) begin         //读存储器为sorted_mem时
                if(count_enable) begin
                    address2 <= 10'h3ff - count_reg1;
                end
            end
            else if(~flag & flag_reg) begin      //转换时
                address2 <= 10'h0;
            end
            else if(start_reg1 & ~start) begin
                address2 <= 0;
            end
            else if(flag == 0 & ~done) begin
                if(address1 == 0 ) begin
                    address2 <= 0;
                end
                else begin
                    address2 <= address1 ;
                end
            end
            else begin                          //done，地址变成1
                if(done & ~done_reg) begin
                    address2 <= 0;
                end
                else begin
                    if(prior_reg & ~prior) begin    //下降沿减一
                        address2 <= address2 - 1; 
                    end
                    else if(next_reg & ~next) begin //下降沿加一
                        address2 <= address2 + 1;
                    end
                end
            end
        end
    end

endmodule

