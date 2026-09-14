vlib work

# Compile RTL & UVM Testbench
vlog +cover=bcesft axi_memory.v axi4.v
vlog -sv +cover=bcesft +incdir+. \
     +incdir+C:/questasim64_2021.1/verilog_src/uvm-1.1d/src \
     C:/questasim64_2021.1/verilog_src/uvm-1.1d/src/uvm_pkg.sv \
     axi4_if.sv axi4_assertions.sv axi_uvm_pkg.sv top.sv

# Optimize
vopt top -o top_opt +acc +cover=bcesft -suppress 3009 -work work

# Run Test 1: Random Test
vsim top_opt -coverage -assertdebug +UVM_TESTNAME=axi_random_test \
     -suppress 3009 -sv_lib C:/questasim64_2021.1/uvm-1.1d/win64/uvm_dpi -onfinish stop
run -all
coverage save cov_random.ucdb

# Run Test 2: Delay Test (Factory Override)
vsim top_opt -coverage -assertdebug +UVM_TESTNAME=axi_delay_test \
     -suppress 3009 -sv_lib C:/questasim64_2021.1/uvm-1.1d/win64/uvm_dpi -onfinish stop
run -all
coverage save cov_delay.ucdb

# Run Test 3: Burst Boundary Test
vsim top_opt -coverage -assertdebug +UVM_TESTNAME=axi_burst_test \
     -suppress 3009 -sv_lib C:/questasim64_2021.1/uvm-1.1d/win64/uvm_dpi -onfinish stop
run -all
coverage save cov_burst.ucdb

# Merge Databases & Apply Waivers
vcover merge cov_merged_raw.ucdb cov_random.ucdb cov_delay.ucdb cov_burst.ucdb
vsim -viewcov cov_merged_raw.ucdb
do waivers.do
coverage save cov_merged.ucdb
coverage report -codeAll -cvg -verbose -output coverage_report.txt
coverage report -codeAll -summary -instance=/top/dut
