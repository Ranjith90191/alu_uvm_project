class alu_input_agent extends uvm_agent;
  `uvm_component_utils(alu_input_agent)

  alu_input_monitor in_mon;
  alu_driver        drv;
  alu_sequencer     sqr;

  function new(string name="alu_input_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    in_mon = alu_input_monitor::type_id::create("in_mon", this);
    if (get_is_active() == UVM_ACTIVE) begin
      drv = alu_driver::type_id::create("drv", this);
      sqr = alu_sequencer::type_id::create("sqr", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
    end
  endfunction
endclass
