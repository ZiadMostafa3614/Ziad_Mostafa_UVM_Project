//=============================================================================
// axi_driver.sv — Active UVM Bus Driver Class (Coverage-Complete)
// Supports: inject_wvalid_bubble, inject_bready_delay, inject_rready_delay
//=============================================================================
`ifndef AXI_DRIVER_SV
`define AXI_DRIVER_SV

class axi_driver extends uvm_driver #(axi_seq_item);

    `uvm_component_utils(axi_driver)

    virtual axi4_if.DRIVER vif;

    function new(string name = "axi_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual axi4_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRV", "Virtual interface 'vif' not found in uvm_config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        reset_signals();
        wait (vif.ARESETn === 1'b1);
        @(vif.drv_cb);
        forever begin
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    virtual task reset_signals();
        vif.drv_cb.AWVALID <= 0; vif.drv_cb.AWADDR <= '0; vif.drv_cb.AWLEN <= '0; vif.drv_cb.AWSIZE <= '0;
        vif.drv_cb.WVALID  <= 0; vif.drv_cb.WDATA  <= '0; vif.drv_cb.WLAST <= 0;
        vif.drv_cb.BREADY  <= 0;
        vif.drv_cb.ARVALID <= 0; vif.drv_cb.ARADDR <= '0; vif.drv_cb.ARLEN <= '0; vif.drv_cb.ARSIZE <= '0;
        vif.drv_cb.RREADY  <= 0;
    endtask

    virtual task drive_item(axi_seq_item item);
        if (item.op == OP_WRITE) drive_write(item);
        else                     drive_read(item);
    endtask

    virtual task drive_write(axi_seq_item item);
        // --- Address Phase ---
        vif.drv_cb.AWADDR  <= item.addr;
        vif.drv_cb.AWLEN   <= item.len;
        vif.drv_cb.AWSIZE  <= item.size;
        vif.drv_cb.AWVALID <= 1'b1;

        // Drive first data beat concurrently
        vif.drv_cb.WDATA  <= item.wdata[0];
        vif.drv_cb.WVALID <= 1'b1;
        vif.drv_cb.WLAST  <= (item.len == 0);

        // Wait for AWREADY
        do @(vif.drv_cb); while (!vif.drv_cb.AWREADY);
        vif.drv_cb.AWVALID <= 1'b0;

        // --- Data Phase: drive each beat ---
        for (int b = 0; b <= int'(item.len); b++) begin
            if (b > 0) begin
                // Mid-burst WVALID bubble: de-assert for 1 cycle to cover WVALID_0 FEC row
                if (item.inject_wvalid_bubble && b == 1) begin
                    vif.drv_cb.WVALID <= 1'b0;
                    @(vif.drv_cb);
                end
                vif.drv_cb.WDATA  <= item.wdata[b];
                vif.drv_cb.WVALID <= 1'b1;
                vif.drv_cb.WLAST  <= (b == int'(item.len));
            end
            do @(vif.drv_cb); while (!vif.drv_cb.WREADY);
        end
        vif.drv_cb.WVALID <= 1'b0;
        vif.drv_cb.WLAST  <= 1'b0;

        // --- Response Phase ---
        // inject_bready_delay: wait for BVALID first, THEN assert BREADY
        // This covers the BREADY_0 FEC row (BVALID=1, BREADY=0)
        if (item.inject_bready_delay) begin
            vif.drv_cb.BREADY <= 1'b0;
            do @(vif.drv_cb); while (!vif.drv_cb.BVALID); // wait with BREADY=0
            @(vif.drv_cb);                                  // 1 extra cycle BREADY=0, BVALID=1
            vif.drv_cb.BREADY <= 1'b1;
            do @(vif.drv_cb); while (!vif.drv_cb.BVALID);
        end else begin
            vif.drv_cb.BREADY <= 1'b1;
            do @(vif.drv_cb); while (!vif.drv_cb.BVALID);
        end
        item.resp = axi_resp_e'(vif.drv_cb.BRESP);
        @(vif.drv_cb);
        vif.drv_cb.BREADY <= 1'b0;
    endtask

    virtual task drive_read(axi_seq_item item);
        // --- Address Phase ---
        vif.drv_cb.ARADDR  <= item.addr;
        vif.drv_cb.ARLEN   <= item.len;
        vif.drv_cb.ARSIZE  <= item.size;
        vif.drv_cb.ARVALID <= 1'b1;
        do @(vif.drv_cb); while (!vif.drv_cb.ARREADY);
        vif.drv_cb.ARVALID <= 1'b0;

        // --- Data Phase ---
        // inject_rready_delay: wait for RVALID first, THEN assert RREADY
        // This covers the RREADY_0 FEC row (RVALID=1, RREADY=0)
        item.rdata = new[item.len + 1];
        for (int b = 0; b <= int'(item.len); b++) begin
            if (item.inject_rready_delay && b == 0) begin
                vif.drv_cb.RREADY <= 1'b0;
                do @(vif.drv_cb); while (!vif.drv_cb.RVALID); // RVALID=1, RREADY=0
                @(vif.drv_cb);                                  // 1 extra cycle
                vif.drv_cb.RREADY <= 1'b1;
            end else begin
                vif.drv_cb.RREADY <= 1'b1;
            end
            do @(vif.drv_cb); while (!vif.drv_cb.RVALID);
            item.rdata[b] = vif.drv_cb.RDATA;
            item.resp     = axi_resp_e'(vif.drv_cb.RRESP);
        end
        @(vif.drv_cb);
        vif.drv_cb.RREADY <= 1'b0;
    endtask

endclass : axi_driver

`endif
