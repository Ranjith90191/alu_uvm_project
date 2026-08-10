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
    alu_add_seq          seq_add;
    alu_sub_seq          seq_sub;
    alu_add_cin_seq      seq_addc;
    alu_sub_cin_seq      seq_subc;
    alu_inc_a_seq seq_inca;
    alu_dec_a_seq  seq_deca;
    alu_inc_b_seq  seq_incb;
    alu_dec_b_seq seq_decb;
    alu_cmp_seq  seq_cmp;
    alu_mul_inc_seq  seq_muli;
    alu_mul_shl_seq  seq_muls;
    alu_logic_basic_seq  seq_log_b;
    alu_logic_shift_seq  seq_log_s;
    alu_logic_rotate_seq seq_log_r;
    alu_wait_cycle_seq_err seq_wait_err;
    alu_wait_cycle_seq   seq_wait;
	alu_rand seq_rand;
	alu_rand_valid_seq seq_valid_rand;
	alu_wait seq_waiter;
    phase.raise_objection(this);

    seq_add = alu_add_seq::type_id::create("seq_add");       seq_add.start(env.in_agent.sqr);
    seq_sub = alu_sub_seq::type_id::create("seq_sub");       seq_sub.start(env.in_agent.sqr);
    seq_addc = alu_add_cin_seq::type_id::create("seq_addc"); seq_addc.start(env.in_agent.sqr);
    seq_subc = alu_sub_cin_seq::type_id::create("seq_subc"); seq_subc.start(env.in_agent.sqr);
    seq_inca = alu_inc_a_seq::type_id::create("seq_inca");   seq_inca.start(env.in_agent.sqr);
    seq_deca = alu_dec_a_seq::type_id::create("seq_deca");   seq_deca.start(env.in_agent.sqr);
    seq_incb = alu_inc_b_seq::type_id::create("seq_incb");   seq_incb.start(env.in_agent.sqr);
    seq_decb = alu_dec_b_seq::type_id::create("seq_decb");   seq_decb.start(env.in_agent.sqr);
    seq_cmp = alu_cmp_seq::type_id::create("seq_cmp");       seq_cmp.start(env.in_agent.sqr);
    seq_muli = alu_mul_inc_seq::type_id::create("seq_muli"); seq_muli.start(env.in_agent.sqr);
    seq_muls = alu_mul_shl_seq::type_id::create("seq_muls"); seq_muls.start(env.in_agent.sqr);

    seq_log_b = alu_logic_basic_seq::type_id::create("seq_log_b"); seq_log_b.start(env.in_agent.sqr);
    seq_log_s = alu_logic_shift_seq::type_id::create("seq_log_s"); seq_log_s.start(env.in_agent.sqr);
    seq_log_r = alu_logic_rotate_seq::type_id::create("seq_log_r"); seq_log_r.start(env.in_agent.sqr);
    
    seq_wait = alu_wait_cycle_seq::type_id::create("seq_wait"); seq_wait.start(env.in_agent.sqr);
	seq_wait_err = alu_wait_cycle_seq_err::type_id::create("seq_wait_err"); seq_wait_err.start(env.in_agent.sqr);
	seq_rand = alu_rand::type_id::create("seq_rand"); seq_rand.start(env.in_agent.sqr);
	seq_valid_rand = alu_rand_valid_seq::type_id::create("seq_valid_rand"); seq_valid_rand.start(env.in_agent.sqr);
	seq_waiter = alu_wait::type_id::create("seq_waiter"); seq_waiter.start(env.in_agent.sqr);
    phase.drop_objection(this);
  endtask

endclass
