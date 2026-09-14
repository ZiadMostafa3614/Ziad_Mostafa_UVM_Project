//=============================================================================
// axi_coverage.sv — Functional Coverage Subscriber Class for AXI Transactions
//=============================================================================
`ifndef AXI_COVERAGE_SV
`define AXI_COVERAGE_SV

class axi_coverage extends uvm_subscriber #(axi_seq_item);

    `uvm_component_utils(axi_coverage)

    axi_seq_item item;

    covergroup cg_axi4;
        cp_op: coverpoint item.op {
            bins WRITE = {OP_WRITE};
            bins READ  = {OP_READ};
        }

        cp_len: coverpoint item.len {
            bins SINGLE   = {0};
            bins SHORT    = {[1:3]};
            bins MEDIUM   = {[4:7]};
            bins LONG     = {[8:15]};
        }

        cp_size: coverpoint item.size {
            bins WORD  = {3'b010};
            bins OTHER = default;
        }

        cp_region: coverpoint item.addr {
            bins INTERIOR     = {[16'h0000 : 16'h0FBF]};
            bins NEAR_EDGE    = {[16'h0FC0 : 16'h0FFF]};
            bins OUT_OF_RANGE = {[16'h1000 : 16'hFFFF]};
        }

        cp_resp: coverpoint item.resp {
            bins OKAY   = {RESP_OKAY};
            bins SLVERR = {RESP_SLVERR};
        }

        x_op_resp: cross cp_op, cp_resp;

        x_len_region: cross cp_len, cp_region {
            ignore_bins OOB_MULTI = binsof(cp_region.OUT_OF_RANGE) && !binsof(cp_len.SINGLE);
        }
    endgroup

    function new(string name = "axi_coverage", uvm_component parent = null);
        super.new(name, parent);
        cg_axi4 = new();
    endfunction

    virtual function void write(axi_seq_item t);
        item = t;
        cg_axi4.sample();
    endfunction

endclass : axi_coverage

`endif
