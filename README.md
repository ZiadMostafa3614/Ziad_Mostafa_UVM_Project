# AXI4 Memory-Mapped Slave — UVM Verification Environment

[![Coverage](https://img.shields.io/badge/Coverage-100.00%25-brightgreen.svg)]()
[![UVM](https://img.shields.io/badge/UVM-1.1d-blue.svg)]()
[![Simulator](https://img.shields.io/badge/Simulator-QuestaSim%202021.1-purple.svg)]()
[![Status](https://img.shields.io/badge/Status-Verified%20%26%20Closed-success.svg)]()

> **Author**: Ziad Mostafa Abdelaziz  
> **Diploma**: Digital IC Verification Diploma (Top Achiever)  
> **Mentor**: Eng. Hassan Khaled (Design & Verification Engineer)  

---

## 📌 1. Executive Summary

This repository contains a complete, production-grade **UVM (Universal Verification Methodology) Verification Environment** for an **AXI4 Memory-Mapped Slave Controller with dual-port SRAM storage**. 

The verification setup adheres strictly to **Coverage-Driven Verification (CDV)** methodologies, achieving **100.00% Total Code Coverage** (Statement, Branch, FEC Condition, Expression, FSM, Toggle) and **100.00% Functional Coverage** across all protocol modes.

---

## 🏗️ 2. Verification Architecture

The environment utilizes a **dual-agent architecture** separating channel protocol driving from internal memory storage monitoring.

```text
                               +-------------------------------------------------------+
                               |                    uvm_test_top                       |
                               |          (axi_random_test / axi_delay_test)          |
                               +---------------------------+---------------------------+
                                                           |
                               +---------------------------v---------------------------+
                               |                        axi_env                        |
                               +------------+------------------------------+-----------+
                                            |                              |
            +-------------------------------+---------------+              |
            |                                               |              |
+-----------v-----------+                       +-----------v-----------+  |  +--------------------+
|   axi_active_agent    |                       |   mem_passive_agent   |  |  |   axi_scoreboard   |
+-----------------------+                       +-----------------------+  |  | (Golden Memory Ref)|
| - axi_sequencer       |                       | - mem_monitor         |  |  +---------^----------+
| - axi_driver /        |                       | - mem_coverage        |  |            |
|   axi_driver_delay    |                       | - mem_checker         |  |            |
| - axi_monitor         |                       +-----------+-----------+  |            |
+-----------+-----------+                                   |              |            |
            |                                               |              |            |
            | (vif)                                         |              |            |
+-----------v-----------------------------------------------+--------------v------------+-----+
|                                          AXI4 Interface (axi4_if)                           |
+-----------------------------------------------------------+---------------------------------+
                                                            |
                                                +-----------v-----------+
                                                |       axi4 (DUT)      |
                                                |  +-----------------+  |
                                                |  |   axi_memory    |  |
                                                |  +-----------------+  |
                                                +-----------------------+
```

---

## 🧩 3. Key Components & Implementation Details

### 🔹 Active AXI Agent (`axi_active_agent`)
- **`axi_seq_item`**: Sequence item defining AXI transactions (`AWADDR`, `AWLEN`, `AWSIZE`, `WDATA`, `ARADDR`, `ARLEN`, `ARSIZE`, `RDATA`, `BRESP`, `RRESP`).
- **`axi_driver`**: Drives AW, W, B, AR, and R handshake channels with configurable bubble cycle injection (`inject_wvalid_bubble`, `inject_bready_delay`, `inject_rready_delay`).
- **`axi_driver_delay` (UVM Factory Override)**: Inherits from `axi_driver` and injects random inter-beat cycle delays to stress pipeline handshakes.
- **`axi_monitor`**: Monitors bus handshakes and broadcasts transactions to the scoreboard and functional coverage subscriber via `uvm_analysis_port`.

### 🔹 Passive Memory Agent (`mem_passive_agent`)
- **`mem_monitor`**: Monitors internal dual-port RAM operations (`mem_write_en`, `mem_read_en`, `mem_write_addr`, `mem_read_addr`).
- **`mem_coverage`**: Samples RAM utilization metrics (`cg_sram_behavior`) ensuring all memory depth regions are exercised.
- **`mem_checker`**: Enforces RAM boundary safety rules.

### 🔹 Scoreboard (`axi_scoreboard`)
- Maintains an independent **Golden Associative Memory Model** (`bit [31:0] mem_model [*]`).
- Performs automatic read payload and response code verification across **5,488 transaction beats** with zero mismatches.

### 🔹 SystemVerilog Assertions (`axi4_assertions`)
Bound directly to `axi4` DUT containing 23 concurrent assertions:
- Handshake stability (`AWVALID`, `WVALID`, `ARVALID`, `RVALID`, `BVALID` stability until `READY`).
- Burst compliance (`WLAST` asserted on final write beat, `RLAST` asserted on final read beat).
- Response code validation (`BRESP` and `RRESP` strictly `OKAY=2'b00` or `SLVERR=2'b10`).
- 4KB boundary crossing detection.

---

## 🧪 4. UVM Factory Type Override Demonstration

To verify dynamic object replacement without altering environment topology, `axi_delay_test` overrides `axi_driver` with `axi_driver_delay` in `build_phase()`:

```systemverilog
axi_driver::type_id::set_type_override(axi_driver_delay::get_type());
```

### Hierarchy Topologies:
- **`axi_random_test`**: `uvm_test_top.env.axi_agent.drv` $\rightarrow$ **`axi_driver`**
- **`axi_delay_test`**: `uvm_test_top.env.axi_agent.drv` $\rightarrow$ **`axi_driver_delay`**

---

## 📊 5. Verification & Coverage Results

All simulations were executed in **QuestaSim 2021.1** across 3 test suites:
1. `axi_random_test` (Constrained random transactions)
2. `axi_delay_test` (Factory-overridden delay driver)
3. `axi_burst_test` (Burst boundary and maximum length stress)

### Code Coverage Results (Filtered View):

| Coverage Category | Total Bins | Covered Bins | Coverage % |
|:---|:---:|:---:|:---:|
| **Statement Coverage** | 86 | 86 | **100.00%** |
| **Branch Coverage** | 31 | 31 | **100.00%** |
| **FEC Condition Coverage** | 19 | 19 | **100.00%** |
| **Expression Coverage** | 6 | 6 | **100.00%** |
| **FSM State Coverage** | 5 | 5 | **100.00%** |
| **FSM Transition Coverage** | 6 | 6 | **100.00%** |
| **Toggle Coverage** | 690 | 690 | **100.00%** |
| **TOTAL CODE COVERAGE** | — | — | **100.00%** |

### Functional & Assertion Metrics:
- **Functional Coverage (`cg_axi4`)**: **100.00%**
- **SVA Assertions Pass Rate**: **23 / 23 Assertions Pass (0 Failures)**
- **UVM Simulation Errors**: **0 Errors, 0 Fatal Errors, 0 Warnings**

---

## ⚙️ 6. How to Run Simulation

The environment is fully automated using standard QuestaSim scripts.

### Run Complete Flow (CLI / Batch Mode):
```bash
vsim -c -do run.do
```

### Run from QuestaSim GUI:
```tcl
do run.do
```

`run.do` automatically compiles all RTL/UVM sources, runs all 3 tests, merges UCDB databases into `cov_merged.ucdb`, applies `waivers.do`, prints the 100% coverage report, and keeps QuestaSim open for interactive debugging.

---

## 📁 7. Repository File Structure

```text
.
├── axi4.v                  # AXI4 Slave Controller RTL
├── axi_memory.v            # Internal Dual-Port SRAM RTL
├── axi4_if.sv              # AXI4 Virtual Interface
├── axi4_assertions.sv      # Concurrent SystemVerilog Assertions (SVA)
├── axi_uvm_pkg.sv          # UVM Package File
├── axi_seq_item.sv         # Sequence Item Definition
├── axi_sequencer.sv        # UVM Sequencer
├── axi_sequences.sv        # UVM Sequence Library
├── axi_driver.sv           # Standard UVM Bus Driver
├── axi_driver_delay.sv     # Factory-Overridden Delay Driver
├── axi_monitor.sv          # Active AXI Bus Monitor
├── axi_active_agent.sv     # Active AXI Agent
├── axi_scoreboard.sv       # Golden Reference Memory Scoreboard
├── axi_coverage.sv         # Functional Coverage Subscriber
├── mem_monitor.sv          # Passive SRAM Monitor
├── mem_coverage.sv         # SRAM Depth Coverage
├── mem_checker.sv          # Memory Bounds Safety Checker
├── mem_passive_agent.sv    # Passive Memory Agent
├── axi_env.sv              # UVM Environment Container
├── axi_tests.sv            # UVM Test Library (Random, Delay, Burst)
├── top.sv                  # Top-Level Testbench Module
├── waivers.do              # Structural Coverage Exclusion Script
├── run.do                  # Complete QuestaSim Automation Script
└── README.md               # Documentation
```

---

## 📜 8. License & Acknowledgments

Developed as part of the **Digital IC Verification Diploma** under the mentorship of **Eng. Hassan Khaled**.
