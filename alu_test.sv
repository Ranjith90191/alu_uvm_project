// ============================================================
// alu_test.sv
// ============================================================
class alu_base_test extends uvm_test;
  `uvm_component_utils(alu_base_test)

  alu_env env;

  function new(string name="alu_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = alu_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    alu_base_sequence seq;
    phase.raise_objection(this);
    seq = alu_base_sequence::type_id::create("seq");
    seq.start(env.in_agent.sqr);
    phase.drop_objection(this);
  endtask

endclass