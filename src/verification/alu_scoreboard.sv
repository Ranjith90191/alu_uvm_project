
class alu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(alu_scoreboard)

  uvm_tlm_analysis_fifo #(alu_seq_item) exp_fifo;
  uvm_tlm_analysis_fifo #(alu_seq_item) act_fifo;
  uvm_tlm_analysis_fifo #(bit)          reset_fifo;

  int unsigned match_cnt;
  int unsigned mismatch_cnt;
  int report_fd;

  function new(string name="alu_scoreboard", uvm_component parent);
    super.new(name, parent);
    exp_fifo   = new("exp_fifo", this);
    act_fifo   = new("act_fifo", this);
    reset_fifo = new("reset_fifo", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    report_fd = $fopen("scoreboard_report.txt", "w");
    $fdisplay(report_fd, "=====================================================================================================================================================");
    $fdisplay(report_fd, "                                                              ALU SCOREBOARD REPORT");
    $fdisplay(report_fd, "=====================================================================================================================================================");
    $fdisplay(report_fd, "%-8s | %-32s | %-32s | %-32s | %-32s | %-6s", 
      "Time", "Applied Input (Time)", "Expected Output", "Actual Output", "Current Bus Input", "Status");
    $fdisplay(report_fd, "-----------------------------------------------------------------------------------------------------------------------------------------------------");
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
    string status_str;
    
    match = (exp_pkt.res   == act_pkt.res)   &&
            (exp_pkt.cout  == act_pkt.cout)  &&
            (exp_pkt.oflow == act_pkt.oflow) &&
            (exp_pkt.G     == act_pkt.G)     &&
            (exp_pkt.L     == act_pkt.L)     &&
            (exp_pkt.E     == act_pkt.E)     &&
            (exp_pkt.err   == act_pkt.err);

    if (match) begin
      match_cnt++;
      status_str = "PASS";
    end else begin
      mismatch_cnt++;
      status_str = "FAIL";
    end


    $fdisplay(report_fd, "%-8t | %0t: M=%b C=%0d A=%h B=%h | R=%h C=%b O=%b G=%b L=%b E=%b err=%b | R=%h C=%b O=%b G=%b L=%b E=%b err=%b | M=%b C=%0d A=%h B=%h | %s",
      $time,
      exp_pkt.req_time, exp_pkt.mode, exp_pkt.cmd, exp_pkt.OA, exp_pkt.OB,
      exp_pkt.res, exp_pkt.cout, exp_pkt.oflow, exp_pkt.G, exp_pkt.L, exp_pkt.E, exp_pkt.err,
      act_pkt.res, act_pkt.cout, act_pkt.oflow, act_pkt.G, act_pkt.L, act_pkt.E, act_pkt.err,
      act_pkt.mode, act_pkt.cmd, act_pkt.OA, act_pkt.OB,
      status_str
    );
  endfunction

  virtual function void report_phase(uvm_phase phase);
    $fdisplay(report_fd, "=====================================================================================================================================================");
    $fdisplay(report_fd, "SCOREBOARD SUMMARY: Matches = %0d, Mismatches = %0d", match_cnt, mismatch_cnt);
    $fclose(report_fd);
    
    `uvm_info("SCB", $sformatf(
      "SCOREBOARD SUMMARY: match=%0d mismatch=%0d (Check scoreboard_report.txt for details)", match_cnt, mismatch_cnt), UVM_NONE)
  endfunction

endclass
