//=============================================================================
// axi_monitor.sv — Active AXI Channel Monitor Class
//=============================================================================
`ifndef AXI_MONITOR_SV
`define AXI_MONITOR_SV

class axi_monitor extends uvm_monitor;

    `uvm_component_utils(axi_monitor)

    virtual axi4_if.MONITOR vif;
    uvm_analysis_port #(axi_seq_item) item_collected_port;

    function new(string name = "axi_monitor", uvm_component parent = null);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual axi4_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("MON", "Virtual interface 'vif' not found in uvm_config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        wait (vif.ARESETn === 1'b1);
        @(vif.mon_cb);
        fork
            monitor_writes();
            monitor_reads();
        join_none
    endtask

    virtual task monitor_writes();
        axi_seq_item item;
        forever begin
            @(vif.mon_cb);
            if (vif.mon_cb.AWVALID && vif.mon_cb.AWREADY) begin
                item = axi_seq_item::type_id::create("item_wr");
                item.op   = OP_WRITE;
                item.addr = vif.mon_cb.AWADDR;
                item.len  = vif.mon_cb.AWLEN;
                item.size = vif.mon_cb.AWSIZE;

                item.wdata = new[item.len + 1];
                for (int b = 0; b <= int'(item.len); b++) begin
                    do @(vif.mon_cb); while (!(vif.mon_cb.WVALID && vif.mon_cb.WREADY));
                    item.wdata[b] = vif.mon_cb.WDATA;
                end

                do @(vif.mon_cb); while (!(vif.mon_cb.BVALID && vif.mon_cb.BREADY));
                item.resp = axi_resp_e'(vif.mon_cb.BRESP);

                `uvm_info("MON_WR", $sformatf("Observed WRITE: addr=0x%0h len=%0d resp=%s", item.addr, item.len, item.resp.name()), UVM_MEDIUM)
                item_collected_port.write(item);
            end
        end
    endtask

    virtual task monitor_reads();
        axi_seq_item item;
        forever begin
            @(vif.mon_cb);
            if (vif.mon_cb.ARVALID && vif.mon_cb.ARREADY) begin
                item = axi_seq_item::type_id::create("item_rd");
                item.op   = OP_READ;
                item.addr = vif.mon_cb.ARADDR;
                item.len  = vif.mon_cb.ARLEN;
                item.size = vif.mon_cb.ARSIZE;

                item.rdata = new[item.len + 1];
                for (int b = 0; b <= int'(item.len); b++) begin
                    do @(vif.mon_cb); while (!(vif.mon_cb.RVALID && vif.mon_cb.RREADY));
                    item.rdata[b] = vif.mon_cb.RDATA;
                    item.resp     = axi_resp_e'(vif.mon_cb.RRESP);
                end

                `uvm_info("MON_RD", $sformatf("Observed READ: addr=0x%0h len=%0d resp=%s", item.addr, item.len, item.resp.name()), UVM_MEDIUM)
                item_collected_port.write(item);
            end
        end
    endtask

endclass : axi_monitor

`endif
