//=============================================================================
// axi_tests.sv — UVM Test Suite Class Library
//=============================================================================
`ifndef AXI_TESTS_SV
`define AXI_TESTS_SV

// Base Test
class axi_base_test extends uvm_test;
    `uvm_component_utils(axi_base_test)

    axi_env env;

    function new(string name = "axi_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("TEST_TOPOLOGY", "Displaying UVM Test Environment Topology:", UVM_LOW)
        uvm_top.print_topology();
    endfunction
endclass

// Constrained-Random Single-Beat Test (Main Core Scope)
class axi_random_test extends axi_base_test;
    `uvm_component_utils(axi_random_test)

    function new(string name = "axi_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_random_seq           seq;
        axi_coverage_closure_seq cov_seq;
        phase.raise_objection(this, "Starting axi_random_test");
        `uvm_info("TEST", "Executing Constrained-Random Single-Beat AXI Test", UVM_LOW)
        // First run coverage closure directed sequences
        cov_seq = axi_coverage_closure_seq::type_id::create("cov_seq");
        cov_seq.start(env.axi_agent.sqr);
        // Then bulk random
        seq = axi_random_seq::type_id::create("seq");
        seq.num_txn = 150;
        seq.start(env.axi_agent.sqr);
        phase.drop_objection(this, "Completed axi_random_test");
    endtask
endclass

// Factory Type Override Test Requirement
// Applies set_type_override_by_type before super.build_phase()
// Prints uvm_top.print_topology() before and after override
class axi_delay_test extends uvm_test;
    `uvm_component_utils(axi_delay_test)

    axi_env env;

    function new(string name = "axi_delay_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        `uvm_info("FACTORY_OVERRIDE", "=== UVM TOPOLOGY BEFORE FACTORY OVERRIDE ===", UVM_LOW)
        uvm_top.print_topology();

        // UVM Factory Type Override: Override axi_driver with axi_driver_delay
        axi_driver::type_id::set_type_override(axi_driver_delay::get_type());
        `uvm_info("FACTORY_OVERRIDE", "Applied Factory Override: axi_driver -> axi_driver_delay", UVM_LOW)

        super.build_phase(phase);
        env = axi_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("FACTORY_OVERRIDE", "=== UVM TOPOLOGY AFTER FACTORY OVERRIDE ===", UVM_LOW)
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_random_seq seq;
        phase.raise_objection(this, "Starting axi_delay_test");
        `uvm_info("TEST", "Executing Factory Override Delay Driver AXI Test", UVM_LOW)
        seq = axi_random_seq::type_id::create("seq");
        seq.num_txn = 50;
        seq.start(env.axi_agent.sqr);
        phase.drop_objection(this, "Completed axi_delay_test");
    endtask
endclass

// Optional Extra Requirement: Burst Verification Test
class axi_burst_test extends axi_base_test;
    `uvm_component_utils(axi_burst_test)

    function new(string name = "axi_burst_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_burst_seq seq;
        phase.raise_objection(this, "Starting axi_burst_test");
        `uvm_info("TEST", "Executing Multi-Beat Burst AXI Test (Optional Extra Requirement)", UVM_LOW)
        seq = axi_burst_seq::type_id::create("seq");
        seq.num_txn = 30;
        seq.start(env.axi_agent.sqr);
        phase.drop_objection(this, "Completed axi_burst_test");
    endtask
endclass

`endif
