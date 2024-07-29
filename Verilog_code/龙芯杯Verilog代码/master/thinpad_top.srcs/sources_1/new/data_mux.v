
`timescale 1ns / 1ps
module data_mux #(
    parameter Offset_len = 6,
    parameter Segment_width = 32
)(
    input wire last_used_way,
    input wire [Offset_len-1:0] offset,
    input wire [511:0] way1_rdata_reg,
    input wire [511:0] way2_rdata_reg,
    input wire [1:0] hit,
    output reg [Segment_width-1:0] mux_output_data
);

    localparam Total_width = 512;
    localparam Num_segments = 16;

    always @(*) begin
        if (hit[0]) begin
            case (offset[Offset_len-1:2])
                0: mux_output_data = way1_rdata_reg[31:0];
                1: mux_output_data = way1_rdata_reg[63:32];
                2: mux_output_data = way1_rdata_reg[95:64];
                3: mux_output_data = way1_rdata_reg[127:96];
                4: mux_output_data = way1_rdata_reg[159:128];
                5: mux_output_data = way1_rdata_reg[191:160];
                6: mux_output_data = way1_rdata_reg[223:192];
                7: mux_output_data = way1_rdata_reg[255:224];
                8: mux_output_data = way1_rdata_reg[287:256];
                9: mux_output_data = way1_rdata_reg[319:288];
                10: mux_output_data = way1_rdata_reg[351:320];
                11: mux_output_data = way1_rdata_reg[383:352];
                12: mux_output_data = way1_rdata_reg[415:384];
                13: mux_output_data = way1_rdata_reg[447:416];
                14: mux_output_data = way1_rdata_reg[479:448];
                15: mux_output_data = way1_rdata_reg[511:480];
                default: mux_output_data = 0; 
            endcase
        end
        else if (hit[1]) begin
            case (offset[Offset_len-1:2])
                0: mux_output_data = way2_rdata_reg[31:0];
                1: mux_output_data = way2_rdata_reg[63:32];
                2: mux_output_data = way2_rdata_reg[95:64];
                3: mux_output_data = way2_rdata_reg[127:96];
                4: mux_output_data = way2_rdata_reg[159:128];
                5: mux_output_data = way2_rdata_reg[191:160];
                6: mux_output_data = way2_rdata_reg[223:192];
                7: mux_output_data = way2_rdata_reg[255:224];
                8: mux_output_data = way2_rdata_reg[287:256];
                9: mux_output_data = way2_rdata_reg[319:288];
                10: mux_output_data = way2_rdata_reg[351:320];
                11: mux_output_data = way2_rdata_reg[383:352];
                12: mux_output_data = way2_rdata_reg[415:384];
                13: mux_output_data = way2_rdata_reg[447:416];
                14: mux_output_data = way2_rdata_reg[479:448];
                15: mux_output_data = way2_rdata_reg[511:480];
                default: mux_output_data = 0; 
            endcase
        end
        else if (last_used_way) begin
            case (offset[Offset_len-1:2])
                0: mux_output_data = way2_rdata_reg[31:0];
                1: mux_output_data = way2_rdata_reg[63:32];
                2: mux_output_data = way2_rdata_reg[95:64];
                3: mux_output_data = way2_rdata_reg[127:96];
                4: mux_output_data = way2_rdata_reg[159:128];
                5: mux_output_data = way2_rdata_reg[191:160];
                6: mux_output_data = way2_rdata_reg[223:192];
                7: mux_output_data = way2_rdata_reg[255:224];
                8: mux_output_data = way2_rdata_reg[287:256];
                9: mux_output_data = way2_rdata_reg[319:288];
                10: mux_output_data = way2_rdata_reg[351:320];
                11: mux_output_data = way2_rdata_reg[383:352];
                12: mux_output_data = way2_rdata_reg[415:384];
                13: mux_output_data = way2_rdata_reg[447:416];
                14: mux_output_data = way2_rdata_reg[479:448];
                15: mux_output_data = way2_rdata_reg[511:480];
                default: mux_output_data = 0; 
            endcase
        end else begin
            case (offset[Offset_len-1:2])
                0: mux_output_data = way1_rdata_reg[31:0];
                1: mux_output_data = way1_rdata_reg[63:32];
                2: mux_output_data = way1_rdata_reg[95:64];
                3: mux_output_data = way1_rdata_reg[127:96];
                4: mux_output_data = way1_rdata_reg[159:128];
                5: mux_output_data = way1_rdata_reg[191:160];
                6: mux_output_data = way1_rdata_reg[223:192];
                7: mux_output_data = way1_rdata_reg[255:224];
                8: mux_output_data = way1_rdata_reg[287:256];
                9: mux_output_data = way1_rdata_reg[319:288];
                10: mux_output_data = way1_rdata_reg[351:320];
                11: mux_output_data = way1_rdata_reg[383:352];
                12: mux_output_data = way1_rdata_reg[415:384];
                13: mux_output_data = way1_rdata_reg[447:416];
                14: mux_output_data = way1_rdata_reg[479:448];
                15: mux_output_data = way1_rdata_reg[511:480];
                default: mux_output_data = 0; 
            endcase
        end
    end

endmodule
