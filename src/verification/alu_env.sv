
class alu_env extends uvm_env;
  `uvm_component_utils(alu_env)

  alu_input_agent  in_agent;
  alu_output_agent out_agent;
  alu_ref_model    ref_model;
  alu_scoreboard   scb;
  alu_coverage     cov;

  function new(string name="alu_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    in_agent  = alu_input_agent::type_id::create("in_agent", this);
    out_agent = alu_output_agent::type_id::create("out_agent", this);
    ref_model = alu_ref_model::type_id::create("ref_model", this);
    scb = alu_scoreboard::type_id::create("scb", this);
    cov = alu_coverage::type_id::create("cov", this); 
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    in_agent.in_mon.input_broadcaster.connect(ref_model.input_fifo.analysis_export);
    in_agent.in_mon.reset_broadcaster.connect(ref_model.reset_listener.analysis_export);
    in_agent.in_mon.reset_broadcaster.connect(scb.reset_fifo.analysis_export);
    ref_model.exp_output.connect(scb.exp_fifo.analysis_export);
    out_agent.out_mon.output_broadcaster.connect(scb.act_fifo.analysis_export);
    in_agent.in_mon.input_broadcaster.connect(cov.analysis_export);
  endfunction

endclass
