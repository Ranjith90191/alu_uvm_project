class alu_output_monitor extends uvm_monitor;
  `uvm_component_utils(alu_output_monitor)

  virtual alu_if.MON vif;
  uvm_analysis_port #(alu_seq_item) output_broadcaster;

  function new(string name="alu_output_monitor", uvm_component parent);
    super.new(name, parent);
    output_broadcaster = new("output_broadcaster", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("ALU_MON", "Virtual interface not set ");
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    alu_seq_item out_pkt;
    forever begin
      @(vif.mon_cb);
      if (vif.rst) begin
        wait (vif.rst == 1'b0);
        continue;
      end
      out_pkt = alu_seq_item::type_id::create("out_pkt");
      
      out_pkt.res   = vif.mon_cb.res;
      out_pkt.cout  = vif.mon_cb.cout;
      out_pkt.oflow = vif.mon_cb.oflow;
      out_pkt.G     = vif.mon_cb.G;
      out_pkt.L     = vif.mon_cb.L;
      out_pkt.E     = vif.mon_cb.E;
      out_pkt.err   = vif.mon_cb.err;
      out_pkt.OA    = vif.mon_cb.OA;
      out_pkt.OB    = vif.mon_cb.OB;
      out_pkt.cmd   = vif.mon_cb.cmd;
      out_pkt.mode  = vif.mon_cb.mode;

      output_broadcaster.write(out_pkt);
    end
  endtask
endclass
