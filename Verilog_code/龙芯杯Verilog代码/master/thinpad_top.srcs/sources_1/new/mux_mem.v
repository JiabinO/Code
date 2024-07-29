
`timescale 1ns / 1ps
module mux_mem #(
    parameter Offset_len = 6,
    parameter Segment_width = 32
)(
    input wire [Offset_len-1:0] offset,
    input wire [(1 << (Offset_len + 3)) - 1:0] mem_rdata,
    output reg [Segment_width-1:0] mux_mem_rdata
);

    localparam Total_width = (1 << (Offset_len + 3));
    localparam Num_segments = Total_width / Segment_width;

    always @(*) begin
        case (offset[Offset_len-1:2])
            0: mux_mem_rdata = mem_rdata[31:0];
            1: mux_mem_rdata = mem_rdata[63:32];
            2: mux_mem_rdata = mem_rdata[95:64];
            3: mux_mem_rdata = mem_rdata[127:96];
            4: mux_mem_rdata = mem_rdata[159:128];
            5: mux_mem_rdata = mem_rdata[191:160];
            6: mux_mem_rdata = mem_rdata[223:192];
            7: mux_mem_rdata = mem_rdata[255:224];
            8: mux_mem_rdata = mem_rdata[287:256];
            9: mux_mem_rdata = mem_rdata[319:288];
            10: mux_mem_rdata = mem_rdata[351:320];
            11: mux_mem_rdata = mem_rdata[383:352];
            12: mux_mem_rdata = mem_rdata[415:384];
            13: mux_mem_rdata = mem_rdata[447:416];
            14: mux_mem_rdata = mem_rdata[479:448];
            15: mux_mem_rdata = mem_rdata[511:480];
            default: mux_mem_rdata = 0; 
        endcase
    end

endmodule
