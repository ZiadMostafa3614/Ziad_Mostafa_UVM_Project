//=============================================================================
// mem_passive_agent.sv — Passive Memory Agent Class
//=============================================================================
`ifndef MEM_PASSIVE_AGENT_SV
`define MEM_PASSIVE_AGENT_SV

class mem_passive_agent extends uvm_agent;

    `uvm_component_utils(mem_passive_agent)

    mem_monitor  mon;
    mem_coverage cov;
    mem_checker  chk;

    function new(string name = "mem_passive_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Force passive mode for memory agent
        is_active = UVM_PASSIVE;

        mon = mem_monitor::type_id::create("mon", this);
        cov = mem_coverage::type_id::create("cov", this);
        chk = mem_checker::type_id::create("chk", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mon.mem_ap.connect(cov.analysis_export);
        mon.mem_ap.connect(chk.analysis_export);
    endfunction

endclass : mem_passive_agent

`endif
