
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/07 10:03:34
// Design Name: 
// Module Name: I_Cache
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


module I_Cache(
        input       [31:0]  read_address,
        input               clk, rstn, valid,
        input               branch,
        output reg  [31:0]  read_instruction,
        output reg          ICache_ready
    );

    wire [19:0]   tag     = read_address[31:12];
    wire [7:0]    index   = read_address[11:4];
    wire [3:0]    offset  = read_address[3:0];
    wire [19:0]   tag0;
    wire [19:0]   tag1;
    reg  [1:0]    hit;
    reg  [127:0]  return_buffer;
    wire [31:0]   IM_rdata;
    reg  [1:0]    IM_read_count;
    reg  [2:0]    buf_shift_count;
    reg           ICache0_we, ICache1_we;
    reg  [127:0]  ICache0_rdata;
    reg  [127:0]  ICache1_rdata;
    reg  [127:0]  ICache0_wdata;
    reg  [127:0]  ICache1_wdata;
    reg  [19:0]   tag0_wdata;
    reg  [19:0]   tag1_wdata;
    reg           tag0_we, tag1_we;
    wire [31:0]   Cache0_mux_data;
    wire [31:0]   Cache1_mux_data;
    wire [31:0]   return_buffer_mux_data;
    reg  [16:0]   IM_read_address;
    reg           branch_count;
    reg           valid_reg1;
    reg           valid_reg2;
    reg           valid_reg3;
    reg  [2:0]    unhit_count;

  assign Cache0_mux_data        =   ({32{offset[3:2] == 2'd3}} & ICache0_rdata[31  :0 ])|
                                    ({32{offset[3:2] == 2'd2}} & ICache0_rdata[63  :32])|
                                    ({32{offset[3:2] == 2'd1}} & ICache0_rdata[95  :64])|
                                    ({32{offset[3:2] == 2'd0}} & ICache0_rdata[127 :96]);

  assign Cache1_mux_data        =   ({32{offset[3:2] == 2'd3}} & ICache1_rdata[31  :0 ])|
                                    ({32{offset[3:2] == 2'd2}} & ICache1_rdata[63  :32])|
                                    ({32{offset[3:2] == 2'd1}} & ICache1_rdata[95  :64])|
                                    ({32{offset[3:2] == 2'd0}} & ICache1_rdata[127 :96]);

  assign return_buffer_mux_data =   ({32{offset[3:2] == 2'd3}} & return_buffer[31  :0 ])|
                                    ({32{offset[3:2] == 2'd2}} & return_buffer[63  :32])|
                                    ({32{offset[3:2] == 2'd1}} & return_buffer[95  :64])|
                                    ({32{offset[3:2] == 2'd0}} & return_buffer[127 :96]);
                    
  assign ICache0_wdata = return_buffer;
  assign ICache1_wdata = return_buffer;
  assign tag0_wdata    = tag;
  assign tag1_wdata    = tag;
  blk_mem_gen_0  ICache0 (
    .clka(clk),
    .wea(ICache0_we),
    .addra(index),                    //[7  :0]  
    .dina(ICache0_wdata),             //[127:0]  
    .douta(ICache0_rdata)             //[127:0]  
  );

  blk_mem_gen_0  ICache1 (
    .clka(clk),
    .wea(ICache1_we),
    .addra(index),                    //[7  :0]
    .dina(ICache1_wdata),             //[127:0]
    .douta(ICache1_rdata)             //[127:0]
  );

  blk_mem_gen_2  Tag0 (
    .clka(clk),
    .wea(tag0_we),
    .addra(index),                    //[7  :0]
    .dina(tag0_wdata),                //[21 :0]
    .douta(tag0)                      //[21 :0]
  );

  blk_mem_gen_2  Tag1 (
    .clka(clk),
    .wea(tag1_we),
    .addra(index),                    //[7  :0]
    .dina(tag1_wdata),                //[21 :0]
    .douta(tag1)                      //[21 :0]
  );

  blk_mem_gen_1  I_BMem (
    .clka(clk),
    .addra(IM_read_address[16:0]),    //[16 :0]
    .douta(IM_rdata)                  //[31 :0]
  );

  reg [15:0] counter0 [0:255];          //记录使用频率
  reg [15:0] counter1 [0:255];          //记录使用频率
  
  always @(posedge clk) begin
    if(!rstn) begin
      branch_count <= 0;
    end
    else begin
      if(branch) begin
        branch_count <= 1;
      end
      else if(branch_count)
        branch_count <= branch_count - 1;
    end
  end
  //counter0
  always @(posedge clk) begin
    if(!rstn) begin
      for(int i = 0; i <= 255; i++)
      begin
        counter0[i] <= 0;
      end 
    end
    else begin
      if(valid_reg1 & ~valid_reg2) begin 
        if(hit[0] || (~|hit && counter0[index] > counter1[index]))
          counter0[index] <= 0;
        else begin
          counter0[index] <= counter0[index] + 1;
        end
        for(int i = 0; i <= 255; i++)
        begin
          if(i != index && counter0[i] != 16'hffff) begin
            counter0[i] <= counter0[i] + 1;
          end
        end
      end
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      for(int i = 0; i <= 255; i++)
      begin
        counter1[i] <= 0;
      end 
    end
    else begin
      if(valid_reg1 & ~valid_reg2) begin
        if( (hit[1] & ~hit[0]) || (~|hit && counter1[index] >= counter0[index]))
          counter1[index] <= 0;
        else begin
          counter1[index] <= counter1[index] + 1;
        end
        for(int i = 0; i <= 255; i++)
        begin
          if(i != index && counter1[i] != 16'hffff) begin
            counter1[i] <= counter1[i] + 1;
          end
        end
      end
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      hit <= 0;
    end
    else begin
      if(valid_reg1 & ~valid_reg2 ) begin // 在index更新的两个周期后才能读出tag
        hit <= {tag == tag1, tag == tag0};
      end
    end
  end

  //hit及其跟随信号控制哪些信号？
  //tag_we、Cache_we、计数器自增及清零、IM_read_count、read_instruction
  always @(posedge clk) begin
    if(!rstn) begin
      read_instruction <= 0;
    end
    else begin
      if( |hit & valid_reg2 & ~valid_reg3) begin
        read_instruction <= hit[0] ? Cache0_mux_data : Cache1_mux_data;
      end
      else begin
        if(unhit_count == 1) begin       
          read_instruction <= return_buffer_mux_data;
        end
      end
    end
  end
  
  always @(posedge clk) begin
    if(!rstn) begin
      tag0_we <= 0;
    end
    else begin
      if(~|hit & unhit_count == 7) begin            
        tag0_we <= counter0[index] > counter1[index] ? 1 : 0; //等待时长较长的被替换
      end
      else begin
        tag0_we <= 0;
      end
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      tag1_we <= 0;
    end
    else begin
      if(~|hit & unhit_count == 7) begin            
        tag1_we <= counter1[index] >= counter0[index] ? 1 : 0; //等待时长较长的被替换
      end
      else begin
        tag1_we <= 0;
      end
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      IM_read_count <= 0;
    end
    else begin
      if(valid_reg2 & ~valid_reg3 & ~|hit) begin
        IM_read_count <= 2'd3;
      end
      if( IM_read_count != 0) begin
        IM_read_count <= IM_read_count - 1;
      end
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      ICache0_we <= 0;
    end
    else begin
      if(~|hit & unhit_count == 2) begin                             //TO BE DONE 时序需要调整
        ICache0_we <= counter0[index] > counter1[index] ? 1 : 0; //等待时长较长的被替换
      end
      else begin
        ICache0_we <= 0;
      end
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      ICache1_we <= 0;
    end
    else begin
      if(~|hit & unhit_count == 2) begin                              //TO BE DONE 时序需要调整
        ICache1_we <= counter1[index] >= counter0[index] ? 1 : 0; //等待时长较长的被替换
      end
      else begin
        ICache1_we <= 0;
      end
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      ICache_ready <= 1;
    end
    else begin
      if(valid & ~valid_reg1) begin
        ICache_ready <= 0;
      end
      if(ICache_ready == 0 && hit && valid_reg2 && ~valid_reg3) begin    
        ICache_ready <= 1;
      end
      else if(ICache_ready == 0 && unhit_count == 1) begin
        ICache_ready <= 1;
      end
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      return_buffer <= 0;
    end
    else begin
      if(buf_shift_count != 0) begin
        return_buffer <= {return_buffer[95:0], IM_rdata};
      end
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      IM_read_address <= 0;
    end
    else begin
      if(~|hit & valid_reg2 & ~valid_reg3) begin
        IM_read_address <= (read_address >> 2) & 17'h1fffc;
      end
      else if(IM_read_count) begin
        IM_read_address <= IM_read_address + 1;
      end
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      valid_reg1 <= 0;
    end
    else begin
      if(branch | branch_count) begin
        valid_reg1 <= 0;
      end
      else 
        valid_reg1 <= valid;
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      valid_reg2 <= 0;
    end
    else begin
      valid_reg2 <= valid_reg1;
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      valid_reg3 <= 0;
    end
    else begin
      valid_reg3 <= valid_reg2;
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      buf_shift_count <= 0;
    end
    else begin
      if(~|hit & unhit_count == 6) begin
        buf_shift_count <= 3'd4;
      end
      if( buf_shift_count != 0) begin
        buf_shift_count <= buf_shift_count - 1;
      end
    end
  end

  always @(posedge clk) begin
    if(!rstn) begin
      unhit_count <= 3'd0;
    end
    else begin
      if(~|hit & valid_reg2 & ~valid_reg3) begin
        unhit_count <= 3'd7;
      end
      if(|unhit_count) begin
        unhit_count <= unhit_count - 1;
      end
    end
  end
endmodule
