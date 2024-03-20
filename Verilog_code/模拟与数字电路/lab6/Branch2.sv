`timescale 1ns / 1ps
module Branch2#(parameter ADD_WIDTH = 32)(
        input [2:0]                 br_type,
        input [ADD_WIDTH-1:0]       pc,
        input [31:0]                imm,
        input [31:0]                rf_rdata1,
        input [31:0]                rf_rdata2,
        input                       cpu_clk,rstn,
        input [2:0]                 cu_count,
        output reg                  jump_en,
        output reg [ADD_WIDTH-1:0]  jump_target
    );
    initial begin
        jump_en = 0;
    end

    //jump_en的赋值
    always@(*)begin
        if(cu_count == 2)begin
            if( br_type <= 5 )begin
                case(br_type)
                    3'd0:begin//beq
                        if(rf_rdata1 == rf_rdata2)begin
                            jump_en = 1;
                        end
                        else begin
                            jump_en = 0;
                        end
                    end
                    3'd1:begin//bne
                        if(rf_rdata1 != rf_rdata2)begin
                            jump_en = 1;
                        end
                        else begin
                            jump_en = 0;
                        end
                    end
                    3'd2:begin//blt
                        if($signed(rf_rdata1) < $signed(rf_rdata2))begin
                            jump_en = 1;
                        end
                        else begin
                            jump_en = 0;
                        end
                    end
                    3'd3:begin//bge
                        if($signed(rf_rdata1) > $signed(rf_rdata2))begin
                            jump_en = 1;
                        end
                        else begin
                            jump_en = 0;
                        end
                    end
                    3'd4:begin//bltu
                        if($unsigned(rf_rdata1) < $unsigned(rf_rdata2))begin
                            jump_en = 1;
                        end
                        else begin
                            jump_en = 0;
                        end
                    end
                    3'd5:begin//bgeu
                        if($unsigned(rf_rdata1) > $unsigned(rf_rdata2))begin
                            jump_en = 1;
                        end
                        else begin
                            jump_en = 0;
                        end
                    end
                    3'd7:begin
                        jump_en = 0;
                    end
                    default: jump_en = 0;
                endcase
            end
        end
        else if(cu_count == 1)begin//下一个周期置为0
            jump_en = 0;
        end
    end
    //跳转指令的类型，根据指令是否跳转以及跳转的类型给出 跳转条件分别为( 操作数分别为 rj 和 rd ): 
    // 0-相等(BEQ) 1-不等(BNE) 2-有符号小于(BLT) 3-有符号大于(BGE) 4-无符号小于(BLTU) 5-无符号大于(BGEU),规定 7-不跳转
    
    //jump_target的赋值
    always@(*)begin
        if(cu_count == 3) begin
            case(br_type)
            3'd0:begin//beq
                if(rf_rdata1 == rf_rdata2)begin
                    jump_target = pc + imm;
                end
                else begin
                    jump_target = pc;
                end
            end
            3'd1:begin//bne
                if(rf_rdata1 != rf_rdata2)begin
                    jump_target = pc + imm;
                end
                else begin
                    jump_target = pc;
                end
            end
            3'd2:begin//blt
                if($signed(rf_rdata1) < $signed(rf_rdata2))begin
                    jump_target = pc + imm;
                end
                else begin
                    jump_target = pc;
                end
            end
            3'd3:begin//bge
                if($signed(rf_rdata1) > $signed(rf_rdata2))begin
                    jump_target = pc + imm;
                end
                else begin
                    jump_target = pc;
                end
            end
            3'd4:begin//bltu
                if($unsigned(rf_rdata1) < $unsigned(rf_rdata2))begin
                    jump_target = pc + imm;
                end
                else begin
                    jump_target = pc;
                end
            end
            3'd5:begin//bgeu
                if($unsigned(rf_rdata1) > $unsigned(rf_rdata2))begin
                    jump_target = pc + imm;
                end
                else begin
                    jump_target = pc;
                end
            end
            default: ;
        endcase
        end
    end
endmodule