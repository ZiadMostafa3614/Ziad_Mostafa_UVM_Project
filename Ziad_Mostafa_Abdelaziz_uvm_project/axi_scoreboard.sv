//=============================================================================
// axi_scoreboard.sv — UVM Scoreboard Class with Golden Memory Model
//=============================================================================
`ifndef AXI_SCOREBOARD_SV
`define AXI_SCOREBOARD_SV

class axi_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(axi_scoreboard)

    uvm_analysis_imp #(axi_seq_item, axi_scoreboard) item_collected_export;

    // Golden Reference Memory
    bit [31:0] golden_mem[1024];

    // Stats
    int unsigned num_writes_checked = 0;
    int unsigned num_reads_checked  = 0;
    int unsigned num_passed_beats   = 0;
    int unsigned num_failed_beats   = 0;

    function new(string name = "axi_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        item_collected_export = new("item_collected_export", this);
        foreach (golden_mem[i]) golden_mem[i] = 32'h0;
    endfunction

    virtual function void write(axi_seq_item t);
        bit [15:0] start_word_addr = t.addr >> 2;
        bit is_oob = (t.addr >= 16'h1000);

        if (t.op == OP_WRITE) begin
            num_writes_checked++;
            if (!is_oob && t.resp == RESP_OKAY) begin
                for (int b = 0; b <= int'(t.len); b++) begin
                    bit [15:0] waddr = start_word_addr + b;
                    if (waddr < 1024) begin
                        golden_mem[waddr] = t.wdata[b];
                        `uvm_info("SB_WR", $sformatf("Golden write: mem[0x%0h] = 0x%0h", waddr << 2, t.wdata[b]), UVM_HIGH)
                    end
                end
            end
        end else if (t.op == OP_READ) begin
            num_reads_checked++;
            if (!is_oob && t.resp == RESP_OKAY) begin
                for (int b = 0; b <= int'(t.len); b++) begin
                    bit [15:0] raddr = start_word_addr + b;
                    if (raddr < 1024) begin
                        bit [31:0] exp_data = golden_mem[raddr];
                        bit [31:0] act_data = t.rdata[b];
                        if (act_data === exp_data) begin
                            num_passed_beats++;
                            `uvm_info("SB_PASS", $sformatf("READ PASS: addr=0x%0h beat=%0d data=0x%0h", raddr << 2, b, act_data), UVM_HIGH)
                        end else begin
                            num_failed_beats++;
                            `uvm_error("SB_FAIL", $sformatf("READ MISMATCH: addr=0x%0h beat=%0d expected=0x%0h got=0x%0h", raddr << 2, b, exp_data, act_data))
                        end
                    end
                end
            end
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SB_SUMMARY", "========================================================", UVM_LOW)
        `uvm_info("SB_SUMMARY", $sformatf(" Total Writes Checked : %0d", num_writes_checked), UVM_LOW)
        `uvm_info("SB_SUMMARY", $sformatf(" Total Reads Checked  : %0d", num_reads_checked), UVM_LOW)
        `uvm_info("SB_SUMMARY", $sformatf(" Data Beats Passed    : %0d", num_passed_beats), UVM_LOW)
        `uvm_info("SB_SUMMARY", $sformatf(" Data Beats Failed    : %0d", num_failed_beats), UVM_LOW)
        `uvm_info("SB_SUMMARY", "========================================================", UVM_LOW)
    endfunction

endclass : axi_scoreboard

`endif
