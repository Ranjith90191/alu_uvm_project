`include "alu_defines.svh"

class alu_ref_model extends uvm_component;
  `uvm_component_utils(alu_ref_model)

  uvm_tlm_analysis_fifo #(alu_seq_item) input_fifo;
  uvm_tlm_analysis_fifo #(bit)          reset_listener;
  uvm_analysis_port     #(alu_seq_item) exp_output;

  typedef enum {IDLE, WAIT_A, WAIT_B, MUL_BUSY} pred_state_e;
  pred_state_e    state;
  logic [`DW-1:0] oprd1, oprd2;
  logic [`CW-1:0] p_cmd;
  logic           p_mode;
  bit   [4:0]     wait_counter;

  logic [2*`DW-1:0] h_res;
  bit               h_cout, h_oflow, h_g, h_e, h_l, h_err;
  logic [`DW-1:0]   h_in_a, h_in_b;
  logic [`CW-1:0]   h_in_cmd;
  logic             h_in_mode;
  time              h_in_time;

  typedef struct {
    bit               valid;
    logic [2*`DW-1:0] res;
    bit cout, oflow, g, e, l, err;
    logic [`DW-1:0]   in_a, in_b;
    logic [`CW-1:0]   in_cmd;
    logic             in_mode;
    time              in_time;
  } ord_stage_t;

  ord_stage_t ord_pipe[2];

  bit               mul_active;
  int               mul_cycles_left;
  logic [2*`DW-1:0] mul_result;
  logic [`DW-1:0]   mul_in_a, mul_in_b;
  logic [`CW-1:0]   mul_in_cmd;
  logic             mul_in_mode;
  time              mul_in_time;

  bit               mul_gap_pending;

  bit               mul_queued;
  logic [2*`DW-1:0] mul_q_result;
  logic [`DW-1:0]   mul_q_in_a, mul_q_in_b;
  logic [`CW-1:0]   mul_q_in_cmd;
  logic             mul_q_in_mode;
  time              mul_q_in_time;

  function new(string name="alu_ref_model", uvm_component parent);
    super.new(name, parent);
    input_fifo     = new("input_fifo", this);
    exp_output     = new("exp_output", this);
    reset_listener = new("reset_listener", this);
  endfunction

  function void reset_state();
    state = IDLE;
    oprd1='0; oprd2='0; p_cmd='0; p_mode=1'b0; wait_counter='0;

    h_res='0; h_cout=0; h_oflow=0; h_g=0; h_e=0; h_l=0; h_err=0;
    h_in_a='0; h_in_b='0; h_in_cmd='0; h_in_mode=0; h_in_time=0;

    foreach (ord_pipe[i]) ord_pipe[i] = '{default:0};

    mul_active=0; mul_cycles_left=0; mul_result='0;
    mul_in_a='0; mul_in_b='0; mul_in_cmd='0; mul_in_mode=0; mul_in_time=0;
    mul_gap_pending=0;

    mul_queued=0; mul_q_result='0;
    mul_q_in_a='0; mul_q_in_b='0; mul_q_in_cmd='0; mul_q_in_mode=0; mul_q_in_time=0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reset_state();
  endfunction

  virtual task run_phase(uvm_phase phase);
    fork
      reset_responder();
      comparer();
    join_none
  endtask

  virtual task reset_responder();
    bit rst_val;
    forever begin
      reset_listener.get(rst_val);
      if (rst_val) begin
        reset_state();
        push_out(0);
      end
    end
  endtask

  virtual task comparer();
    alu_seq_item pkt;
    forever begin
      input_fifo.get(pkt);

      if (!pkt.ce) begin
        push_out(0);
        continue;
      end

      advance_ord_pipe();

      case (state)
        IDLE: try_capture(pkt);

        WAIT_B: begin
          if (pkt.inp_valid == 2'b11) begin
            oprd1=pkt.OA; oprd2=pkt.OB; p_cmd=pkt.cmd; p_mode=pkt.mode;
            commit(pkt.cin);
          end else if (pkt.inp_valid == 2'b10) begin
            oprd2=pkt.OB; p_cmd=pkt.cmd; p_mode=pkt.mode;
            commit(pkt.cin);
          end else if (pkt.inp_valid == 2'b01) begin
            oprd1=pkt.OA; p_cmd=pkt.cmd; p_mode=pkt.mode;
            wait_counter=0;
          end else if (pkt.cmd != p_cmd || pkt.mode != p_mode) begin
            p_cmd=pkt.cmd; p_mode=pkt.mode; wait_counter=0;
          end else if (wait_counter==15) begin
            timeout();
          end else begin
            wait_counter++;
          end
        end

        WAIT_A: begin
          if (pkt.inp_valid == 2'b11) begin
            oprd1=pkt.OA; oprd2=pkt.OB; p_cmd=pkt.cmd; p_mode=pkt.mode;
            commit(pkt.cin);
          end else if (pkt.inp_valid == 2'b01) begin
            oprd1=pkt.OA; p_cmd=pkt.cmd; p_mode=pkt.mode;
            commit(pkt.cin);
          end else if (pkt.inp_valid == 2'b10) begin
            oprd2=pkt.OB; p_cmd=pkt.cmd; p_mode=pkt.mode; 
            wait_counter=0;
          end else if (pkt.cmd != p_cmd || pkt.mode != p_mode) begin
            p_cmd=pkt.cmd; p_mode=pkt.mode; wait_counter=0;
          end else if (wait_counter==15) begin
            timeout();
          end else begin
            wait_counter++;  
          end
        end

        MUL_BUSY: begin
          if (mul_gap_pending) begin
            mul_gap_pending = 0;

            if (pkt.inp_valid==2'b11 && pkt.mode==1'b1 &&
                (pkt.cmd==4'b1001 || pkt.cmd==4'b1010)) begin
              queue_second_mul(pkt);
            end
            else if (pkt.inp_valid == 2'b00) begin
            end
            else begin
              abort_mul();
              try_capture(pkt);
            end
          end
        end
      endcase

      push_out(1);
    end
  endtask

  function void try_capture(alu_seq_item pkt);
    if (pkt.inp_valid == 2'b11) begin
      oprd1=pkt.OA; oprd2=pkt.OB; p_cmd=pkt.cmd; p_mode=pkt.mode;
      commit(pkt.cin);
    end else if (pkt.inp_valid == 2'b01) begin
      oprd1=pkt.OA; p_cmd=pkt.cmd; p_mode=pkt.mode;
      wait_counter=0; state=WAIT_B;
    end else if (pkt.inp_valid == 2'b10) begin
      oprd2=pkt.OB; p_cmd=pkt.cmd; p_mode=pkt.mode;
      wait_counter=0; state=WAIT_A;
    end else begin
      state = IDLE; 
    end
  endfunction

  function void advance_ord_pipe();
    if (ord_pipe[1].valid) begin
      h_res=ord_pipe[1].res; h_cout=ord_pipe[1].cout; h_oflow=ord_pipe[1].oflow;
      h_g=ord_pipe[1].g; h_e=ord_pipe[1].e; h_l=ord_pipe[1].l; h_err=ord_pipe[1].err;
      h_in_a=ord_pipe[1].in_a; h_in_b=ord_pipe[1].in_b; h_in_cmd=ord_pipe[1].in_cmd;
      h_in_mode=ord_pipe[1].in_mode; h_in_time=ord_pipe[1].in_time;
    end
    ord_pipe[1] = ord_pipe[0];
    ord_pipe[0] = '{default:0};
  endfunction

  function void commit(logic cin);
    compute(oprd1, oprd2, p_cmd, p_mode, cin);
    wait_counter = 0;
    if (mul_active) begin
      state = MUL_BUSY;
      mul_gap_pending = 1;
    end else begin
      state = IDLE;
    end
  endfunction

  function void timeout();
    ord_stage_t nv;
    nv.valid=1;
    nv.res=h_res; nv.cout=h_cout; nv.oflow=h_oflow;
    nv.g=h_g; nv.e=h_e; nv.l=h_l;
    nv.err=1'b1; 
    nv.in_a=oprd1; nv.in_b=oprd2; nv.in_cmd=p_cmd; nv.in_mode=p_mode; nv.in_time=$time;
    ord_pipe[0] = nv;
    state = IDLE;
    wait_counter = 0;
  endfunction

  function void start_mul(logic [2*`DW-1:0] result, logic [`DW-1:0] a, b,
                           logic [`CW-1:0] cmd, logic mode);
    mul_active = 1;
    mul_result = result;
    mul_cycles_left = 4;   // empirically commit+3 -- see prior message
    mul_in_a=a; mul_in_b=b; mul_in_cmd=cmd; mul_in_mode=mode; mul_in_time=$time;
  endfunction

  function void queue_second_mul(alu_seq_item pkt);
    logic [`DW-1:0] t1, t2;
    if (pkt.cmd == 4'b1001) begin t1 = pkt.OA + 1; t2 = pkt.OB + 1; end
    else                    begin t1 = pkt.OA << 1; t2 = pkt.OB;     end
    mul_queued   = 1;
    mul_q_result = t1 * t2;
    mul_q_in_a=pkt.OA; mul_q_in_b=pkt.OB; mul_q_in_cmd=pkt.cmd;
    mul_q_in_mode=pkt.mode; mul_q_in_time=$time;
  endfunction

  function void abort_mul();
    mul_active = 0;
    mul_cycles_left = 0;
    mul_queued = 0;
    mul_gap_pending = 0;
  endfunction

  function automatic logic [`DW-1:0] rol_dw(logic [`DW-1:0] val, logic [2:0] amt);
    rol_dw = (val << amt) | (val >> (`DW-amt));
  endfunction

  function automatic logic [`DW-1:0] ror_dw(logic [`DW-1:0] val, logic [2:0] amt);
    ror_dw = (val >> amt) | (val << (`DW-amt));
  endfunction

  function void compute(logic [`DW-1:0] a, b, logic [`CW-1:0] cmd, logic mode, logic cin);
    logic [`DW:0]   s;
    logic [`DW-1:0] diff, t1, t2;
    ord_stage_t     nv;

    nv.valid=1;
    nv.res=h_res; nv.cout=h_cout; nv.oflow=h_oflow;
    nv.g=h_g; nv.e=h_e; nv.l=h_l; nv.err=1'b0;   // ASSUMPTION: success clears ERR
    nv.in_a=a; nv.in_b=b; nv.in_cmd=cmd; nv.in_mode=mode; nv.in_time=$time;

    if (mode) begin // ---------------- arithmetic ----------------
      case (cmd)
        4'b0000: begin s={1'b0,a}+{1'b0,b}; nv.cout=s[`DW]; nv.res=s; end   // ADD

        4'b0001: begin // SUB
          diff = a - b;
          nv.res = {{`DW{diff[`DW-1]}}, diff};
          nv.oflow = (a[`DW-1]!=b[`DW-1]) && (diff[`DW-1]!=a[`DW-1]);
        end

        4'b0010: begin s={1'b0,a}+{1'b0,b}+cin; nv.cout=s[`DW]; nv.res=s; end // ADD_CIN

        4'b0011: begin // SUB_CIN 
          diff = a - b - cin;
          nv.res = {{`DW{diff[`DW-1]}}, diff};
          nv.oflow = (a[`DW-1]!=b[`DW-1]) && (diff[`DW-1]!=a[`DW-1]);
        end

        4'b0100: begin s={1'b0,a}+1; nv.res=s; end   // INC_A
        4'b0101: begin s={1'b0,a}-1; nv.res=s; end   // DEC_A
        4'b0110: begin s={1'b0,b}+1; nv.res=s; end   // INC_B
        4'b0111: begin s={1'b0,b}-1; nv.res=s; end   // DEC_B
        4'b1000: begin nv.g=(a>b); nv.e=(a==b); nv.l=(a<b); end   // CMP
        4'b1001: begin t1=a+1;  t2=b+1; start_mul(t1*t2, a, b, cmd, mode); return; end // MUL_INC
        4'b1010: begin t1=a<<1; t2=b;   start_mul(t1*t2, a, b, cmd, mode); return; end // MUL_SHL
        default: ;
      endcase
    end
    else begin // ---------------- logical ----------------
      case (cmd)
        4'b0000: nv.res = {1'b0, a & b};
        4'b0001: nv.res = {1'b0, ~(a & b)};
        4'b0010: nv.res = {1'b0, a | b};
        4'b0011: nv.res = {1'b0, ~(a | b)};
        4'b0100: nv.res = {1'b0, a ^ b};
        4'b0101: nv.res = {1'b0, ~(a ^ b)};
        4'b0110: nv.res = {1'b0, ~a};
        4'b0111: nv.res = {1'b0, ~b};
        4'b1000: nv.res = {1'b0, a >> 1};
        4'b1001: nv.res = {1'b0, a << 1};
        4'b1010: nv.res = {1'b0, b >> 1};
        4'b1011: nv.res = {1'b0, b << 1};
        4'b1100: begin nv.res={1'b0,rol_dw(a,b[2:0])}; nv.err=|b[7:4]; end
        4'b1101: begin nv.res={1'b0,ror_dw(a,b[2:0])}; nv.err=|b[7:4]; end
        default: ;
      endcase
    end

    ord_pipe[0] = nv;
  endfunction


  function void push_out(bit advance);
    alu_seq_item out_pkt;

    if (advance && mul_active) begin
      mul_cycles_left--;
      if (mul_cycles_left <= 0) begin
        h_res=mul_result;
        h_cout=0; h_oflow=0; h_g=0; h_e=0; h_l=0;
        h_err=0;
        h_in_a=mul_in_a; h_in_b=mul_in_b; h_in_cmd=mul_in_cmd;
        h_in_mode=mul_in_mode; h_in_time=mul_in_time;
        mul_active = 0;

        if (mul_queued) begin
          mul_active = 1;
          mul_cycles_left = 1;
          mul_result = mul_q_result;
          mul_in_a=mul_q_in_a; mul_in_b=mul_q_in_b; mul_in_cmd=mul_q_in_cmd;
          mul_in_mode=mul_q_in_mode; mul_in_time=mul_q_in_time;
          mul_queued = 0;
          state = MUL_BUSY;
        end else begin
          state = IDLE;
        end
      end
    end

    out_pkt = alu_seq_item::type_id::create("out_pkt");
    out_pkt.res=h_res; out_pkt.cout=h_cout; out_pkt.oflow=h_oflow;
    out_pkt.G=h_g; out_pkt.L=h_l; out_pkt.E=h_e; out_pkt.err=h_err;
    out_pkt.OA=h_in_a; out_pkt.OB=h_in_b; out_pkt.cmd=h_in_cmd; out_pkt.mode=h_in_mode;
    out_pkt.req_time=h_in_time;
    exp_output.write(out_pkt);
  endfunction

endclass
