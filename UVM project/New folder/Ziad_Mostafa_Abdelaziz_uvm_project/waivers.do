#=============================================================================
# waivers.do — Minimal & Complete Coverage Exclusions (100.00% Total Coverage)
#=============================================================================

# Unreachable FSM Case Default Arms (Branch & Statement)
coverage exclude -scope /top/dut -linerange 178
coverage exclude -scope /top/dut -linerange 252

# Structurally Unreachable Condition Terms
coverage exclude -src axi4.v -feccondrow 130 3
coverage exclude -src axi4.v -feccondrow 145 3
coverage exclude -src axi4.v -feccondrow 152 4
coverage exclude -src axi4.v -feccondrow 169 3
coverage exclude -src axi4.v -feccondrow 208 3

# FSM Reset Path & Testbench Reset Toggle
coverage exclude -scope /top/dut -ftrans write_state W_DATA->W_IDLE
coverage exclude -togglenode ARESETn -scope /top/dut

# Structural RTL Design Constraints
coverage exclude -du axi4 -toggle {BRESP[0]}
coverage exclude -du axi4 -toggle {RRESP[0]}
coverage exclude -du axi4 -toggle {read_state[1]}
coverage exclude -du axi4_memory -toggle {j}

# Upper Unreachable Address Increment Bits (8..15)
coverage exclude -du axi4 -toggle {write_addr_incr[8]}
coverage exclude -du axi4 -toggle {write_addr_incr[9]}
coverage exclude -du axi4 -toggle {write_addr_incr[10]}
coverage exclude -du axi4 -toggle {write_addr_incr[11]}
coverage exclude -du axi4 -toggle {write_addr_incr[12]}
coverage exclude -du axi4 -toggle {write_addr_incr[13]}
coverage exclude -du axi4 -toggle {write_addr_incr[14]}
coverage exclude -du axi4 -toggle {write_addr_incr[15]}
coverage exclude -du axi4 -toggle {read_addr_incr[8]}
coverage exclude -du axi4 -toggle {read_addr_incr[9]}
coverage exclude -du axi4 -toggle {read_addr_incr[10]}
coverage exclude -du axi4 -toggle {read_addr_incr[11]}
coverage exclude -du axi4 -toggle {read_addr_incr[12]}
coverage exclude -du axi4 -toggle {read_addr_incr[13]}
coverage exclude -du axi4 -toggle {read_addr_incr[14]}
coverage exclude -du axi4 -toggle {read_addr_incr[15]}
