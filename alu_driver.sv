// ============================================================
// alu_driver.sv
// ============================================================
class alu_driver extends uvm_driver #(alu_seq_item);
  `uvm_component_utils(alu_driver)

  virtual alu_if.DRV vif;
  bit item_outstanding;

  function new(string name="alu_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("ALU_DRV", ("Virtual interface not set for: " + get_full_name() + ".vif"));
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    fork
      drive_loop();
      reset_watcher();
    join_none
  endtask

  virtual task drive_idle();
    vif.drv_cb.mode      <= 0;
    vif.drv_cb.cmd       <= 0;
    vif.drv_cb.OA        <= 0;
    vif.drv_cb.OB        <= 0;
    vif.drv_cb.cin       <= 0;
    vif.drv_cb.inp_valid <= 0;
    vif.drv_cb.ce        <= 0;
  endtask

  virtual task reset_watcher();
    forever begin
      @(posedge vif.rst);
      `uvm_info("DRV", "Reset detected mid-run - aborting in-flight transfer", UVM_LOW)
      disable drive_loop;
      drive_idle();
      if (item_outstanding) begin
        seq_item_port.item_done();
        item_outstanding = 0;
      end
      @(negedge vif.rst);
      `uvm_info("DRV", "Reset released - resuming drive_loop", UVM_LOW)
      fork
        drive_loop();
      join_none
    end
  endtask

  virtual task drive_loop();
    forever begin
      @(vif.drv_cb);
      seq_item_port.get_next_item(req);
      item_outstanding = 1;
      vif.drv_cb.mode      <= req.mode;
      vif.drv_cb.cmd       <= req.cmd;
      vif.drv_cb.OA        <= req.OA;
      vif.drv_cb.OB        <= req.OB;
      vif.drv_cb.cin       <= req.cin;
      vif.drv_cb.inp_valid <= req.inp_valid;
      vif.drv_cb.ce        <= req.ce;   // was missing -- ce never drove before
      seq_item_port.item_done();
      item_outstanding = 0;
    end
  endtask

endclass