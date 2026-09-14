# AXI4-Compliant Memory-Mapped Slave — UVM Verification

## 1. Project Overview

The assignment is to build a **full UVM verification environment** for an **AXI4-compliant memory-mapped design**.

The design may be reused from the previous SystemVerilog project after fixing any bugs found there.

The core functional scope is intentionally simplified to:

- Basic **READ** operations
- Basic **WRITE** operations
- **No Burst feature** for the required core implementation

Burst verification is explicitly optional.

The project is intended to exercise the UVM components, objects, phasing, reporting, agents, checkers, coverage, assertions, configuration, and factory concepts learned during the UVM phase. fileciteturn6file0

---

# 2. Main Objectives

The verification environment must demonstrate:

1. Full UVM structure.
2. Basic AXI READ verification.
3. Basic AXI WRITE verification.
4. 100% pass rate.
5. 100% functional coverage.
6. 100% code coverage, with acceptable justification if any coverage is missed.
7. Assertions integrated with the UVM environment.
8. Appropriate UVM phasing.
9. UVM reporting.
10. Both active and passive agent types.
11. Custom checking and coverage on both AXI and memory sides.
12. Factory type override.
13. Automated execution through `run.do`.
14. Proper documentation of the verification environment.

---

# 3. Functional Scope

## Required

```text
AXI Memory-Mapped Slave
        |
        +-- READ
        |
        +-- WRITE
```

The assignment specifically asks to test basic READ and WRITE operations **without the Burst feature**.

## Optional

```text
AXI Burst Verification
```

Burst support can be implemented as an enhancement but is not part of the core required functionality.

---

# 4. Design Under Test

The DUT is an:

```text
AXI4-Compliant Memory-Mapped Design
```

The assignment allows the student to use the design from the previous SystemVerilog project after fixing previously detected bugs.

Conceptually:

```text
                 AXI Transactions
                        |
                        v
              +-------------------+
              | AXI Memory-Mapped |
              |      Slave        |
              +-------------------+
                        |
                        v
                     Memory
```

The assignment PDF does not include the actual DUT RTL or detailed AXI signal specification. Those details must come from the referenced AXI specifications and previous design.

---

# 5. Coverage and Pass Requirements

The assignment requires:

```text
100% Pass Rate
100% Functional Coverage
100% Code Coverage
```

If complete coverage cannot be achieved, acceptable justification must be provided for the missing coverage.

Therefore, the final verification report should not merely show percentages; it should explain any intentionally uncovered functionality.

---

# 6. Assertions

The project must include assertions.

The requirement is:

> Practice Assertions with the built UVM Environment.

Assertions should therefore be integrated into the verification environment and used to verify appropriate protocol/design properties.

The final report must also include:

```text
Assertions Coverage Report
```

The PDF does not define the exact assertion properties, so those properties must be derived from the AXI protocol and actual DUT behavior.

---

# 7. Required UVM Architecture

The assignment explicitly requires both:

```text
ACTIVE Agent
PASSIVE Agent
```

There are two main verification sides:

### AXI Wrapper Agent

```text
ACTIVE
```

### Memory Agent

```text
PASSIVE
```

The AXI wrapper agent carries its own:

- Checker
- Covergroups

The passive memory agent carries its own:

- Custom checker
- Custom covergroup

---

# 8. Active AXI Wrapper Agent

The AXI wrapper agent is the active verification component.

Conceptually:

```text
AXI Wrapper Agent
│
├── Sequencer
├── Driver
├── Monitor
├── Checker
└── Covergroups
```

The active agent is responsible for generating AXI transactions toward the DUT.

Typical flow:

```text
Sequence
   ↓
Sequencer
   ↓
Driver
   ↓
AXI Interface
   ↓
DUT
```

The exact transaction fields and signal-level timing must be taken from the AXI specification/DUT rather than invented from this assignment PDF.

---

# 9. AXI Agent Checker

The active AXI wrapper agent must have its own checker.

```text
AXI Agent
    |
    +-- Checker
```

The purpose is to verify AXI-side behavior.

The assignment does not specify the exact checking algorithm, so the checker must be designed according to the actual AXI interface and expected behavior.

---

# 10. AXI Agent Covergroups

The active AXI wrapper agent must also contain its own covergroups.

```text
AXI Agent
    |
    +-- Covergroups
```

These covergroups should measure the functional scenarios relevant to the AXI interface and the required READ/WRITE operations.

The assignment does not prescribe exact coverpoints or bins.

---

# 11. Passive Memory Agent

A separate passive agent must be customized for the memory itself.

Conceptually:

```text
Memory Passive Agent
│
├── Monitor
├── Custom Checker
└── Custom Covergroup
```

The passive agent observes memory behavior rather than actively driving the memory.

This allows the verification environment to independently check whether AXI transactions produce the expected memory behavior.

---

# 12. Active vs. Passive Agent

## Active AXI Agent

The active agent generates stimulus:

```text
Sequence
   ↓
Sequencer
   ↓
Driver
   ↓
DUT
```

## Passive Memory Agent

The passive agent observes behavior:

```text
Memory Activity
      ↓
Memory Monitor
      ↓
Custom Checker
      ↓
Coverage
```

The central distinction is:

```text
ACTIVE  → drives + monitors
PASSIVE → monitors only
```

The actual implementation must follow the DUT architecture.

---

# 13. Conceptual UVM Structure

A high-level representation of the required environment is:

```text
                         UVM TEST
                            |
                            v
                      +-----------+
                      | UVM ENV   |
                      +-----------+
                       /         \
                      /           \
                     v             v
          +----------------+   +----------------+
          | AXI WRAPPER    |   | MEMORY AGENT   |
          | ACTIVE         |   | PASSIVE        |
          +----------------+   +----------------+
             |  |  |  |  |        |
             |  |  |  |  |        +-- Monitor
             |  |  |  |  |        +-- Checker
             |  |  |  |  |        +-- Covergroup
             |  |  |  |  |
             |  |  |  |  +-- Covergroups
             |  |  |  +----- Checker
             |  |  +-------- Monitor
             |  +----------- Driver
             +-------------- Sequencer
                    |
                    v
              AXI DUT / Memory
```

The final project must draw the actual UVM structure implemented.

---

# 14. UVM Components and Objects

The assignment requires implementation of the full UVM structure and all components/objects learned during the UVM phase.

A practical hierarchy will therefore contain concepts such as:

```text
UVM Test
    |
    v
UVM Environment
    |
    +-- AXI Active Agent
    |     ├── Sequencer
    |     ├── Driver
    |     ├── Monitor
    |     ├── Checker
    |     └── Coverage
    |
    +-- Memory Passive Agent
          ├── Monitor
          ├── Checker
          └── Coverage
```

Additional components may be included according to the course methodology.

---

# 15. Required UVM Phasing

The assignment explicitly requires:

> Use the appropriate UVM Phasing and reporting with your environment.

The implementation should therefore use the appropriate UVM phases for:

- Construction
- Configuration
- Connections
- Simulation
- Checking
- Final reporting

Typical UVM phases include:

```text
build_phase
connect_phase
end_of_elaboration_phase
start_of_simulation_phase
run_phase
extract_phase
check_phase
report_phase
```

The exact contents of each phase are implementation-dependent.

---

# 16. UVM Reporting

UVM reporting must be practiced throughout the environment.

The final PDF must include log snippets showing the printed values using UVM reporting.

Typical reporting mechanisms include:

```systemverilog
`uvm_info
`uvm_warning
`uvm_error
`uvm_fatal
```

The exact messages and severity usage are not prescribed by the source.

---

# 17. Functional Verification

The minimum required functional scenarios are:

## WRITE

```text
AXI WRITE
   ↓
Memory-Mapped Slave
   ↓
Memory Updated
```

## READ

```text
AXI READ
   ↓
Memory-Mapped Slave
   ↓
Expected Memory Data Returned
```

The testbench should clearly demonstrate these scenarios in simulation.

---

# 18. Functional Coverage Strategy

The assignment requires 100% functional coverage.

A suitable coverage model should represent the behaviors actually required by the design.

At minimum, coverage should distinguish:

```text
READ
WRITE
```

Additional coverpoints should be based on:

- AXI transaction properties
- Memory accesses
- Valid/ready behavior
- Addresses
- Data
- Response behavior
- Error/normal responses

However, the exact AXI signals, widths, and legal values are not included in the assignment PDF, so exact bins cannot be derived from this source alone.

---

# 19. Code Coverage

The assignment requires 100% code coverage.

The final PDF must include a code coverage report/snippet.

The source explicitly mentions categories such as:

```text
Line
Toggle
Branch
Condition
...
```

Therefore, the report should show the available code-coverage metrics produced by the chosen simulation/coverage tool.

---

# 20. Assertion Coverage

Assertions must be exercised and their coverage reported.

The final PDF must contain:

```text
Assertion Coverage Report
```

This should demonstrate that the implemented properties were actually evaluated during simulation.

---

# 21. Factory Type Override

The assignment has an additional mandatory requirement involving the UVM Factory.

A derived driver must be created:

```text
axi_driver_delay
```

This class must inherit from the existing driver.

Conceptually:

```text
axi_driver
     ^
     |
     +---- axi_driver_delay
```

---

# 22. `axi_driver_delay`

The new driver must modify the normal driver behavior.

Instead of driving transfers back-to-back:

```text
Transfer
Transfer
Transfer
Transfer
```

it must insert **random idle cycles** between transfers:

```text
Transfer
Idle
Transfer
Idle
Idle
Transfer
Idle
Transfer
```

The idle-cycle count should be randomized.

---

# 23. New Test for the Override

A new test must be created.

Inside its:

```text
build_phase
```

the test must call:

```systemverilog
set_type_override_by_type
```

The assignment specifically requires this call to occur:

```text
BEFORE
super.build_phase()
```

Conceptually:

```text
new_test.build_phase()
        |
        v
set_type_override_by_type(...)
        |
        v
super.build_phase()
        |
        v
UVM component construction
```

This ordering is an explicit requirement.

---

# 24. Same Sequences Must Be Reused

The factory override must be demonstrated without changing the existing sequences.

The assignment requires:

> run the same sequences without changing them.

Therefore:

```text
Original Test
   |
   +-- Same Sequence
   |
   +-- Original Driver
```

and:

```text
Override Test
   |
   +-- SAME Sequence
   |
   +-- axi_driver_delay
```

The sequence remains unchanged; only the driver implementation changes through the factory.

---

# 25. Topology Verification

The assignment requires:

```systemverilog
uvm_top.print_topology()
```

The topology must be printed:

1. Before the override.
2. After the override.

The purpose is to demonstrate that the instantiated component type changed.

### Before

```text
Driver → axi_driver
```

### After

```text
Driver → axi_driver_delay
```

The topology snippets must be included as evidence.

---

# 26. Factory Override Flow

```text
                  Test
                   |
                   v
       set_type_override_by_type()
                   |
                   v
              UVM Factory
                   |
          +--------+--------+
          |                 |
          v                 v
    axi_driver       axi_driver_delay
                            |
                            v
                   Random Idle Cycles
```

The important point is that the sequence remains the same.

---

# 27. Optional Burst Verification

The assignment explicitly labels Burst verification as optional.

```text
Optional:
Verify AXI Burst Feature
```

The core project can therefore be completed using only basic READ/WRITE operations.

If implemented, Burst verification is an enhancement.

---

# 28. Other Optional Enhancements

The assignment states that students are free to add other UVM enhancements and practice topics learned during the course.

Therefore:

```text
Core Requirements
    ↓
Required UVM + READ/WRITE + coverage + assertions + factory override

Optional Enhancements
    ↓
Burst verification
Additional UVM features
```

---

# 29. Deliverable 1 — Archive

The first submission is a ZIP/RAR archive containing:

- All implemented UVM files
- Design files
- `run.do`

The required naming format is:

```text
your_name_uvm_project.rar
```

Example:

```text
Hassan_Khaled_uvm_project.rar
```

---

# 30. Deliverable 2 — PDF

A separate PDF must contain evidence of the verification work.

Required contents include:

### Code

Snippets for the implemented UVM files.

### Waveform

A waveform snippet clearly showing the different test cases.

### Logs

Log snippets showing all printed values using UVM reporting.

### Functional Coverage

Functional coverage report snippet.

### Code Coverage

Code coverage report snippets including available categories such as:

- Line
- Toggle
- Branch
- Condition
- etc.

### Assertions

Assertion coverage report snippet.

### Automation

Snippet of the `run.do` file used to automate the process.

---

# 31. Required PDF Filename

The report must use:

```text
your_name_uvm_project.pdf
```

Example:

```text
Hassan_Khaled_uvm_project.pdf
```

---

# 32. Suggested Project Organization

The following is a logical organization based on the assignment requirements:

```text
your_name_uvm_project/
│
├── rtl/
│   └── axi_memory_slave.sv
│
├── uvm/
│   ├── axi_transaction.sv
│   ├── axi_sequence.sv
│   ├── axi_sequencer.sv
│   ├── axi_driver.sv
│   ├── axi_driver_delay.sv
│   ├── axi_monitor.sv
│   ├── axi_checker.sv
│   ├── axi_coverage.sv
│   ├── memory_monitor.sv
│   ├── memory_checker.sv
│   ├── memory_coverage.sv
│   ├── axi_agent.sv
│   ├── memory_agent.sv
│   ├── axi_env.sv
│   ├── base_test.sv
│   └── override_test.sv
│
├── assertions/
│   └── axi_assertions.sv
│
├── tb/
│   └── tb_top.sv
│
└── run.do
```

This is a **suggested organization**, not a source-mandated filename list.

---

# 33. Complete Verification Flow

```text
AXI Specification
       ↓
Previous SystemVerilog DUT
       ↓
Fix Detected Bugs
       ↓
Understand AXI READ/WRITE Protocol
       ↓
Create Transactions
       ↓
Build AXI Active Agent
       ↓
Build Sequencer + Driver + Monitor
       ↓
Add AXI Checker
       ↓
Add AXI Covergroups
       ↓
Build Memory Passive Agent
       ↓
Add Memory Monitor
       ↓
Add Memory Checker
       ↓
Add Memory Covergroup
       ↓
Add Assertions
       ↓
Create READ/WRITE Sequences
       ↓
Run Tests
       ↓
Reach 100% Pass Rate
       ↓
Close Functional Coverage
       ↓
Close Code Coverage
       ↓
Check Assertion Coverage
       ↓
Create axi_driver_delay
       ↓
Apply Factory Type Override
       ↓
Print Topology Before/After
       ↓
Run Same Sequences
       ↓
Automate with run.do
       ↓
Prepare PDF Evidence
       ↓
Package RAR + PDF
```

---

# 34. Requirement Checklist

## DUT

- [ ] Obtain AXI specification.
- [ ] Obtain previous SystemVerilog AXI-memory design.
- [ ] Fix previously detected DUT bugs.
- [ ] Understand READ protocol.
- [ ] Understand WRITE protocol.
- [ ] Understand timing.

## UVM Environment

- [ ] Build UVM test.
- [ ] Build UVM environment.
- [ ] Build active AXI wrapper agent.
- [ ] Build passive memory agent.
- [ ] Implement required sequencer.
- [ ] Implement driver.
- [ ] Implement monitors.
- [ ] Implement sequence item(s).
- [ ] Implement representative sequences.

## AXI Agent

- [ ] Active operation.
- [ ] Checker.
- [ ] Covergroups.

## Memory Agent

- [ ] Passive operation.
- [ ] Memory monitor.
- [ ] Custom checker.
- [ ] Custom covergroup.

## Assertions

- [ ] Add assertions.
- [ ] Exercise assertions.
- [ ] Generate assertion coverage report.

## Coverage

- [ ] Functional coverage.
- [ ] Code coverage.
- [ ] Line coverage.
- [ ] Toggle coverage.
- [ ] Branch coverage.
- [ ] Condition coverage.
- [ ] Justify any missing coverage.

## UVM Methodology

- [ ] Appropriate phasing.
- [ ] UVM reporting.
- [ ] Draw actual UVM structure.

## Factory

- [ ] Implement `axi_driver_delay`.
- [ ] Inherit from original driver.
- [ ] Insert random idle cycles.
- [ ] Create new test.
- [ ] Call `set_type_override_by_type`.
- [ ] Perform override before `super.build_phase()`.
- [ ] Reuse the same sequences.
- [ ] Print topology before override.
- [ ] Print topology after override.
- [ ] Demonstrate instantiated type changed.

## Deliverables

- [ ] RAR/ZIP with UVM files.
- [ ] Design files.
- [ ] `run.do`.
- [ ] PDF with code snippets.
- [ ] Waveform snippets.
- [ ] UVM log snippets.
- [ ] Functional coverage snippet.
- [ ] Code coverage snippet.
- [ ] Assertion coverage snippet.
- [ ] `run.do` snippet.

---

# 35. Important Design Decisions

## Do not invent the AXI interface

The assignment references an external AXI specification and a previous design. Therefore, exact:

- AXI signal names
- Signal widths
- Address width
- Data width
- Response encoding
- Memory depth
- Timing
- Transaction format

must be taken from those sources.

## Do not treat Burst as mandatory

Burst verification is explicitly optional.

## Do not change sequences for the factory exercise

The factory exercise is specifically intended to show that the driver implementation can change while the same sequences continue to work.

## Do not merely define the delayed driver

The project must prove that the factory actually instantiates `axi_driver_delay`, using topology output before and after the override.

---

# 36. What the Assignment PDF Does Not Specify

The PDF does not contain the detailed AXI design specification itself.

It therefore does not define:

- Exact DUT RTL
- Exact AXI port list
- Exact signal widths
- Memory size
- Exact transaction class fields
- Exact read sequence
- Exact write sequence
- Exact checker algorithms
- Exact coverpoints/bins
- Exact assertions
- Exact simulation commands
- Actual coverage percentages
- Actual pass/fail results
- Actual topology output

These must be obtained from the referenced AXI specification, previous SystemVerilog project, and actual implementation/simulation.

---

# 37. Core Engineering Idea

The assignment is not simply an AXI testbench exercise.

It is designed to demonstrate a complete verification methodology:

```text
DUT
 ↓
Stimulus
 ↓
Monitoring
 ↓
Checking
 ↓
Coverage
 ↓
Assertions
 ↓
Reporting
 ↓
Automation
```

It also demonstrates the separation of concerns:

```text
AXI-side verification
        +
Memory-side verification
        +
Protocol assertions
        +
Functional/code coverage
```

Finally, the factory requirement demonstrates UVM's ability to modify component behavior without modifying the sequence stimulus.

---

# 38. Final Summary

The required project is a **full UVM verification environment for an AXI4-compliant memory-mapped slave**.

The core functionality is:

```text
READ + WRITE
```

without Burst.

The environment must contain:

```text
                 UVM TEST
                     |
                     v
                  UVM ENV
                 /       \
                /         \
               v           v
       AXI ACTIVE       MEMORY PASSIVE
          AGENT             AGENT
        /   |   \           |
       /    |    \          |
 Sequencer Driver Monitor  Monitor
       |       |      |       |
       |       |      +-------+---- Checker
       |       |              +---- Coverage
       |       |
       |       +---- AXI Checker
       |       +---- AXI Coverage
       |
       v
    AXI DUT
       |
       v
    Memory
```

The verification must target:

```text
100% Pass Rate
100% Functional Coverage
100% Code Coverage
Assertions + Assertion Coverage
```

The project must also demonstrate:

```text
Active Agent
Passive Agent
UVM Phasing
UVM Reporting
Factory Type Override
axi_driver_delay
Random Idle Cycles
Topology Before/After Override
run.do Automation
```

The final submission consists of:

```text
your_name_uvm_project.rar
your_name_uvm_project.pdf
```

---

# 39. Source Fidelity

This Markdown is derived from the uploaded two-page assignment. Requirements explicitly stated in the source are preserved. Details that the assignment says must come from the external AXI specification or previous DUT are deliberately not fabricated. fileciteturn6file0

## Original Source Text

The uploaded document states, in summary, that the project is an AXI4-compliant memory-mapped slave UVM verification project; it requires basic READ/WRITE verification, full UVM structure, active AXI and passive memory agents, checkers, covergroups, assertions, appropriate phasing/reporting, coverage closure, and a factory override using `axi_driver_delay`. It also specifies the RAR/PDF deliverables and required evidence. fileciteturn6file0
