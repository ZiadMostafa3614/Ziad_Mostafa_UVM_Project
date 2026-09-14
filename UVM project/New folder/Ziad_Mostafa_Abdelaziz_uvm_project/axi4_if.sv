//=============================================================================
// axi4_if.sv — SystemVerilog Interface for AXI4 Bus & Memory Signals
//=============================================================================
interface axi4_if #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16
)(
    input logic ACLK,
    input logic ARESETn
);

    // AXI Write Address Channel
    logic [ADDR_WIDTH-1:0] AWADDR;
    logic [7:0]            AWLEN;
    logic [2:0]            AWSIZE;
    logic                  AWVALID;
    logic                  AWREADY;

    // AXI Write Data Channel
    logic [DATA_WIDTH-1:0] WDATA;
    logic                  WVALID;
    logic                  WLAST;
    logic                  WREADY;

    // AXI Write Response Channel
    logic [1:0]            BRESP;
    logic                  BVALID;
    logic                  BREADY;

    // AXI Read Address Channel
    logic [ADDR_WIDTH-1:0] ARADDR;
    logic [7:0]            ARLEN;
    logic [2:0]            ARSIZE;
    logic                  ARVALID;
    logic                  ARREADY;

    // AXI Read Data Channel
    logic [DATA_WIDTH-1:0] RDATA;
    logic [1:0]            RRESP;
    logic                  RVALID;
    logic                  RLAST;
    logic                  RREADY;

    // Clocking block for UVM Active Driver
    clocking drv_cb @(posedge ACLK);
        default input #1ns output #1ns;
        output AWADDR, AWLEN, AWSIZE, AWVALID;
        input  AWREADY;
        output WDATA, WVALID, WLAST;
        input  WREADY;
        input  BRESP, BVALID;
        output BREADY;
        output ARADDR, ARLEN, ARSIZE, ARVALID;
        input  ARREADY;
        input  RDATA, RRESP, RVALID, RLAST;
        output RREADY;
    endclocking

    // Clocking block for UVM Active Monitor
    clocking mon_cb @(posedge ACLK);
        default input #1ns output #1ns;
        input AWADDR, AWLEN, AWSIZE, AWVALID, AWREADY;
        input WDATA, WVALID, WLAST, WREADY;
        input BRESP, BVALID, BREADY;
        input ARADDR, ARLEN, ARSIZE, ARVALID, ARREADY;
        input RDATA, RRESP, RVALID, RLAST, RREADY;
    endclocking

    modport DRIVER  (clocking drv_cb, input ACLK, input ARESETn);
    modport MONITOR (clocking mon_cb, input ACLK, input ARESETn);

endinterface
