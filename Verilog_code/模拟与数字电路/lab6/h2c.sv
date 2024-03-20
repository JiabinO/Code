`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/06 13:08:26
// Design Name: 
// Module Name: h2c
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


module h2c(
    input      [3 :0] cnt ,
    input             type_tx ,
    input             data_mode ,
    input      [31:0] all,
    output reg [7 :0] dout
    );

    reg [31:0] mid;
    reg [7:0] data_1;
    reg [7:0] data_2;
    reg [7:0] data_3;
    reg [7:0] data_4;


    always @(*) begin
        case (cnt)
            4'd1 : dout = mid[ 7: 0];
            4'd2 : dout = mid[15: 8];
            4'd3 : dout = mid[23:16];
            4'd4 : dout = mid[31:24];
            default :dout = 8'd0;
        endcase  
    end
    always @(*) begin
        //将0->F翻译成ASCII
        case (all[3:0])
            4'd0   : data_4 = 8'h30;
            4'd1   : data_4 = 8'h31;
            4'd2   : data_4 = 8'h32;
            4'd3   : data_4 = 8'h33;
            4'd4   : data_4 = 8'h34;
            4'd5   : data_4 = 8'h35;
            4'd6   : data_4 = 8'h36;
            4'd7   : data_4 = 8'h37;
            4'd8   : data_4 = 8'h38;
            4'd9   : data_4 = 8'h39;
            4'd10  : data_4 = 8'h41;
            4'd11  : data_4 = 8'h42;
            4'd12  : data_4 = 8'h43;
            4'd13  : data_4 = 8'h44;
            4'd14  : data_4 = 8'h45;
            4'd15  : data_4 = 8'h46; 
            default: data_4 = 8'h3f;
        endcase
        case (all[7:4])
            4'd0   : data_3 = 8'h30;
            4'd1   : data_3 = 8'h31;
            4'd2   : data_3 = 8'h32;
            4'd3   : data_3 = 8'h33;
            4'd4   : data_3 = 8'h34;
            4'd5   : data_3 = 8'h35;
            4'd6   : data_3 = 8'h36;
            4'd7   : data_3 = 8'h37;
            4'd8   : data_3 = 8'h38;
            4'd9   : data_3 = 8'h39;
            4'd10  : data_3 = 8'h41;
            4'd11  : data_3 = 8'h42;
            4'd12  : data_3 = 8'h43;
            4'd13  : data_3 = 8'h44;
            4'd14  : data_3 = 8'h45;
            4'd15  : data_3 = 8'h46; 
            default: data_3 = 8'h3f;
        endcase
    end



    always @(*) begin
        if( type_tx == 1'b0 ) begin
            if( data_mode == 1'b1) begin
                case (all[7:0])
                    8'hFF: begin
                        mid = 32'h00000d0a;//\n
                    end
                    default: mid = {24'd0, all[7:0]} ;
                endcase
            end
        end
        else if( type_tx == 1'b1 ) begin
            if( data_mode == 1'b1)begin
                case (all[31:24])
                    8'h05 : begin
                        mid = {8'h44, 8'd0, data_3, data_4};
                    end 
                    8'h01 : begin
                        mid = {8'h49, 8'd0, data_3, data_4};
                    end
                    8'h02 : begin
                        mid = {8'h52, 24'd0};
                    end
                    8'h03 : begin
                        mid = {16'h4c44, 16'd0};
                    end
                    8'h04 : begin
                        mid = {16'h4c49, 16'd0};
                    end
                    default: mid = 32'h0000003f;//报错指示
                endcase
            end
            else begin
                mid = all;
            end
        end
    end
endmodule

        // if(cnt > 4'd2) begin
        //     case (din)
        //         4'd0 : mid = 8'h30;
        //         4'd1 : mid = 8'h31;
        //         4'd2 : mid = 8'h32;
        //         4'd3 : mid = 8'h33;
        //         4'd4 : mid = 8'h34;
        //         4'd5 : mid = 8'h35;
        //         4'd6 : mid = 8'h36;
        //         4'd7 : mid = 8'h37;
        //         4'd8 : mid = 8'h38;
        //         4'd9 : mid = 8'h39;
        //         4'd10: mid = 8'h41;
        //         4'd11: mid = 8'h42;
        //         4'd12: mid = 8'h43;
        //         4'd13: mid = 8'h44;
        //         4'd14: mid = 8'h45;
        //         4'd15: mid = 8'h46;
        //     endcase
        // end
        // else if(cnt == 4'd2)begin
        //     mid = 8'h0d;
        // end
        // else if(cnt == 4'd1)begin
        //     mid = 8'h0a;
        // end
        // else begin
        //     mid = 8'd0;
        // end


    // always @(*) begin
    //     case (cnt)
    //         4'd1 : din = all[ 3: 0];
    //         4'd2 : din = all[ 7: 4];
    //         4'd3 : din = all[11: 8];
    //         4'd4 : din = all[15:12];
    //         4'd5 : din = all[19:16];
    //         4'd6 : din = all[23:20];
    //         4'd7 : din = all[27:24];
    //         4'd8 : din = all[31:28];
    //         default :din = 4'd0;
    //     endcase
    // end