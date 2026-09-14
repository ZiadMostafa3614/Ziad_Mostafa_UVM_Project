//=============================================================================
// axi_seq_item.sv — UVM Transaction Object for AXI4 Operations
//=============================================================================
`ifndef AXI_SEQ_ITEM_SV
`define AXI_SEQ_ITEM_SV

typedef enum bit [1:0] {
    OP_WRITE = 2'b00,
    OP_READ  = 2'b01
} axi_op_e;

typedef enum bit [1:0] {
    RESP_OKAY   = 2'b00,
    RESP_EXOKAY = 2'b01,
    RESP_SLVERR = 2'b10,
    RESP_DECERR = 2'b11
} axi_resp_e;

class axi_seq_item extends uvm_sequence_item;

    // Transaction Fields
    rand axi_op_e         op;
    rand bit [15:0]       addr;
    rand bit [7:0]        len;
    rand bit [2:0]        size;
    rand bit [31:0]       wdata[];
    rand bit              inject_delay;
    rand int unsigned     delay_cycles;

    // Coverage Closure Injection Flags
    bit                   inject_bready_delay;  // Delay BREADY to cover BREADY_0 FEC row
    bit                   inject_rready_delay;  // Delay RREADY to cover RREADY_0 FEC row
    bit                   inject_wvalid_bubble; // Drop WVALID 1 cycle mid-burst

    // Response & Analysis Fields
    axi_resp_e            resp;
    bit [31:0]            rdata[];

    // UVM Automation Macros
    `uvm_object_utils_begin(axi_seq_item)
        `uvm_field_enum(axi_op_e, op, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(len, UVM_ALL_ON)
        `uvm_field_int(size, UVM_ALL_ON)
        `uvm_field_array_int(wdata, UVM_ALL_ON)
        `uvm_field_enum(axi_resp_e, resp, UVM_ALL_ON)
        `uvm_field_array_int(rdata, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constraints
    // soft constraints allow directed sequences to override SIZE/ADDR/dist
    constraint c_default_size { soft size == 3'b010; }
    constraint c_aligned_addr { soft addr[1:0] == 2'b00; }
    constraint c_wdata_size   { wdata.size() == (len + 1); }
    constraint c_delay_range  { delay_cycles inside {[1:5]}; }

    // Address distribution constraint — soft so directed sequences can drive any address
    constraint c_addr_dist {
        soft addr inside {
            [16'h0000 : 16'h0FBC],
            [16'h0FC0 : 16'h0FFF],
            [16'h1000 : 16'h2000]
        };
    }

    function new(string name = "axi_seq_item");
        super.new(name);
    endfunction

endclass : axi_seq_item

`endif
