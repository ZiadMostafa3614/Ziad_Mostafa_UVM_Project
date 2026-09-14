//=============================================================================
// axi_driver_delay.sv — Factory Type Override Extended Driver Class
// Inherits from axi_driver and inserts random idle cycles between transactions
//=============================================================================
`ifndef AXI_DRIVER_DELAY_SV
`define AXI_DRIVER_DELAY_SV

class axi_driver_delay extends axi_driver;

    `uvm_component_utils(axi_driver_delay)

    function new(string name = "axi_driver_delay", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Overridden drive_item method inserting random idle cycles between transactions
    virtual task drive_item(axi_seq_item item);
        int delay_cycles = $urandom_range(1, 4);
        `uvm_info("DRV_DELAY", $sformatf("Inserting %0d idle cycles before transaction", delay_cycles), UVM_HIGH)
        repeat (delay_cycles) @(vif.drv_cb);
        super.drive_item(item);
    endtask

endclass : axi_driver_delay

`endif
