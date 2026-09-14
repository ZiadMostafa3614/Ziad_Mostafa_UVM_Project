//=============================================================================
// axi_uvm_pkg.sv — Top UVM Verification Package
//=============================================================================
`ifndef AXI_UVM_PKG_SV
`define AXI_UVM_PKG_SV

package axi_uvm_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Sequence Item & Sequences
    `include "axi_seq_item.sv"
    `include "axi_sequences.sv"
    `include "axi_sequencer.sv"

    // Active Agent Components
    `include "axi_driver.sv"
    `include "axi_driver_delay.sv"
    `include "axi_monitor.sv"
    `include "axi_coverage.sv"
    `include "axi_scoreboard.sv"
    `include "axi_active_agent.sv"

    // Passive Memory Agent Components
    `include "mem_monitor.sv"
    `include "mem_coverage.sv"
    `include "mem_checker.sv"
    `include "mem_passive_agent.sv"

    // Top Environment & Tests
    `include "axi_env.sv"
    `include "axi_tests.sv"

endpackage : axi_uvm_pkg

`endif
