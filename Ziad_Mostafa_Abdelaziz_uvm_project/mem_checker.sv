//=============================================================================
// mem_checker.sv — Custom Memory Behavior Checker Component
//=============================================================================
`ifndef MEM_CHECKER_SV
`define MEM_CHECKER_SV

class mem_checker extends uvm_subscriber #(mem_access_item);

    `uvm_component_utils(mem_checker)

    int unsigned total_mem_accesses = 0;
    int unsigned out_of_bounds_attempts = 0;

    function new(string name = "mem_checker", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void write(mem_access_item t);
        total_mem_accesses++;
        if (t.write_en && (t.write_addr >= 1024)) begin
            out_of_bounds_attempts++;
            `uvm_error("MEM_CHK", $sformatf("Memory Checker: Write address 0x%0h out of bounds [0..1023]", t.write_addr))
        end
        if (t.read_en && (t.read_addr >= 1024)) begin
            out_of_bounds_attempts++;
            `uvm_error("MEM_CHK", $sformatf("Memory Checker: Read address 0x%0h out of bounds [0..1023]", t.read_addr))
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("MEM_CHK_SUM", $sformatf("Passive Memory Checker verified %0d access cycles (%0d out-of-bounds violations)", total_mem_accesses, out_of_bounds_attempts), UVM_LOW)
    endfunction

endclass : mem_checker

`endif
