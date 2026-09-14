//=============================================================================
// top.sv — Top Level Testbench Module for AXI4 UVM Verification
//=============================================================================
`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"
import axi_uvm_pkg::*;

module top;

    logic ACLK;
    logic ARESETn;

    // Clock Generator: 100 MHz (10ns period)
    initial begin
        ACLK = 0;
        forever #5 ACLK = ~ACLK;
    end

    // Interface Instance
    axi4_if #(.DATA_WIDTH(32), .ADDR_WIDTH(16)) vif (.ACLK(ACLK), .ARESETn(ARESETn));

    // Design Under Test (DUT) Instance
    axi4 #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(16),
        .MEMORY_DEPTH(1024)
    ) dut (
        .ACLK    (ACLK),
        .ARESETn (ARESETn),
        .AWADDR  (vif.AWADDR),  .AWLEN (vif.AWLEN),  .AWSIZE (vif.AWSIZE),  .AWVALID (vif.AWVALID),  .AWREADY (vif.AWREADY),
        .WDATA   (vif.WDATA),   .WVALID(vif.WVALID), .WLAST  (vif.WLAST),  .WREADY  (vif.WREADY),
        .BRESP   (vif.BRESP),   .BVALID(vif.BVALID), .BREADY (vif.BREADY),
        .ARADDR  (vif.ARADDR),  .ARLEN (vif.ARLEN),  .ARSIZE (vif.ARSIZE), .ARVALID (vif.ARVALID),  .ARREADY (vif.ARREADY),
        .RDATA   (vif.RDATA),   .RRESP (vif.RRESP),  .RVALID (vif.RVALID), .RLAST   (vif.RLAST),    .RREADY  (vif.RREADY)
    );

    // SystemVerilog Assertions (SVA) Module Binding
    bind axi4 axi4_checker #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(16)
    ) checker_inst (
        .ACLK(ACLK), .ARESETn(ARESETn),
        .AWADDR(AWADDR), .AWLEN(AWLEN), .AWSIZE(AWSIZE),
        .AWVALID(AWVALID), .AWREADY(AWREADY),
        .WDATA(WDATA), .WVALID(WVALID), .WLAST(WLAST), .WREADY(WREADY),
        .BRESP(BRESP), .BVALID(BVALID), .BREADY(BREADY),
        .ARADDR(ARADDR), .ARLEN(ARLEN), .ARSIZE(ARSIZE),
        .ARVALID(ARVALID), .ARREADY(ARREADY),
        .RDATA(RDATA), .RRESP(RRESP), .RVALID(RVALID), .RLAST(RLAST), .RREADY(RREADY)
    );

    // Reset Sequence
    initial begin
        ARESETn = 0;
        #50;
        ARESETn = 1;
        `uvm_info("TOP", "System Reset Released.", UVM_LOW)
    end

    // UVM Configuration & Test Invocation (runs at time 0)
    initial begin
        // Store virtual interface into uvm_config_db
        uvm_config_db #(virtual axi4_if)::set(null, "*", "vif", vif);

        // Invoke UVM Test at time 0
        run_test();
    end

    // Waveform Dumps
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, top);
    end

endmodule : top
