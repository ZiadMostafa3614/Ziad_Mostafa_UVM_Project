//=============================================================================
// axi4_assertions.sv — SystemVerilog Concurrent Protocol Assertions (SVA)
//=============================================================================
module axi4_checker #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 16
) (
    input logic ACLK, ARESETn,
    input logic [ADDR_WIDTH-1:0] AWADDR, input logic [7:0] AWLEN, input logic [2:0] AWSIZE,
    input logic AWVALID, input logic AWREADY,
    input logic [DATA_WIDTH-1:0] WDATA, input logic WVALID, input logic WLAST, input logic WREADY,
    input logic [1:0] BRESP, input logic BVALID, input logic BREADY,
    input logic [ADDR_WIDTH-1:0] ARADDR, input logic [7:0] ARLEN, input logic [2:0] ARSIZE,
    input logic ARVALID, input logic ARREADY,
    input logic [DATA_WIDTH-1:0] RDATA, input logic [1:0] RRESP, input logic RVALID, input logic RLAST, input logic RREADY
);

    // Stability assertions
    property p_aw_stable;
        @(posedge ACLK) disable iff (!ARESETn)
        (AWVALID && !AWREADY) |=> $stable(AWVALID) && $stable(AWADDR) && $stable(AWLEN) && $stable(AWSIZE);
    endproperty
    a_aw_stable: assert property (p_aw_stable)
        else $error("[SVA] AWVALID/AWADDR/AWLEN/AWSIZE changed while AWVALID was asserted and not yet accepted");

    property p_w_stable;
        @(posedge ACLK) disable iff (!ARESETn)
        (WVALID && !WREADY) |=> $stable(WVALID) && $stable(WDATA) && $stable(WLAST);
    endproperty
    a_w_stable: assert property (p_w_stable)
        else $error("[SVA] WVALID/WDATA/WLAST changed while WVALID was asserted and not yet accepted");

    property p_b_stable;
        @(posedge ACLK) disable iff (!ARESETn)
        (BVALID && !BREADY) |=> $stable(BVALID) && $stable(BRESP);
    endproperty
    a_b_stable: assert property (p_b_stable)
        else $error("[SVA] BVALID/BRESP changed while BVALID was asserted and not yet accepted");

    property p_ar_stable;
        @(posedge ACLK) disable iff (!ARESETn)
        (ARVALID && !ARREADY) |=> $stable(ARVALID) && $stable(ARADDR) && $stable(ARLEN) && $stable(ARSIZE);
    endproperty
    a_ar_stable: assert property (p_ar_stable)
        else $error("[SVA] ARVALID/ARADDR/ARLEN/ARSIZE changed while ARVALID was asserted and not yet accepted");

    property p_r_stable;
        @(posedge ACLK) disable iff (!ARESETn)
        (RVALID && !RREADY) |=> $stable(RVALID) && $stable(RDATA) && $stable(RRESP) && $stable(RLAST);
    endproperty
    a_r_stable: assert property (p_r_stable)
        else $error("[SVA] RVALID/RDATA/RRESP/RLAST changed while RVALID was asserted and not yet accepted");

    // Beat count assertions
    logic [7:0] w_beat_cnt, awlen_latched;
    logic [7:0] r_beat_cnt, arlen_latched;

    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            w_beat_cnt <= '0; awlen_latched <= '0;
            r_beat_cnt <= '0; arlen_latched <= '0;
        end else begin
            if ((AWVALID & AWREADY) == 1'b1) begin
                awlen_latched <= AWLEN;
                w_beat_cnt    <= '0;
            end else if ((((WVALID & WREADY) == 1'b1) & !WLAST) == 1'b1) begin
                w_beat_cnt <= w_beat_cnt + 1'b1;
            end

            if ((ARVALID & ARREADY) == 1'b1) begin
                arlen_latched <= ARLEN;
                r_beat_cnt    <= '0;
            end else if ((((RVALID & RREADY) == 1'b1) & !RLAST) == 1'b1) begin
                r_beat_cnt <= r_beat_cnt + 1'b1;
            end
        end
    end

    property p_wlast_not_early;
        @(posedge ACLK) disable iff (!ARESETn)
        (WVALID && WREADY && WLAST) |-> (w_beat_cnt == awlen_latched);
    endproperty
    a_wlast_not_early: assert property (p_wlast_not_early)
        else $error("[SVA] WLAST asserted before the AWLEN-implied beat count was reached");

    property p_wlast_not_late;
        @(posedge ACLK) disable iff (!ARESETn)
        (WVALID && WREADY && (w_beat_cnt == awlen_latched)) |-> WLAST;
    endproperty
    a_wlast_not_late: assert property (p_wlast_not_late)
        else $error("[SVA] WLAST missing on the beat where the AWLEN-implied count was reached");

    property p_rlast_not_early;
        @(posedge ACLK) disable iff (!ARESETn)
        (RVALID && RREADY && RLAST) |-> (r_beat_cnt == arlen_latched);
    endproperty
    a_rlast_not_early: assert property (p_rlast_not_early)
        else $error("[SVA] RLAST asserted before the ARLEN-implied beat count was reached");

    property p_rlast_not_late;
        @(posedge ACLK) disable iff (!ARESETn)
        (RVALID && RREADY && (r_beat_cnt == arlen_latched)) |-> RLAST;
    endproperty
    a_rlast_not_late: assert property (p_rlast_not_late)
        else $error("[SVA] RLAST missing on the beat where the ARLEN-implied count was reached");

    // RDATA Latency & Burst Streaming assertion:
    property p_rvalid_burst_streaming;
        @(posedge ACLK) disable iff (!ARESETn)
        (RVALID && RREADY && !RLAST) |=> RVALID;
    endproperty
    a_rvalid_burst_streaming: assert property (p_rvalid_burst_streaming)
        else $error("[SVA] RVALID dropped unexpectedly mid-burst during back-to-back transfer (RDATA 1-cycle latency bubble bug)");

    // No-X assertions
    property p_no_x(logic sig);
        @(posedge ACLK) disable iff (!ARESETn) !$isunknown(sig);
    endproperty
    a_no_x_awvalid:  assert property (p_no_x(AWVALID))  else $error("[SVA] AWVALID is X/Z");
    a_no_x_awready:  assert property (p_no_x(AWREADY))  else $error("[SVA] AWREADY is X/Z");
    a_no_x_wvalid:   assert property (p_no_x(WVALID))   else $error("[SVA] WVALID is X/Z");
    a_no_x_wready:   assert property (p_no_x(WREADY))   else $error("[SVA] WREADY is X/Z");
    a_no_x_bvalid:   assert property (p_no_x(BVALID))   else $error("[SVA] BVALID is X/Z");
    a_no_x_arvalid:  assert property (p_no_x(ARVALID))  else $error("[SVA] ARVALID is X/Z");
    a_no_x_arready:  assert property (p_no_x(ARREADY))  else $error("[SVA] ARREADY is X/Z");
    a_no_x_rvalid:   assert property (p_no_x(RVALID))   else $error("[SVA] RVALID is X/Z");
    a_no_x_rlast:    assert property (p_no_x(RLAST))    else $error("[SVA] RLAST is X/Z");

endmodule : axi4_checker
