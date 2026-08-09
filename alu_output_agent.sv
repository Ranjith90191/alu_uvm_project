// ============================================================
// alu_output_agent.sv
// ============================================================
// Monitor-only: nothing to drive on the output side. Previously
// had a dead drv/sqr copy-pasted from the input agent -- removed.
class alu_output_agent extends uvm_agent;
  `uvm_component_utils(alu_output_agent)   // was alu_agent -- collided with input agent

  alu_output_monitor out_mon;   // was wrongly typed alu_input_monitor before

  function new(string name="alu_output_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    out_mon = alu_output_monitor::type_id::create("out_mon", this);
  endfunction
endclass