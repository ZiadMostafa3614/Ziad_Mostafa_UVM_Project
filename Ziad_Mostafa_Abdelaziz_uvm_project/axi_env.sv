//=============================================================================
// axi_env.sv — Top UVM Environment Class
//=============================================================================
`ifndef AXI_ENV_SV
`define AXI_ENV_SV

class axi_env extends uvm_env;

    `uvm_component_utils(axi_env)

    axi_active_agent  axi_agent;
    mem_passive_agent mem_agent;
    axi_scoreboard    sb;
    axi_coverage      cov;

    function new(string name = "axi_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_agent = axi_active_agent::type_id::create("axi_agent", this);
        mem_agent = mem_passive_agent::type_id::create("mem_agent", this);
        sb        = axi_scoreboard::type_id::create("sb", this);
        cov       = axi_coverage::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        axi_agent.mon.item_collected_port.connect(sb.item_collected_export);
        axi_agent.mon.item_collected_port.connect(cov.analysis_export);
    endfunction

endclass : axi_env

`endif
