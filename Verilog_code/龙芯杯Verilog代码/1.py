def generate_verilog_code(offset_len):
    segment_width = 32
    total_width = (1 << (offset_len + 3))
    num_segments = total_width // segment_width

    case_statements_way1 = []
    case_statements_way2 = []

    for i in range(num_segments):
        case_statements_way1.append(f"                {i}: mux_output_data = way1_rdata_reg[{segment_width*(i+1)-1}:{segment_width*i}];")
        case_statements_way2.append(f"                {i}: mux_output_data = way2_rdata_reg[{segment_width*(i+1)-1}:{segment_width*i}];")

    case_statements_way1 = "\n".join(case_statements_way1)
    case_statements_way2 = "\n".join(case_statements_way2)

    template = f"""
`timescale 1ns / 1ps
module data_mux #(
    parameter Offset_len = {offset_len},
    parameter Segment_width = 32
)(
    input wire last_used_way,
    input wire [Offset_len-1:0] offset,
    input wire [{total_width-1}:0] way1_rdata_reg,
    input wire [{total_width-1}:0] way2_rdata_reg,
    input wire [1:0] hit,
    output reg [Segment_width-1:0] mux_output_data
);

    localparam Total_width = {total_width};
    localparam Num_segments = {num_segments};

    always @(*) begin
        if (hit[0]) begin
            case (offset[Offset_len-1:2])
{case_statements_way1}
                default: mux_output_data = 0; 
            endcase
        end
        else if (hit[1]) begin
            case (offset[Offset_len-1:2])
{case_statements_way2}
                default: mux_output_data = 0; 
            endcase
        end
        else if (last_used_way) begin
            case (offset[Offset_len-1:2])
{case_statements_way2}
                default: mux_output_data = 0; 
            endcase
        end else begin
            case (offset[Offset_len-1:2])
{case_statements_way1}
                default: mux_output_data = 0; 
            endcase
        end
    end

endmodule
"""
    return template

def generate_verilog_mux_mem_code(offset_len):
    segment_width = 32
    total_width = (1 << (offset_len + 3))
    num_segments = total_width // segment_width

    case_statements = []

    for i in range(num_segments):
        case_statements.append(f"            {i}: mux_mem_rdata = mem_rdata[{segment_width*(i+1)-1}:{segment_width*i}];")

    case_statements_str = "\n".join(case_statements)

    template = f"""
`timescale 1ns / 1ps
module mux_mem #(
    parameter Offset_len = {offset_len},
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
{case_statements_str}
            default: mux_mem_rdata = 0; 
        endcase
    end

endmodule
"""
    return template


def generate_verilog_insert_data(offset_len):
    segment_width = 32
    total_width = (1 << (offset_len + 3))
    num_segments = total_width // segment_width

    case_statements = []

    for i in range(num_segments):
        if i == 0:
            case_statements.append(f"            {i}: processed_data = {{origin_data[{total_width-1}:{segment_width}], inserted_data}};")
        elif i == num_segments - 1:
            case_statements.append(f"            {i}: processed_data = {{inserted_data, origin_data[{total_width-segment_width-1}:0]}};")
        else:
            case_statements.append(f"            {i}: processed_data = {{origin_data[{total_width-1}:{segment_width*(i+1)}], inserted_data, origin_data[{segment_width*i-1}:0]}};")

    case_statements_str1 = "\n".join(case_statements)

    case_statements = []
    segment_width = 16
    num_segments = total_width // segment_width
    for i in range(num_segments):
        if i == 0:
            case_statements.append(f"            {i}: processed_data = {{origin_data[{total_width-1}:{segment_width}], inserted_data[15:0]}};")
        elif i == num_segments - 1:
            case_statements.append(f"            {i}: processed_data = {{inserted_data[15:0], origin_data[{total_width-segment_width-1}:0]}};")
        else:
            case_statements.append(f"            {i}: processed_data = {{origin_data[{total_width-1}:{segment_width*(i+1)}], inserted_data[15:0], origin_data[{segment_width*i-1}:0]}};")   
    case_statements_str2 = "\n".join(case_statements)

    case_statements = []
    segment_width = 8
    num_segments = total_width // segment_width
    for i in range(num_segments):
        if i == 0:
            case_statements.append(f"            {i}: processed_data = {{origin_data[{total_width-1}:{segment_width}], inserted_data[7:0]}};")
        elif i == num_segments - 1:
            case_statements.append(f"            {i}: processed_data = {{inserted_data[7:0], origin_data[{total_width-segment_width-1}:0]}};")
        else:
            case_statements.append(f"            {i}: processed_data = {{origin_data[{total_width-1}:{segment_width*(i+1)}], inserted_data[7:0], origin_data[{segment_width*i-1}:0]}};")   
    case_statements_str3 = "\n".join(case_statements)

    template = f"""
`timescale 1ns / 1ps
module insert_data #(
    parameter Offset_len = {offset_len}
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
        {case_statements_str1}
                default: processed_data = origin_data;
            endcase
        else if(half_word_write) 
            case (offset[Offset_len - 1:1])
        {case_statements_str2}
                default: processed_data = origin_data;
            endcase
        else if(byte_write)
            case (offset[Offset_len - 1:0])
        {case_statements_str3}
                default: processed_data = origin_data;
            endcase
        else 
            processed_data = origin_data;
    end

endmodule
"""
    return template

def generate_verilog_write_data_mux(offset_len):
    segment_width = 32
    total_width = (1 << (offset_len + 3))
    num_segments = total_width // segment_width

    case_statements = []

    for i in range(num_segments):
        case_statements.append(f"            {i}: write_data_mux = d_wdata[{segment_width*(i+1)-1}:{segment_width*i}];")

    case_statements_str = "\n".join(case_statements)

    template = f"""
`timescale 1ns / 1ps
module mux_write_data #(
    parameter Offset_len = {offset_len},
    parameter Segment_width = 32
)(
    input wire [Offset_len-2:0] buf_shift_count,
    input wire [(1 << (Offset_len + 3)) - 1:0] d_wdata,
    output reg [Segment_width-1:0] write_data_mux
);

    always @(*) begin
        case (buf_shift_count[Offset_len-2:0])
{case_statements_str}
            default: write_data_mux = 0; 
        endcase
    end

endmodule
"""
    return template

def generate_verilog_DCache_rdata_mux(offset_len):
    segment_width = 32
    total_width = (1 << (offset_len + 3))
    num_segments = total_width // segment_width

    case_statements = []

    for i in range(num_segments):
        case_statements.append(f"            {i}: mux_rdata = DCache_rdata_block[{segment_width*(i+1)-1}:{segment_width*i}];")

    case_statements_str = "\n".join(case_statements)

    template = f"""
`timescale 1ns / 1ps
module DCache_rdata_mux #(
    parameter Offset_len = {offset_len}
)(
    input wire [(1 << (Offset_len + 3)) - 1:0] DCache_rdata_block,
    input wire [Offset_len - 1:0] offset,
    output reg [31:0] mux_rdata
);

    always @(*) begin
        case (offset[Offset_len - 1: 2])
{case_statements_str}
            default: mux_rdata = 0; 
        endcase
    end

endmodule
"""
    return template

offset_len = 6  # 设置Offset_len的值
verilog_code = generate_verilog_code(offset_len)

with open("data_mux.v", "w") as f:
    f.write(verilog_code)

# verilog_code = generate_verilog_mux_mem_code(offset_len)
# with open("mux_mem.v", "w") as f:
#     f.write(verilog_code)

# verilog_code = generate_verilog_insert_data(offset_len)

# with open("insert_data.v", "w") as f:
#     f.write(verilog_code)

# verilog_code = generate_verilog_write_data_mux(offset_len)

# with open("mux_write_data.v", "w") as f:
#     f.write(verilog_code)

# verilog_code = generate_verilog_DCache_rdata_mux(offset_len)

# with open("DCache_rdata_mux.v", "w") as f:
#     f.write(verilog_code)
    
print("Verilog code generated successfully.")

