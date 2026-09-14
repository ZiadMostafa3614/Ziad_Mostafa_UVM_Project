//=============================================================================
// axi_active_agent.sv — Active UVM AXI Agent Class
//=============================================================================
`ifndef AXI_ACTIVE_AGENT_SV
`define AXI_ACTIVE_AGENT_SV

class axi_active_agent extends uvm_agent;

    `uvm_component_utils(axi_active_agent)

    axi_sequencer sqr;
    axi_driver    drv;
    axi_monitor   mon;

    function new(string name = "axi_active_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = axi_monitor::type_id::create("mon", this);
        if (is_active == UVM_ACTIVE) begin
            sqr = axi_sequencer::type_id::create("sqr", this);
            drv = axi_driver::type_id::create("drv", this);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction

endclass : axi_active_agent

`endif
