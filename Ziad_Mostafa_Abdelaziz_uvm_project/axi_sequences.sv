//=============================================================================
// axi_sequences.sv — UVM Sequence Library (Coverage-Complete v2)
// Fixes: naming collision in send() task, adds injection scenarios for
//        WVALID_0 bubble, delayed BREADY_0, delayed RREADY_0.
//=============================================================================
`ifndef AXI_SEQUENCES_SV
`define AXI_SEQUENCES_SV

class axi_base_seq extends uvm_sequence #(axi_seq_item);
    `uvm_object_utils(axi_base_seq)
    function new(string name = "axi_base_seq"); super.new(name); endfunction
endclass

//-----------------------------------------------------------------------------
// 1. Single-Beat Write
//-----------------------------------------------------------------------------
class axi_single_write_seq extends axi_base_seq;
    `uvm_object_utils(axi_single_write_seq)
    function new(string name = "axi_single_write_seq"); super.new(name); endfunction
    virtual task body();
        req = axi_seq_item::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { op == OP_WRITE; len == 8'd0; size == 3'b010; })
            `uvm_fatal("SEQ", "Single write randomize failed")
        finish_item(req);
    endtask
endclass

//-----------------------------------------------------------------------------
// 2. Single-Beat Read
//-----------------------------------------------------------------------------
class axi_single_read_seq extends axi_base_seq;
    `uvm_object_utils(axi_single_read_seq)
    function new(string name = "axi_single_read_seq"); super.new(name); endfunction
    virtual task body();
        req = axi_seq_item::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { op == OP_READ; len == 8'd0; size == 3'b010; })
            `uvm_fatal("SEQ", "Single read randomize failed")
        finish_item(req);
    endtask
endclass

//-----------------------------------------------------------------------------
// 3. Directed Write-then-Read
//-----------------------------------------------------------------------------
class axi_write_read_seq extends axi_base_seq;
    `uvm_object_utils(axi_write_read_seq)
    rand bit [15:0] target_addr;
    rand bit [31:0] target_data;
    constraint c_target { target_addr[1:0] == 2'b00; target_addr < 16'h1000; }
    function new(string name = "axi_write_read_seq"); super.new(name); endfunction
    virtual task body();
        req = axi_seq_item::type_id::create("req_wr");
        start_item(req);
        if (!req.randomize() with { op == OP_WRITE; len == 8'd0; size == 3'b010;
                                    addr == target_addr; wdata[0] == target_data; })
            `uvm_fatal("SEQ", "Write-read write phase failed")
        finish_item(req);
        req = axi_seq_item::type_id::create("req_rd");
        start_item(req);
        if (!req.randomize() with { op == OP_READ; len == 8'd0; size == 3'b010;
                                    addr == target_addr; })
            `uvm_fatal("SEQ", "Write-read read phase failed")
        finish_item(req);
    endtask
endclass

//-----------------------------------------------------------------------------
// 4. Bulk Random Single-Beat
//-----------------------------------------------------------------------------
class axi_random_seq extends axi_base_seq;
    `uvm_object_utils(axi_random_seq)
    int num_txn = 100;
    function new(string name = "axi_random_seq"); super.new(name); endfunction
    virtual task body();
        for (int i = 0; i < num_txn; i++) begin
            req = axi_seq_item::type_id::create($sformatf("req_%0d", i));
            start_item(req);
            if (!req.randomize() with { len == 8'd0; })
                `uvm_fatal("SEQ", "Random seq randomize failed")
            finish_item(req);
        end
    endtask
endclass

//-----------------------------------------------------------------------------
// 5. Multi-Beat Burst (len 1-15)
//-----------------------------------------------------------------------------
class axi_burst_seq extends axi_base_seq;
    `uvm_object_utils(axi_burst_seq)
    int num_txn = 30;
    function new(string name = "axi_burst_seq"); super.new(name); endfunction
    virtual task body();
        for (int i = 0; i < num_txn; i++) begin
            req = axi_seq_item::type_id::create($sformatf("burst_req_%0d", i));
            start_item(req);
            if (!req.randomize() with { len inside {[1:15]}; })
                `uvm_fatal("SEQ", "Burst randomize failed")
            finish_item(req);
        end
    endtask
endclass

//-----------------------------------------------------------------------------
// 6. Coverage-Closure Sequence
//    Drives every missing toggle and condition FEC row with CORRECT parameter names
//    (t_op, t_addr, t_len, t_size) to avoid naming collision inside with{} blocks.
//-----------------------------------------------------------------------------
class axi_coverage_closure_seq extends axi_base_seq;
    `uvm_object_utils(axi_coverage_closure_seq)
    function new(string name = "axi_coverage_closure_seq"); super.new(name); endfunction

    // -----------------------------------------------------------------------
    // Helper: send a directed transaction.
    // CRITICAL: task params prefixed t_ to avoid naming collision with rand
    // fields inside randomize() with {} blocks (SV LRM constraint scope rule).
    // -----------------------------------------------------------------------
    task send(axi_op_e t_op, bit [15:0] t_addr, bit [7:0] t_len, bit [2:0] t_size,
              bit t_bready_dly = 0, bit t_rready_dly = 0, bit t_wval_bubble = 0);
        axi_seq_item item;
        item = axi_seq_item::type_id::create("dir_item");
        start_item(item);
        item.inject_bready_delay  = t_bready_dly;
        item.inject_rready_delay  = t_rready_dly;
        item.inject_wvalid_bubble = t_wval_bubble;
        // Use t_ prefixed names so rand fields (op/addr/len/size) are distinct from args
        if (!item.randomize() with {
            op   == t_op;
            addr == t_addr;
            len  == t_len;
            size == t_size;
        }) `uvm_fatal("SEQ", $sformatf("Directed randomize failed: op=%0d addr=%0h len=%0d size=%0d",
                                        t_op, t_addr, t_len, t_size))
        finish_item(item);
    endtask

    virtual task body();

        // === A. All SIZE variants: toggles AWSIZE/ARSIZE[2:0] and addr_incr bits ===
        // SIZE=000 byte     (addr_incr=1  → bit0)
        send(OP_WRITE, 16'h0010, 8'd0, 3'b000);
        send(OP_READ,  16'h0010, 8'd0, 3'b000);
        // SIZE=001 halfword (addr_incr=2  → bit1)
        send(OP_WRITE, 16'h0014, 8'd0, 3'b001);
        send(OP_READ,  16'h0014, 8'd0, 3'b001);
        // SIZE=010 word     (addr_incr=4  → bit2, already covered but included)
        send(OP_WRITE, 16'h0018, 8'd0, 3'b010);
        send(OP_READ,  16'h0018, 8'd0, 3'b010);
        // SIZE=011 8-byte   (addr_incr=8  → bit3)
        send(OP_WRITE, 16'h0020, 8'd1, 3'b011);
        send(OP_READ,  16'h0020, 8'd1, 3'b011);
        // SIZE=100 16-byte  (addr_incr=16 → bit4)
        send(OP_WRITE, 16'h0040, 8'd1, 3'b100);
        send(OP_READ,  16'h0040, 8'd1, 3'b100);
        // SIZE=101 32-byte  (addr_incr=32 → bit5)
        send(OP_WRITE, 16'h0080, 8'd1, 3'b101);
        send(OP_READ,  16'h0080, 8'd1, 3'b101);
        // SIZE=110 64-byte  (addr_incr=64 → bit6)
        send(OP_WRITE, 16'h0100, 8'd1, 3'b110);
        send(OP_READ,  16'h0100, 8'd1, 3'b110);
        // SIZE=111 128-byte (addr_incr=128→ bit7)
        send(OP_WRITE, 16'h0200, 8'd1, 3'b111);
        send(OP_READ,  16'h0200, 8'd1, 3'b111);

        // === B. Unaligned addresses: toggles ADDR[1:0] ===
        send(OP_WRITE, 16'h0001, 8'd0, 3'b000); // addr[0]=1
        send(OP_WRITE, 16'h0002, 8'd0, 3'b001); // addr[1]=1
        send(OP_WRITE, 16'h0003, 8'd0, 3'b000); // addr[1:0]=11
        send(OP_READ,  16'h0001, 8'd0, 3'b000);
        send(OP_READ,  16'h0002, 8'd0, 3'b001);
        send(OP_READ,  16'h0003, 8'd0, 3'b000);

        // === C. Large OOB addresses: toggles ADDR[13], ADDR[14], ADDR[15] ===
        send(OP_WRITE, 16'h2000, 8'd0, 3'b010); // bit13=1
        send(OP_READ,  16'h2000, 8'd0, 3'b010);
        send(OP_WRITE, 16'h4000, 8'd0, 3'b010); // bit14=1
        send(OP_READ,  16'h4000, 8'd0, 3'b010);
        send(OP_WRITE, 16'h8000, 8'd0, 3'b010); // bit15=1
        send(OP_READ,  16'h8000, 8'd0, 3'b010);
        send(OP_WRITE, 16'hFFFC, 8'd0, 3'b010); // all upper bits
        send(OP_READ,  16'hFFFC, 8'd0, 3'b010);

        // === D. Max burst LEN=255: toggles LEN[7:4] ===
        send(OP_WRITE, 16'h0000, 8'd255, 3'b010);
        send(OP_READ,  16'h0000, 8'd255, 3'b010);
        send(OP_WRITE, 16'h0400, 8'hF0, 3'b010); // LEN[7:4]=1111
        send(OP_READ,  16'h0400, 8'hF0, 3'b010);

        // === E. 4KB boundary crossing: covers lines 177/249 branch + statement ===
        send(OP_WRITE, 16'h0FF0, 8'd7,  3'b010); // crosses 0x1000
        send(OP_READ,  16'h0FF0, 8'd7,  3'b010);
        send(OP_WRITE, 16'h0FFC, 8'd1,  3'b010); // single-beat boundary
        send(OP_READ,  16'h0FFC, 8'd1,  3'b010);

        // === F. WVALID bubble: covers WVALID_0 FEC condition row in W_DATA ===
        // (multi-beat write with 1-cycle WVALID de-assertion after beat 0)
        send(OP_WRITE, 16'h0300, 8'd3, 3'b010, 0, 0, 1); // inject_wvalid_bubble=1

        // === G. Delayed BREADY: covers BREADY_0 FEC condition row in W_RESP ===
        // (also covers W_RESP→W_RESP FSM self-loop transition)
        send(OP_WRITE, 16'h0400, 8'd0, 3'b010, 1, 0, 0); // inject_bready_delay=1
        send(OP_WRITE, 16'h0500, 8'd3, 3'b010, 1, 0, 0);

        // === H. Delayed RREADY: covers RREADY_0 FEC condition row in R_DATA ===
        send(OP_READ,  16'h0300, 8'd0, 3'b010, 0, 1, 0); // inject_rready_delay=1
        send(OP_READ,  16'h0400, 8'd3, 3'b010, 0, 1, 0);

    endtask
endclass

`endif
