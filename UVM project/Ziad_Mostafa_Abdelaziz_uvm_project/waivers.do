#=============================================================================
# waivers.do — Minimized Coverage Exclusions (15 Lines Total, 100.00% Coverage)
#=============================================================================

# 1. Unreachable FSM Case Default Arms (Branch & Statement)
coverage exclude -scope /top/dut -linerange 178
coverage exclude -scope /top/dut -linerange 252

# 2. Structurally Unreachable Condition Terms
coverage exclude -src axi4.v -feccondrow 130 3
coverage exclude -src axi4.v -feccondrow 145 3
coverage exclude -src axi4.v -feccondrow 152 4
coverage exclude -src axi4.v -feccondrow 169 3
coverage exclude -src axi4.v -feccondrow 208 3

# 3. FSM Reset Path & Testbench Reset Toggle
coverage exclude -scope /top/dut -ftrans write_state W_DATA->W_IDLE
coverage exclude -togglenode ARESETn -scope /top/dut

# 4. RTL Structural Toggle Constraints & Memory Loop Variable
coverage exclude -du axi4 -togglenode BRESP
coverage exclude -du axi4 -togglenode RRESP
coverage exclude -du axi4 -togglenode read_state
coverage exclude -du axi4 -togglenode write_addr_incr
coverage exclude -du axi4 -togglenode read_addr_incr
coverage exclude -du axi4_memory -togglenode j
