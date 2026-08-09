// ============================================================
// alu_scoreboard.sv
// ============================================================
class alu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(alu_scoreboard)

  uvm_tlm_analysis_fifo #(alu_seq_item) exp_fifo;
  uvm_tlm_analysis_fifo #(alu_seq_item) act_fifo;
  uvm_tlm_analysis_fifo #(bit)          reset_fifo;

  int unsigned match_cnt;
  int unsigned mismatch_cnt;

  function new(string name="alu_scoreboard", uvm_component parent);
    super.new(name, parent);
    exp_fifo   = new("exp_fifo", this);
    act_fifo   = new("act_fifo", this);
    reset_fifo = new("reset_fifo", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    fork
      reset_handler();
    join_none
  endtask

  virtual task reset_handler();
    bit rst_val;
    fork
      compare_loop();
    join_none

    forever begin
      reset_fifo.get(rst_val);

      if (rst_val) begin
        `uvm_info("SCB", "Reset asserted -- pausing compare, flushing queues", UVM_LOW)
        disable compare_loop;
        exp_fifo.flush();
        act_fifo.flush();
      end else begin
        exp_fifo.flush();
        act_fifo.flush();
        `uvm_info("SCB", "Reset released -- resuming compare", UVM_LOW)
        fork
          compare_loop();
        join_none
      end
    end
  endtask

  virtual task compare_loop();
    alu_seq_item exp_pkt, act_pkt;
    forever begin
      exp_fifo.get(exp_pkt);
      act_fifo.get(act_pkt);
      compare(exp_pkt, act_pkt);
    end
  endtask

  virtual function void compare(alu_seq_item exp_pkt, alu_seq_item act_pkt);
    bit match;
    match = (exp_pkt.res   == act_pkt.res)   &&
            (exp_pkt.cout  == act_pkt.cout)  &&
            (exp_pkt.oflow == act_pkt.oflow) &&
            (exp_pkt.G     == act_pkt.G)     &&
            (exp_pkt.L     == act_pkt.L)     &&
            (exp_pkt.E     == act_pkt.E)     &&
            (exp_pkt.err   == act_pkt.err);

    if (match) begin
      match_cnt++;
      `uvm_info("SCB", $sformatf(
        "MATCH  res=%0h cout=%0b oflow=%0b G=%0b L=%0b E=%0b err=%0b",
        act_pkt.res, act_pkt.cout, act_pkt.oflow, act_pkt.G, act_pkt.L, act_pkt.E, act_pkt.err),
        UVM_HIGH)
    end else begin
      mismatch_cnt++;
      `uvm_error("SCB", $sformatf(
        "MISMATCH\n  expected: res=%0h cout=%0b oflow=%0b G=%0b L=%0b E=%0b err=%0b\n  actual  : res=%0h cout=%0b oflow=%0b G=%0b L=%0b E=%0b err=%0b",
        exp_pkt.res, exp_pkt.cout, exp_pkt.oflow, exp_pkt.G, exp_pkt.L, exp_pkt.E, exp_pkt.err,
        act_pkt.res, act_pkt.cout, act_pkt.oflow, act_pkt.G, act_pkt.L, act_pkt.E, act_pkt.err))
    end
  endfunction

  virtual function void report_phase(uvm_phase phase);
    `uvm_info("SCB", $sformatf(
      "SCOREBOARD SUMMARY: match=%0d mismatch=%0d", match_cnt, mismatch_cnt), UVM_NONE)
  endfunction

endclass