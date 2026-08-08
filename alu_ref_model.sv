class alu_ref_model extends uvm_component;
  `uvm_component_utils(alu_ref_model)

  uvm_tlm_analysis_fifo #(alu_seq_item) input_fifo;
  uvm_tlm_analysis_fifo #(bit) reset_listener;
  uvm_analysis_port     #(alu_seq_item) exp_output;

  typedef enum {IDLE, WAIT_A, WAIT_B, MUL_BUSY} pred_state_e;
  pred_state_e   state;
  logic [DW-1:0] oprd1, oprd2;
  logic [CW-1:0] p_cmd;
  logic          p_mode;
  bit   [4:0]    wait_counter;

  logic [2*DW-1:0] h_res;
  bit h_cout, h_oflow, h_g, h_e, h_l, h_err;

  bit mul_active;
  logic [2*DW-1:0] mul_result;
  int mul_cycles_left;

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
    mul_active=0; mul_result='0; mul_cycles_left=0;
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
        push_held(0);
      end
    end
  endtask

  virtual task comparer();
    alu_seq_item pkt;
    forever begin
      input_fifo.get(pkt);

      if (!pkt.ce) begin
        push_held(0);   // CE low: nothing advances, not even an in-flight multiply
        continue;
      end

      case (state)
        IDLE: begin
          if (pkt.inp_valid == 2'b11) begin
            oprd1=pkt.opa; oprd2=pkt.opb; p_cmd=pkt.cmd; p_mode=pkt.mode;
            commit(pkt.cin);
          end else if (pkt.inp_valid == 2'b01) begin
            oprd1=pkt.opa; p_cmd=pkt.cmd; p_mode=pkt.mode;
            wait_counter=0; state=WAIT_B;
          end else if (pkt.inp_valid == 2'b10) begin
            oprd2=pkt.opb; p_cmd=pkt.cmd; p_mode=pkt.mode;
            wait_counter=0; state=WAIT_A;
          end
        end

        WAIT_B: begin
            if (pkt.inp_valid == 2'b11) begin
                oprd1=pkt.opa; oprd2=pkt.opb; p_cmd=pkt.cmd; p_mode=pkt.mode;
                commit(pkt.cin);
            end else if (pkt.inp_valid == 2'b10) begin
                oprd2=pkt.opb; p_cmd=pkt.cmd; p_mode=pkt.mode;
                commit(pkt.cin);
            end else if (pkt.inp_valid == 2'b01) begin
                oprd1=pkt.opa; p_cmd=pkt.cmd; p_mode=pkt.mode;
                wait_counter=0;
            end else if (pkt.inp_valid == 2'b00) begin
                oprd1='0; oprd2='0; state=IDLE; wait_counter=0;
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
                oprd1=pkt.opa; oprd2=pkt.opb; p_cmd=pkt.cmd; p_mode=pkt.mode;
                commit(pkt.cin);
            end else if (pkt.inp_valid == 2'b01) begin
                oprd1=pkt.opa; p_cmd=pkt.cmd; p_mode=pkt.mode;      // was missing before too
                commit(pkt.cin);
            end else if (pkt.inp_valid == 2'b10) begin
                oprd2=pkt.opb; p_cmd=pkt.cmd; p_mode=pkt.mode;      // <-- the fix
                wait_counter=0;
            end else if (pkt.inp_valid == 2'b00) begin
                oprd1='0; oprd2='0; state=IDLE; wait_counter=0;
            end else if (pkt.cmd != p_cmd || pkt.mode != p_mode) begin
                p_cmd=pkt.cmd; p_mode=pkt.mode; wait_counter=0;
            end else if (wait_counter==15) begin
                timeout();
            end else begin
                wait_counter++;
            end
        end
        MUL_BUSY: begin
        end
      endcase
      push_held(1);
    end
  endtask

  function void commit(logic cin);
    compute(oprd1, oprd2, p_cmd, p_mode, cin);
    wait_counter = 0;
    state = mul_active ? MUL_BUSY : IDLE;
  endfunction

  function void timeout();
    h_err = 1'b1;
    state = IDLE;
    wait_counter = 0;
  endfunction

  function automatic logic [DW-1:0] rol_dw(logic [DW-1:0] val, logic [2:0] amt);
    rol_dw = (val << amt) | (val >> (DW-amt));
  endfunction

  function automatic logic [DW-1:0] ror_dw(logic [DW-1:0] val, logic [2:0] amt);
    ror_dw = (val >> amt) | (val << (DW-amt));
  endfunction

  function void compute(logic [DW-1:0] a, b, logic [CW-1:0] cmd, logic mode, logic cin);
    h_err = 1'b0; 
    if (mode) begin // ---------------- arithmetic ----------------
      case (cmd)
        4'b0000: begin // ADD
          logic [DW:0] s; s = {1'b0,a} + {1'b0,b};
          h_cout = s[DW]; h_res = s[DW-1:0];
        end
        4'b0001: begin // SUB
          logic [DW-1:0] r; r = a - b;
          h_res = r;
          h_oflow = (a[DW-1]!=b[DW-1]) && (r[DW-1]!=a[DW-1]);
        end
        4'b0010: begin // ADD_CIN
          logic [DW:0] s; s = {1'b0,a} + {1'b0,b} + cin;
          h_cout = s[DW]; h_res = s[DW-1:0];
        end
        4'b0011: begin // SUB_CIN
          logic [DW-1:0] r; r = a - b - cin;
          h_res = r;
          h_oflow = (a[DW-1]!=b[DW-1]) && (r[DW-1]!=a[DW-1]);
        end
        4'b0100: h_res = a + 1;   // INC_A
        4'b0101: h_res = a - 1;   // DEC_A
        4'b0110: h_res = b + 1;   // INC_B
        4'b0111: h_res = b - 1;   // DEC_B
        4'b1000: begin
          h_g = (a > b); h_e = (a == b); h_l = (a < b);
        end
        4'b1001: begin // MUL_INC 
          logic [DW-1:0] t1, t2;
          t1 = a + 1; t2 = b + 1;
          mul_active = 1; mul_result = t1*t2; mul_cycles_left = 3;
        end
        4'b1010: begin 
          logic [DW-1:0] t1, t2;
          t1 = a << 1; t2 = b;
          mul_active = 1; mul_result = t1*t2; mul_cycles_left = 3;
        end
        default: ;
      endcase
    end
    else begin // ---------------- logical ----------------
      case (cmd)
        4'b0000: h_res = {1'b0, a & b};
        4'b0001: h_res = {1'b0, ~(a & b)};
        4'b0010: h_res = {1'b0, a | b};
        4'b0011: h_res = {1'b0, ~(a | b)};
        4'b0100: h_res = {1'b0, a ^ b};
        4'b0101: h_res = {1'b0, ~(a ^ b)};
        4'b0110: h_res = {1'b0, ~a};
        4'b0111: h_res = {1'b0, ~b};
        4'b1000: h_res = {1'b0, a >> 1};
        4'b1001: h_res = {1'b0, a << 1};
        4'b1010: h_res = {1'b0, b >> 1};
        4'b1011: h_res = {1'b0, b << 1};
        4'b1100: begin h_res = {1'b0, rol_dw(a,b[2:0])}; h_err = |b[7:4]; end
        4'b1101: begin h_res = {1'b0, ror_dw(a,b[2:0])}; h_err = |b[7:4]; end
        default: ;
      endcase
    end
  endfunction

  function void push_held(bit advance_mul);
    alu_seq_item out_pkt;

    if (advance_mul && mul_active) begin
      mul_cycles_left--;
      if (mul_cycles_left <= 0) begin
        h_res = mul_result;
        mul_active = 0;
        state = IDLE;  
      end
    end
    out_pkt = alu_seq_item::type_id::create("out_pkt");
    out_pkt.res=h_res; out_pkt.cout=h_cout; out_pkt.oflow=h_oflow;
    out_pkt.g=h_g; out_pkt.e=h_e; out_pkt.l=h_l; out_pkt.err=h_err;
    exp_output.write(out_pkt);
  endfunction

endclass