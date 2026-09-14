//=============================================================================
// mem_coverage.sv — Custom Memory Behavior Functional Coverage Collector
//=============================================================================
`ifndef MEM_COVERAGE_SV
`define MEM_COVERAGE_SV

class mem_coverage extends uvm_subscriber #(mem_access_item);

    `uvm_component_utils(mem_coverage)

    mem_access_item item;

    covergroup cg_sram_behavior;
        cp_mem_wr: coverpoint item.write_en {
            bins INACTIVE = {0};
            bins ACTIVE   = {1};
        }

        cp_mem_rd: coverpoint item.read_en {
            bins INACTIVE = {0};
            bins ACTIVE   = {1};
        }

        cp_mem_depth: coverpoint item.write_addr {
            bins LOW_RANGE  = {[0:255]};
            bins MID_RANGE  = {[256:767]};
            bins HIGH_RANGE = {[768:1023]};
        }

        x_rw_simultaneous: cross cp_mem_wr, cp_mem_rd {
            ignore_bins BOTH_IDLE = binsof(cp_mem_wr.INACTIVE) && binsof(cp_mem_rd.INACTIVE);
            ignore_bins DUAL_ACTIVE = binsof(cp_mem_wr.ACTIVE) && binsof(cp_mem_rd.ACTIVE);
        }
    endgroup

    function new(string name = "mem_coverage", uvm_component parent = null);
        super.new(name, parent);
        cg_sram_behavior = new();
    endfunction

    virtual function void write(mem_access_item t);
        item = t;
        cg_sram_behavior.sample();
    endfunction

endclass : mem_coverage

`endif
