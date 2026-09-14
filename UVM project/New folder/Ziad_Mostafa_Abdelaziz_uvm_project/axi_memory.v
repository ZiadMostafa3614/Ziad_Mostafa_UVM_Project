//=============================================================================
// axi_memory.v — True Dual-Port Synchronous SRAM Model
//=============================================================================
module axi4_memory #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10,
    parameter DEPTH = 1024
)(
    input  wire                  clk,
    input  wire                  rst_n,

    // Independent Write Port
    input  wire                  write_en,
    input  wire [ADDR_WIDTH-1:0] write_addr,
    input  wire [DATA_WIDTH-1:0] write_data,

    // Independent Read Port
    input  wire                  read_en,
    input  wire [ADDR_WIDTH-1:0] read_addr,
    output wire [DATA_WIDTH-1:0] read_data
);

    // Memory Storage
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    integer j;

    // Synchronous Write Port Operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (j = 0; j < DEPTH; j = j + 1) begin
                mem[j] <= {DATA_WIDTH{1'b0}};
            end
        end else if (write_en) begin
            mem[write_addr] <= write_data;
        end
    end

    // Combinational Read Port (Zero-latency RAM read output)
    assign read_data = mem[read_addr];

endmodule
