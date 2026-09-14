//=============================================================================
// axi4.v — Fixed AXI4 Memory-Mapped Slave Controller (Dual-Port Interface)
//=============================================================================
module axi4 #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter MEMORY_DEPTH = 1024
)(
    input  wire                     ACLK,
    input  wire                     ARESETn,

    // Write address channel
    input  wire [ADDR_WIDTH-1:0]    AWADDR,
    input  wire [7:0]               AWLEN,
    input  wire [2:0]               AWSIZE,
    input  wire                     AWVALID,
    output reg                      AWREADY,

    // Write data channel
    input  wire [DATA_WIDTH-1:0]    WDATA,
    input  wire                     WVALID,
    input  wire                     WLAST,
    output reg                      WREADY,

    // Write response channel
    output reg [1:0]                BRESP,
    output reg                      BVALID,
    input  wire                     BREADY,

    // Read address channel
    input  wire [ADDR_WIDTH-1:0]    ARADDR,
    input  wire [7:0]               ARLEN,
    input  wire [2:0]               ARSIZE,
    input  wire                     ARVALID,
    output reg                      ARREADY,

    // Read data channel
    output wire [DATA_WIDTH-1:0]    RDATA,
    output reg [1:0]                RRESP,
    output reg                      RVALID,
    output reg                      RLAST,
    input  wire                     RREADY
);

    // Memory interface signals (independent read and write ports)
    reg write_en;
    reg [$clog2(MEMORY_DEPTH)-1:0] write_addr_reg;
    reg [DATA_WIDTH-1:0] mem_wdata;

    reg read_en;
    reg [$clog2(MEMORY_DEPTH)-1:0] read_addr_reg;
    wire [DATA_WIDTH-1:0] mem_rdata;

    // Direct combinational connection from RAM read port to AXI RDATA bus
    assign RDATA = mem_rdata;

    // Address & Burst Tracking
    reg [ADDR_WIDTH-1:0] write_addr, read_addr;
    reg [ADDR_WIDTH-1:0] write_start_addr, read_start_addr;
    reg [7:0] write_burst_len, read_burst_len;
    reg [7:0] write_burst_cnt, read_burst_cnt;
    reg [2:0] write_size, read_size;

    wire [ADDR_WIDTH-1:0] write_addr_incr, read_addr_incr;

    assign write_addr_incr = (1 << write_size);
    assign read_addr_incr  = (1 << read_size);

    // Static 4KB boundary cross check (latched at address phase)
    wire write_boundary_cross = ((write_start_addr & 12'hFFF) + ((write_burst_len + 1) << write_size)) > 12'hFFF;
    wire read_boundary_cross  = ((read_start_addr  & 12'hFFF) + ((read_burst_len  + 1) << read_size))  > 12'hFFF;

    // Address range check (4KB = 1024 words)
    wire write_addr_valid = (write_start_addr >> 2) < MEMORY_DEPTH;
    wire read_addr_valid  = (read_start_addr  >> 2) < MEMORY_DEPTH;

    // Dual-Port Synchronous Memory Instance
    axi4_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH($clog2(MEMORY_DEPTH)),
        .DEPTH(MEMORY_DEPTH)
    ) mem_inst (
        .clk(ACLK),
        .rst_n(ARESETn),
        .write_en(write_en),
        .write_addr(write_addr_reg),
        .write_data(mem_wdata),
        .read_en(read_en),
        .read_addr(read_addr_reg),
        .read_data(mem_rdata)
    );

    // FSM States
    reg [1:0] write_state;
    localparam W_IDLE = 2'd0,
               W_DATA = 2'd1,
               W_RESP = 2'd2;

    reg [1:0] read_state;
    localparam R_IDLE = 2'd0,
               R_DATA = 2'd1;

    //-------------------------------------------------------------------------
    // Write Channel FSM
    //-------------------------------------------------------------------------
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            write_state      <= W_IDLE;
            AWREADY          <= 1'b1;
            WREADY           <= 1'b0;
            BVALID           <= 1'b0;
            BRESP            <= 2'b00;
            write_en         <= 1'b0;
            write_addr       <= '0;
            write_start_addr <= '0;
            write_burst_len  <= '0;
            write_burst_cnt  <= '0;
            write_size       <= '0;
            write_addr_reg   <= '0;
            mem_wdata        <= '0;
        end else begin
            write_en <= 1'b0;  // Default pulse

            case (write_state)
                W_IDLE: begin
                    AWREADY <= 1'b1;
                    WREADY  <= 1'b0;
                    BVALID  <= 1'b0;

                    if (AWVALID && AWREADY) begin
                        write_addr       <= AWADDR;
                        write_start_addr <= AWADDR;
                        write_burst_len  <= AWLEN;
                        write_burst_cnt  <= AWLEN;
                        write_size       <= AWSIZE;

                        AWREADY     <= 1'b0;
                        WREADY      <= 1'b1;
                        write_state <= W_DATA;
                    end
                end

                W_DATA: begin
                    WREADY <= 1'b1;
                    if (WVALID && WREADY) begin
                        if (write_addr_valid && !write_boundary_cross) begin
                            write_en       <= 1'b1;
                            write_addr_reg <= write_addr >> 2;
                            mem_wdata      <= WDATA;
                        end

                        if (WLAST || (write_burst_cnt == 0)) begin
                            WREADY      <= 1'b0;
                            write_state <= W_RESP;
                            BVALID      <= 1'b1;
                            if (!write_addr_valid || write_boundary_cross) begin
                                BRESP <= 2'b10; // SLVERR
                            end else begin
                                BRESP <= 2'b00; // OKAY
                            end
                        end else begin
                            write_addr      <= write_addr + write_addr_incr;
                            write_burst_cnt <= write_burst_cnt - 1'b1;
                        end
                    end
                end

                W_RESP: begin
                    if (BREADY && BVALID) begin
                        BVALID      <= 1'b0;
                        BRESP       <= 2'b00;
                        AWREADY     <= 1'b1;
                        write_state <= W_IDLE;
                    end
                end

                // coverage off -- default arm unreachable: write_state encoding uses only 3 of 4 values
                default: write_state <= W_IDLE;
                // coverage on
            endcase
        end
    end

    //-------------------------------------------------------------------------
    // Read Channel FSM
    //-------------------------------------------------------------------------
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            read_state      <= R_IDLE;
            ARREADY         <= 1'b1;
            RVALID          <= 1'b0;
            RRESP           <= 2'b00;
            RLAST           <= 1'b0;
            read_en         <= 1'b0;
            read_addr       <= '0;
            read_start_addr <= '0;
            read_burst_len  <= '0;
            read_burst_cnt  <= '0;
            read_size       <= '0;
            read_addr_reg   <= '0;
        end else begin
            case (read_state)
                R_IDLE: begin
                    ARREADY <= 1'b1;
                    RVALID  <= 1'b0;
                    RLAST   <= 1'b0;

                    if (ARVALID && ARREADY) begin
                        read_addr       <= ARADDR;
                        read_start_addr <= ARADDR;
                        read_burst_len  <= ARLEN;
                        read_burst_cnt  <= ARLEN;
                        read_size       <= ARSIZE;

                        ARREADY       <= 1'b0;
                        read_en       <= 1'b1;
                        read_addr_reg <= ARADDR >> 2;
                        read_state    <= R_DATA;
                    end
                end

                R_DATA: begin
                    if (read_addr_valid && !read_boundary_cross) begin
                        RRESP <= 2'b00; // OKAY
                    end else begin
                        RRESP <= 2'b10; // SLVERR
                    end

                    RVALID <= 1'b1;
                    RLAST  <= (read_burst_cnt == 0);

                    if (RREADY && RVALID) begin
                        if (read_burst_cnt > 0) begin
                            read_addr      <= read_addr + read_addr_incr;
                            read_burst_cnt <= read_burst_cnt - 1'b1;

                            read_en       <= 1'b1;
                            read_addr_reg <= (read_addr + read_addr_incr) >> 2;
                            // Pre-drive RLAST for the NEXT beat using decremented count
                            RLAST         <= (read_burst_cnt - 1'b1 == 0);
                        end else begin
                            RVALID     <= 1'b0;
                            RLAST      <= 1'b0;
                            ARREADY    <= 1'b1;
                            read_en    <= 1'b0;
                            read_state <= R_IDLE;
                        end
                    end
                end

                // coverage off -- default arm unreachable: read_state encoding uses only 2 of 4 values
                default: read_state <= R_IDLE;
                // coverage on
            endcase
        end
    end

endmodule
