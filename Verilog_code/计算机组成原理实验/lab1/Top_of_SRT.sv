`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/24 18:50:32
// Design Name: 
// Module Name: Top_of_SRT
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


module Top_of_SRT
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
        input           clk, rstn,  
        input           up,             //sw[0]
	    input           start,          //btnc
        input           prior,          //btnl
        input           next,           //btnr	
        input           count_display,  //btnu
        input           data_display,   //btnd
        output [7:0]    an,             //an7-0
        output [2:0]    flag,           //led15-0，指示数码管显示的数据类型
        output [6:0]    seg,            //ca-cg
        output          done_flag,      //led17_g
        output          not_done_flag,  //led17_r
        output [15:0]   addr            //led15-0
    );

    SRT # (
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
    SRT_inst (
      .clk(clk),
      .rstn(rstn),
      .up(up),
      .start(start_p),
      .prior(prior_p),
      .next(next_p),
      .done(done),
      .index(index),
      .data(data),
      .count(count)
    );
    wire    [9:0]  index;
    wire            up;
    reg     [2:0]   seg_sel_r;
    wire    [31:0]  count;
    wire    [31:0]  data;
    reg     [31:0]  display_data ;
    reg     [19:0]  cnt_clk_r;
    reg     [6:0]   seg_t;
    reg     [3:0]   hd_t;
    reg     [7:0]   an_t;
    reg     [15:0]  addr_r;
    wire    [4:0]   btn;
    reg     [4:0]   cnt_btn_db_r;
    reg     [4:0]   btn_db_r, btn_db_1r;
    wire            clk_db = cnt_clk_r[16]; //去抖动计数器时钟763Hz（周期约1.3ms）
    wire            start_p, prior_p, next_p, count_display_p, data_display_p;
    reg             data_display_p_flag;
    reg     [3:0]   seg_count;
    wire    is_open = (seg_count == 0);

    assign done_flag = done;
    assign not_done_flag = ~done;
    assign flag = seg_sel_r & {3{is_open}};;
    assign addr = addr_r;
    assign btn = {start, prior, next, count_display, data_display};
    assign seg = seg_t;
    assign an = an_t;
    assign start_p = btn_db_r[4] & ~btn_db_1r[4];
    assign prior_p = btn_db_r[3] & ~btn_db_1r[3];
    assign next_p = btn_db_r[2] & ~btn_db_1r[2];
    assign count_display_p = btn_db_r[1] & ~btn_db_1r[1];
    assign data_display_p = btn_db_r[0] & ~btn_db_1r[0];

    always @(posedge clk) begin
        if(!rstn) begin
            seg_count <= 0;
        end
        else begin
            seg_count <= seg_count + 1;
        end
    end
    
    always @(posedge clk) begin    //数码管显示数据选择
        if (!rstn)
            seg_sel_r <= 3'b001;
		else if(prior_p| next_p)
            seg_sel_r <= 3'b001; 
        else if(count_display_p)
            seg_sel_r <= 3'b010;
    end

    always @(*) begin
        case(seg_sel_r) 
            2'b01:
                display_data = data;
            2'b10:
                display_data = count;
            default:
                display_data = data;
        endcase
    end

    always@(posedge clk_db) begin  
        if (!rstn)
            btn_db_r <= btn;
        else if (cnt_btn_db_r[4])
            btn_db_r <= btn;
    end

    always @(posedge clk) begin   
        if (!rstn)
            btn_db_1r <= btn;
        else
            btn_db_1r <= btn_db_r;
    end 

    always @(posedge clk_db) begin
        if (!rstn)
            cnt_btn_db_r <= 5'h0;
        else if ((|(btn ^ btn_db_r)) & (~ cnt_btn_db_r[4]))
            cnt_btn_db_r <= cnt_btn_db_r + 5'h1;
        else
            cnt_btn_db_r <= 5'h0;
    end

    always @(posedge clk, negedge rstn) begin
        if (!rstn)
            cnt_clk_r <= 20'h0;
        else
            cnt_clk_r <= cnt_clk_r + 20'h1;
    end

    always @(*) begin                  //数码管扫描
        an_t = 8'b1111_1111;
        hd_t = display_data[3:0];
        if (&cnt_clk_r[16:15])         //降低亮度
        case (cnt_clk_r[19:17])        //刷新频率约为95Hz
            3'b000: begin
                an_t = 8'b1111_1110;
                hd_t = display_data[3:0];
            end
            3'b001: begin
                an_t = 8'b1111_1101;
                hd_t = display_data[7:4];
            end
            3'b010: begin
                an_t = 8'b1111_1011;
                hd_t = display_data[11:8];
            end
            3'b011: begin
                an_t = 8'b1111_0111;
                hd_t = display_data[15:12];
            end
            3'b100: begin
                an_t = 8'b1110_1111;
                hd_t = display_data[19:16];
            end
            3'b101: begin
                an_t = 8'b1101_1111;
                hd_t = display_data[23:20];
            end
            3'b110: begin
                an_t = 8'b1011_1111;
                hd_t = display_data[27:24];
            end
            3'b111: begin
                an_t = 8'b0111_1111;
                hd_t = display_data[31:28];
            end
            default: begin
                an_t = 8'b1111_1111;
                hd_t = 4'b0000;
            end
        endcase
    end

    always @ (*) begin    //7段译码
        case(hd_t)
            4'b1111:
                seg_t = 7'b0111000;
            4'b1110:
                seg_t = 7'b0110000;
            4'b1101:
                seg_t = 7'b1000010;
            4'b1100:
                seg_t = 7'b0110001;
            4'b1011:
                seg_t = 7'b1100000;
            4'b1010:
                seg_t = 7'b0001000;
            4'b1001:
                seg_t = 7'b0001100;
            4'b1000:
                seg_t = 7'b0000000;
            4'b0111:
                seg_t = 7'b0001111;
            4'b0110:
                seg_t = 7'b0100000;
            4'b0101:
                seg_t = 7'b0100100;
            4'b0100:
                seg_t = 7'b1001100;
            4'b0011:
                seg_t = 7'b0000110;
            4'b0010:
                seg_t = 7'b0010010;
            4'b0001:
                seg_t = 7'b1001111;
            4'b0000:
                seg_t = 7'b0000001;
            default:
                seg_t = 7'b1111111;
        endcase
    end

    always @(posedge clk) begin
        if(!rstn) begin
            data_display_p_flag <= 1;
        end
        else if(count_display_p) begin
            data_display_p_flag <= 0;
        end
        else if(next_p | prior_p | data_display_p) begin
            data_display_p_flag <= 1;
        end
    end

    always @(posedge clk) begin
        if (!rstn) 
            addr_r <= 16'h0000;
		else if (count_display_p | start_p)
            addr_r <= 16'h0000;			
        else if (prior_p) begin
		    if (data_display_p_flag) begin
			    addr_r <= {{6{1'b0}},{index - 1'b1}};
            end
            else begin
                addr_r <= 0;
            end
        end
        else if (next_p) begin
            if (data_display_p_flag) begin
			    addr_r <= {{6{1'b0}},{index + 1'b1}};
            end
            else begin
                addr_r <= 0;
            end
        end
            
    end
	
endmodule
