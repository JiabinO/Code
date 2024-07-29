
`timescale 1ns / 1ps
module insert_data #(
    parameter Offset_len = 6
)(
    input wire [Offset_len-1:0] offset,
    input wire [(1 << (Offset_len + 3)) - 1:0] origin_data,
    input wire [31:0] inserted_data,
    input wire byte_write,
    input wire half_word_write,
    input wire word_write,
    output reg [(1 << (Offset_len + 3)) - 1:0] processed_data
);

    localparam Total_width = (1 << (Offset_len + 3));

    always @(*) begin
        if(word_write)
            case (offset[Offset_len - 1:2])
                    0: processed_data = {origin_data[511:32], inserted_data};
            1: processed_data = {origin_data[511:64], inserted_data, origin_data[31:0]};
            2: processed_data = {origin_data[511:96], inserted_data, origin_data[63:0]};
            3: processed_data = {origin_data[511:128], inserted_data, origin_data[95:0]};
            4: processed_data = {origin_data[511:160], inserted_data, origin_data[127:0]};
            5: processed_data = {origin_data[511:192], inserted_data, origin_data[159:0]};
            6: processed_data = {origin_data[511:224], inserted_data, origin_data[191:0]};
            7: processed_data = {origin_data[511:256], inserted_data, origin_data[223:0]};
            8: processed_data = {origin_data[511:288], inserted_data, origin_data[255:0]};
            9: processed_data = {origin_data[511:320], inserted_data, origin_data[287:0]};
            10: processed_data = {origin_data[511:352], inserted_data, origin_data[319:0]};
            11: processed_data = {origin_data[511:384], inserted_data, origin_data[351:0]};
            12: processed_data = {origin_data[511:416], inserted_data, origin_data[383:0]};
            13: processed_data = {origin_data[511:448], inserted_data, origin_data[415:0]};
            14: processed_data = {origin_data[511:480], inserted_data, origin_data[447:0]};
            15: processed_data = {inserted_data, origin_data[479:0]};
                default: processed_data = origin_data;
            endcase
        else if(half_word_write) 
            case (offset[Offset_len - 1:1])
                    0: processed_data = {origin_data[511:16], inserted_data[15:0]};
            1: processed_data = {origin_data[511:32], inserted_data[15:0], origin_data[15:0]};
            2: processed_data = {origin_data[511:48], inserted_data[15:0], origin_data[31:0]};
            3: processed_data = {origin_data[511:64], inserted_data[15:0], origin_data[47:0]};
            4: processed_data = {origin_data[511:80], inserted_data[15:0], origin_data[63:0]};
            5: processed_data = {origin_data[511:96], inserted_data[15:0], origin_data[79:0]};
            6: processed_data = {origin_data[511:112], inserted_data[15:0], origin_data[95:0]};
            7: processed_data = {origin_data[511:128], inserted_data[15:0], origin_data[111:0]};
            8: processed_data = {origin_data[511:144], inserted_data[15:0], origin_data[127:0]};
            9: processed_data = {origin_data[511:160], inserted_data[15:0], origin_data[143:0]};
            10: processed_data = {origin_data[511:176], inserted_data[15:0], origin_data[159:0]};
            11: processed_data = {origin_data[511:192], inserted_data[15:0], origin_data[175:0]};
            12: processed_data = {origin_data[511:208], inserted_data[15:0], origin_data[191:0]};
            13: processed_data = {origin_data[511:224], inserted_data[15:0], origin_data[207:0]};
            14: processed_data = {origin_data[511:240], inserted_data[15:0], origin_data[223:0]};
            15: processed_data = {origin_data[511:256], inserted_data[15:0], origin_data[239:0]};
            16: processed_data = {origin_data[511:272], inserted_data[15:0], origin_data[255:0]};
            17: processed_data = {origin_data[511:288], inserted_data[15:0], origin_data[271:0]};
            18: processed_data = {origin_data[511:304], inserted_data[15:0], origin_data[287:0]};
            19: processed_data = {origin_data[511:320], inserted_data[15:0], origin_data[303:0]};
            20: processed_data = {origin_data[511:336], inserted_data[15:0], origin_data[319:0]};
            21: processed_data = {origin_data[511:352], inserted_data[15:0], origin_data[335:0]};
            22: processed_data = {origin_data[511:368], inserted_data[15:0], origin_data[351:0]};
            23: processed_data = {origin_data[511:384], inserted_data[15:0], origin_data[367:0]};
            24: processed_data = {origin_data[511:400], inserted_data[15:0], origin_data[383:0]};
            25: processed_data = {origin_data[511:416], inserted_data[15:0], origin_data[399:0]};
            26: processed_data = {origin_data[511:432], inserted_data[15:0], origin_data[415:0]};
            27: processed_data = {origin_data[511:448], inserted_data[15:0], origin_data[431:0]};
            28: processed_data = {origin_data[511:464], inserted_data[15:0], origin_data[447:0]};
            29: processed_data = {origin_data[511:480], inserted_data[15:0], origin_data[463:0]};
            30: processed_data = {origin_data[511:496], inserted_data[15:0], origin_data[479:0]};
            31: processed_data = {inserted_data[15:0], origin_data[495:0]};
                default: processed_data = origin_data;
            endcase
        else if(byte_write)
            case (offset[Offset_len - 1:0])
                    0: processed_data = {origin_data[511:8], inserted_data[7:0]};
            1: processed_data = {origin_data[511:16], inserted_data[7:0], origin_data[7:0]};
            2: processed_data = {origin_data[511:24], inserted_data[7:0], origin_data[15:0]};
            3: processed_data = {origin_data[511:32], inserted_data[7:0], origin_data[23:0]};
            4: processed_data = {origin_data[511:40], inserted_data[7:0], origin_data[31:0]};
            5: processed_data = {origin_data[511:48], inserted_data[7:0], origin_data[39:0]};
            6: processed_data = {origin_data[511:56], inserted_data[7:0], origin_data[47:0]};
            7: processed_data = {origin_data[511:64], inserted_data[7:0], origin_data[55:0]};
            8: processed_data = {origin_data[511:72], inserted_data[7:0], origin_data[63:0]};
            9: processed_data = {origin_data[511:80], inserted_data[7:0], origin_data[71:0]};
            10: processed_data = {origin_data[511:88], inserted_data[7:0], origin_data[79:0]};
            11: processed_data = {origin_data[511:96], inserted_data[7:0], origin_data[87:0]};
            12: processed_data = {origin_data[511:104], inserted_data[7:0], origin_data[95:0]};
            13: processed_data = {origin_data[511:112], inserted_data[7:0], origin_data[103:0]};
            14: processed_data = {origin_data[511:120], inserted_data[7:0], origin_data[111:0]};
            15: processed_data = {origin_data[511:128], inserted_data[7:0], origin_data[119:0]};
            16: processed_data = {origin_data[511:136], inserted_data[7:0], origin_data[127:0]};
            17: processed_data = {origin_data[511:144], inserted_data[7:0], origin_data[135:0]};
            18: processed_data = {origin_data[511:152], inserted_data[7:0], origin_data[143:0]};
            19: processed_data = {origin_data[511:160], inserted_data[7:0], origin_data[151:0]};
            20: processed_data = {origin_data[511:168], inserted_data[7:0], origin_data[159:0]};
            21: processed_data = {origin_data[511:176], inserted_data[7:0], origin_data[167:0]};
            22: processed_data = {origin_data[511:184], inserted_data[7:0], origin_data[175:0]};
            23: processed_data = {origin_data[511:192], inserted_data[7:0], origin_data[183:0]};
            24: processed_data = {origin_data[511:200], inserted_data[7:0], origin_data[191:0]};
            25: processed_data = {origin_data[511:208], inserted_data[7:0], origin_data[199:0]};
            26: processed_data = {origin_data[511:216], inserted_data[7:0], origin_data[207:0]};
            27: processed_data = {origin_data[511:224], inserted_data[7:0], origin_data[215:0]};
            28: processed_data = {origin_data[511:232], inserted_data[7:0], origin_data[223:0]};
            29: processed_data = {origin_data[511:240], inserted_data[7:0], origin_data[231:0]};
            30: processed_data = {origin_data[511:248], inserted_data[7:0], origin_data[239:0]};
            31: processed_data = {origin_data[511:256], inserted_data[7:0], origin_data[247:0]};
            32: processed_data = {origin_data[511:264], inserted_data[7:0], origin_data[255:0]};
            33: processed_data = {origin_data[511:272], inserted_data[7:0], origin_data[263:0]};
            34: processed_data = {origin_data[511:280], inserted_data[7:0], origin_data[271:0]};
            35: processed_data = {origin_data[511:288], inserted_data[7:0], origin_data[279:0]};
            36: processed_data = {origin_data[511:296], inserted_data[7:0], origin_data[287:0]};
            37: processed_data = {origin_data[511:304], inserted_data[7:0], origin_data[295:0]};
            38: processed_data = {origin_data[511:312], inserted_data[7:0], origin_data[303:0]};
            39: processed_data = {origin_data[511:320], inserted_data[7:0], origin_data[311:0]};
            40: processed_data = {origin_data[511:328], inserted_data[7:0], origin_data[319:0]};
            41: processed_data = {origin_data[511:336], inserted_data[7:0], origin_data[327:0]};
            42: processed_data = {origin_data[511:344], inserted_data[7:0], origin_data[335:0]};
            43: processed_data = {origin_data[511:352], inserted_data[7:0], origin_data[343:0]};
            44: processed_data = {origin_data[511:360], inserted_data[7:0], origin_data[351:0]};
            45: processed_data = {origin_data[511:368], inserted_data[7:0], origin_data[359:0]};
            46: processed_data = {origin_data[511:376], inserted_data[7:0], origin_data[367:0]};
            47: processed_data = {origin_data[511:384], inserted_data[7:0], origin_data[375:0]};
            48: processed_data = {origin_data[511:392], inserted_data[7:0], origin_data[383:0]};
            49: processed_data = {origin_data[511:400], inserted_data[7:0], origin_data[391:0]};
            50: processed_data = {origin_data[511:408], inserted_data[7:0], origin_data[399:0]};
            51: processed_data = {origin_data[511:416], inserted_data[7:0], origin_data[407:0]};
            52: processed_data = {origin_data[511:424], inserted_data[7:0], origin_data[415:0]};
            53: processed_data = {origin_data[511:432], inserted_data[7:0], origin_data[423:0]};
            54: processed_data = {origin_data[511:440], inserted_data[7:0], origin_data[431:0]};
            55: processed_data = {origin_data[511:448], inserted_data[7:0], origin_data[439:0]};
            56: processed_data = {origin_data[511:456], inserted_data[7:0], origin_data[447:0]};
            57: processed_data = {origin_data[511:464], inserted_data[7:0], origin_data[455:0]};
            58: processed_data = {origin_data[511:472], inserted_data[7:0], origin_data[463:0]};
            59: processed_data = {origin_data[511:480], inserted_data[7:0], origin_data[471:0]};
            60: processed_data = {origin_data[511:488], inserted_data[7:0], origin_data[479:0]};
            61: processed_data = {origin_data[511:496], inserted_data[7:0], origin_data[487:0]};
            62: processed_data = {origin_data[511:504], inserted_data[7:0], origin_data[495:0]};
            63: processed_data = {inserted_data[7:0], origin_data[503:0]};
                default: processed_data = origin_data;
            endcase
        else 
            processed_data = origin_data;
    end

endmodule
