module xilinx_single_port_ram_write_first #(
  parameter RAM_WIDTH = 18,                       // Specify RAM data width
  parameter RAM_DEPTH = 1024                     // Specify RAM depth (number of entries)
) (
  input [$clog2(RAM_DEPTH)-1:0] addra,  // Address bus, width determined from RAM_DEPTH
  input [RAM_WIDTH-1:0] dina,           // RAM input data
  input clka,                           // Clock
  input wea,                            // Write enable
  output [RAM_WIDTH-1:0] douta          // RAM output data
);
(*ram_style="block"*)
  reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_data = {RAM_WIDTH{1'b0}};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          BRAM[ram_index] = {RAM_WIDTH{1'b0}};
  endgenerate
  
  always @(posedge clka) begin
      if (wea) begin
        BRAM[addra] <= dina;
        ram_data <= dina;
      end else
        ram_data <= BRAM[addra];
  end
endmodule