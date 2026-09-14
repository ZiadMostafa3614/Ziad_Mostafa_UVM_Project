

<!-- Start of picture text -->
Coverage Scoreboard<br>Seq_item Sequence = If DUT<br>Monitor ly<br>7 Sequencer = Driver<br><!-- End of picture text -->

- U have to practice the Factory Type Override on a component. Create a class **axi_driver_delay** which inherits from your driver and inserts random idle cycles between the transfers instead of driving them back to back. In a new test apply **set_type_override_by_type** inside the **build_phase** before calling **super.build_phase()** and run the same sequences without changing them. U have to deliver a snippet for **uvm_top.print_topology() before and after** the override showing that the instantiated type changed. 

# **Extra Requirement (Optional)** 

- Verifying the **Brust** Feature for The AXI-Memory mapped design. 

- Any other enhancements on the UVM structure you are building it is up to you and you are free to practice all the topics you learnt take the project as a chance for strengthening your knowledge. 



# **Deliverables:** 

## U have to deliver two separated files 

- <u>Zip Folder</u> contains: 

   - All the implemented uvm files and the design files <u>and</u> run.do file . 

- **<u>Separated PDF</u>** contains: 

   - Snippets for the implemented code. 

   - Snippet for the waveform shows the different testcases clearly. 

   - Snippets for the logs show the all printed values using UVM reporting. 

   - Snippets for functional coverage report. 

   - Snippets for code coverage report for all parameters [Line / toggle / branch /condition/…] 

   - Snippets for Assertions Coverage report. 

   - Snippet for Do file you have used for automating the process. 

The delivered zip file must be named like **your_name_uvm_project.rar** for example: 

**Hassan_Khaled_uvm_project.rar** also the PDF file **Hassan_Khaled_uvm_project.pdf** 



Good Luck 

