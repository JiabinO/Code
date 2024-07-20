
`timescale 1ns / 1ps
module DCache_rdata_mux #(
    parameter Offset_len = 6
)(
    input wire [(1 << (Offset_len + 3)) - 1:0] DCache_rdata_block,
    input wire [Offset_len - 1:0] offset,
    output reg [31:0] mux_rdata
);

    always @(*) begin
        case (offset[Offset_len - 1: 2])
            0: mux_rdata = DCache_rdata_block[31:0];
            1: mux_rdata = DCache_rdata_block[63:32];
            2: mux_rdata = DCache_rdata_block[95:64];
            3: mux_rdata = DCache_rdata_block[127:96];
            4: mux_rdata = DCache_rdata_block[159:128];
            5: mux_rdata = DCache_rdata_block[191:160];
            6: mux_rdata = DCache_rdata_block[223:192];
            7: mux_rdata = DCache_rdata_block[255:224];
            8: mux_rdata = DCache_rdata_block[287:256];
            9: mux_rdata = DCache_rdata_block[319:288];
            10: mux_rdata = DCache_rdata_block[351:320];
            11: mux_rdata = DCache_rdata_block[383:352];
            12: mux_rdata = DCache_rdata_block[415:384];
            13: mux_rdata = DCache_rdata_block[447:416];
            14: mux_rdata = DCache_rdata_block[479:448];
            15: mux_rdata = DCache_rdata_block[511:480];
            default: mux_rdata = 0; 
        endcase
    end

endmodule
