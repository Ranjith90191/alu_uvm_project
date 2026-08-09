// ============================================================
// alu_input_monitor.sv
// ============================================================
class alu_input_monitor extends uvm_monitor;
  `uvm_component_utils(alu_input_monitor)

  virtual alu_if.MON vif;
  uvm_analysis_port #(alu_seq_item) input_broadcaster;
  uvm_analysis_port #(bit)          reset_broadcaster;

  function new(string name="alu_input_monitor", uvm_component parent);
    super.new(name, parent);
    input_broadcaster = new("input_broadcaster", this);
    reset_broadcaster = new("reset_broadcaster", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("ALU_MON", "Virtual interface not set ");
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    fork
      watch_reset();
      watch_inputs();
    join_none
  endtask

  virtual task watch_reset();
    forever begin
      @(posedge vif.rst);
      `uvm_info("MON", "Reset detected mid-run - aborting in-flight transfer", UVM_LOW)
      reset_broadcaster.write(1'b1);
      @(negedge vif.rst);
      `uvm_info("MON", "Reset released - resuming watch_inputs", UVM_LOW)
      reset_broadcaster.write(1'b0);
    end
  endtask

  virtual task watch_inputs();
    alu_seq_item pkt;   // was undefined alu_base_seq_item -- fixed
    forever begin
      @(vif.mon_cb);
      if (vif.rst) begin
        wait (vif.rst == 1'b0);
        continue;
      end
      pkt = alu_seq_item::type_id::create("pkt");
      pkt.mode      = vif.mon_cb.mode;
      pkt.cmd       = vif.mon_cb.cmd;
      pkt.OA        = vif.mon_cb.OA;
      pkt.OB        = vif.mon_cb.OB;
      pkt.cin       = vif.mon_cb.cin;
      pkt.inp_valid = vif.mon_cb.inp_valid;
      pkt.ce        = vif.mon_cb.ce;   // was missing -- ref model needs this every cycle
      `uvm_info("MON", $sformatf(
        "Inputs: mode=%0d, cmd=%0d, OA=%0h, OB=%0h, cin=%0d, inp_valid=%0b, ce=%0b",
        pkt.mode, pkt.cmd, pkt.OA, pkt.OB, pkt.cin, pkt.inp_valid, pkt.ce), UVM_LOW)
      input_broadcaster.write(pkt);
    end
  endtask
endclass
