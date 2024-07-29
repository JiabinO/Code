
`timescale 1ns / 1ps
module mux_write_data #(
    parameter Offset_len = 6,
    parameter Segment_width = 32
)(
    input wire [Offset_len-2:0] buf_shift_count,
    input wire [(1 << (Offset_len + 3)) - 1:0] d_wdata,
    output reg [Segment_width-1:0] write_data_mux
);

    always @(*) begin
        case (buf_shift_count[Offset_len-2:0])
            0: write_data_mux = d_wdata[31:0];
            1: write_data_mux = d_wdata[63:32];
            2: write_data_mux = d_wdata[95:64];
            3: write_data_mux = d_wdata[127:96];
            4: write_data_mux = d_wdata[159:128];
            5: write_data_mux = d_wdata[191:160];
            6: write_data_mux = d_wdata[223:192];
            7: write_data_mux = d_wdata[255:224];
            8: write_data_mux = d_wdata[287:256];
            9: write_data_mux = d_wdata[319:288];
            10: write_data_mux = d_wdata[351:320];
            11: write_data_mux = d_wdata[383:352];
            12: write_data_mux = d_wdata[415:384];
            13: write_data_mux = d_wdata[447:416];
            14: write_data_mux = d_wdata[479:448];
            15: write_data_mux = d_wdata[511:480];
            default: write_data_mux = 0; 
        endcase
    end

endmodule
