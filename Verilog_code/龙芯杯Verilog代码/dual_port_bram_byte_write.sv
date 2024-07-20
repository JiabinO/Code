`timescale 1ns / 1ps
module dual_port_bram_byte_write #(
    parameter NB_COL    = 64,                       // Specify number of columns (number of bytes)
    parameter COL_WIDTH = 8,                        // Specify column width (byte width, typically 8 or 9)
    parameter RAM_DEPTH = 64                        // Specify RAM depth (number of entries)
  )(
    input [$clog2(RAM_DEPTH)-1:0] addra,  // Write address bus, width determined from RAM_DEPTH
    input [$clog2(RAM_DEPTH)-1:0] addrb,  // Read address bus, width determined from RAM_DEPTH
    input [(NB_COL*COL_WIDTH)-1:0] dina,  // RAM input data
    input clka,                           // Write clock
    input [NB_COL-1:0] wea,               // Byte-write enable
    output [(NB_COL*COL_WIDTH)-1:0] doutb // RAM output data
  );
  (*ram_style="block"*)
    reg [(NB_COL*COL_WIDTH)-1:0] BRAM [RAM_DEPTH-1:0];
    reg [$clog2(RAM_DEPTH)-1:0] addr_r;
    // The following code either initializes the memory values to a specified file or to all zeros to match hardware
    generate
        integer ram_index;
        initial
          for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
            BRAM[ram_index] = {(NB_COL*COL_WIDTH){1'b0}};
    endgenerate
  
    always @(posedge clka)
        addr_r <= addra == addrb ? addra : addrb;
    assign doutb = BRAM[addr_r];

    generate
    genvar i;
       for (i = 0; i < NB_COL; i = i+1) begin: byte_write
         always @(posedge clka)
           if (wea[i]) 
             BRAM[addra][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= dina[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
        end
    endgenerate
  endmodule
