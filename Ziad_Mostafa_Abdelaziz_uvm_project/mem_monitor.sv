//=============================================================================
// mem_monitor.sv — Passive Memory Monitor Listening Directly to SRAM Interface
//=============================================================================
`ifndef MEM_MONITOR_SV
`define MEM_MONITOR_SV

class mem_access_item extends uvm_object;
    bit        write_en;
    bit        read_en;
    bit [9:0]  write_addr;
    bit [9:0]  read_addr;
    bit [31:0] write_data;
    bit [31:0] read_data;

    `uvm_object_utils_begin(mem_access_item)
        `uvm_field_int(write_en, UVM_ALL_ON)
        `uvm_field_int(read_en, UVM_ALL_ON)
        `uvm_field_int(write_addr, UVM_ALL_ON)
        `uvm_field_int(read_addr, UVM_ALL_ON)
        `uvm_field_int(write_data, UVM_ALL_ON)
        `uvm_field_int(read_data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "mem_access_item");
        super.new(name);
    endfunction
endclass

class mem_monitor extends uvm_monitor;

    `uvm_component_utils(mem_monitor)

    virtual axi4_if.MONITOR vif;
    uvm_analysis_port #(mem_access_item) mem_ap;

    function new(string name = "mem_monitor", uvm_component parent = null);
        super.new(name, parent);
        mem_ap = new("mem_ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual axi4_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("MEM_MON", "Virtual interface 'vif' not found in uvm_config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        mem_access_item item;
        wait (vif.ARESETn === 1'b1);
        forever begin
            @(vif.mon_cb);
            if ((vif.mon_cb.WVALID && vif.mon_cb.WREADY) || (vif.mon_cb.RVALID && vif.mon_cb.RREADY)) begin
                item = mem_access_item::type_id::create("mem_item");
                item.write_en   = vif.mon_cb.WVALID && vif.mon_cb.WREADY;
                item.read_en    = vif.mon_cb.RVALID && vif.mon_cb.RREADY;
                item.write_addr = vif.mon_cb.AWADDR[11:2];
                item.read_addr  = vif.mon_cb.ARADDR[11:2];
                item.write_data = vif.mon_cb.WDATA;
                item.read_data  = vif.mon_cb.RDATA;

                `uvm_info("MEM_MON", $sformatf("Observed Memory Access: WR=%0b (addr=0x%0h) RD=%0b (addr=0x%0h)", item.write_en, item.write_addr, item.read_en, item.read_addr), UVM_HIGH)
                mem_ap.write(item);
            end
        end
    endtask

endclass : mem_monitor

`endif
