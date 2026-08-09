// ============================================================
// alu_sequence.sv
// ============================================================

// --- Arithmetic Sequences (Mode 1) ---

class alu_add_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_add_seq)
  function new(string name="alu_add_seq"); super.new(name); endfunction
  virtual task body();
    repeat (`NUM_SEQ) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {cmd==4'b0000; mode==1; inp_valid==2'b11; ce==1;}) 
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

class alu_sub_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_sub_seq)
  function new(string name="alu_sub_seq"); super.new(name); endfunction
  virtual task body();
    repeat (`NUM_SEQ) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {cmd==4'b0001; mode==1; inp_valid==2'b11; ce==1;}) 
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

class alu_add_cin_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_add_cin_seq)
  function new(string name="alu_add_cin_seq"); super.new(name); endfunction
  virtual task body();
    repeat (`NUM_SEQ) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {cmd==4'b0010; mode==1; inp_valid==2'b11; ce==1;}) 
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

class alu_sub_cin_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_sub_cin_seq)
  function new(string name="alu_sub_cin_seq"); super.new(name); endfunction
  virtual task body();
    repeat (`NUM_SEQ) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {cmd==4'b0011; mode==1; inp_valid==2'b11; ce==1;}) 
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

class alu_inc_a_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_inc_a_seq)
  function new(string name="alu_inc_a_seq"); super.new(name); endfunction
  virtual task body();
    repeat (`NUM_SEQ) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {cmd==4'b0100; mode==1; inp_valid==2'b11; ce==1;}) 
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

class alu_dec_a_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_dec_a_seq)
  function new(string name="alu_dec_a_seq"); super.new(name); endfunction
  virtual task body();
    repeat (`NUM_SEQ) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {cmd==4'b0101; mode==1; inp_valid==2'b11; ce==1;}) 
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

class alu_inc_b_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_inc_b_seq)
  function new(string name="alu_inc_b_seq"); super.new(name); endfunction
  virtual task body();
    repeat (`NUM_SEQ) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {cmd==4'b0110; mode==1; inp_valid==2'b11; ce==1;}) 
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

class alu_dec_b_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_dec_b_seq)
  function new(string name="alu_dec_b_seq"); super.new(name); endfunction
  virtual task body();
    repeat (`NUM_SEQ) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {cmd==4'b0111; mode==1; inp_valid==2'b11; ce==1;}) 
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

class alu_cmp_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_cmp_seq)
  function new(string name="alu_cmp_seq"); super.new(name); endfunction
  virtual task body();
    repeat (`NUM_SEQ) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {cmd==4'b1000; mode==1; inp_valid==2'b11; ce==1;}) 
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

class alu_mul_inc_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_mul_inc_seq)
  function new(string name="alu_mul_inc_seq"); super.new(name); endfunction
  virtual task body();
    repeat (`NUM_SEQ) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {cmd==4'b1001; mode==1; inp_valid==2'b11; ce==1;}) 
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

class alu_mul_shl_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_mul_shl_seq)
  function new(string name="alu_mul_shl_seq"); super.new(name); endfunction
  virtual task body();
    repeat (`NUM_SEQ) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {cmd==4'b1010; mode==1; inp_valid==2'b11; ce==1;}) 
        `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

// --- Logical Sequences (Mode 0) ---

class alu_logic_basic_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_logic_basic_seq)
  function new(string name="alu_logic_basic_seq"); super.new(name); endfunction
  virtual task body();
    int i;
    for (i = 0; i <= 11; i++) begin
      repeat (`NUM_SEQ) begin
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {cmd==i; mode==0; inp_valid==2'b11; ce==1;}) 
          `uvm_error("SEQ", "Randomization failed")
        finish_item(req);
      end
    end
  endtask
endclass

class alu_logic_shift_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_logic_shift_seq)
  function new(string name="alu_logic_shift_seq"); super.new(name); endfunction
  virtual task body();
    int i;
    for (i = 8; i <= 11; i++) begin
      repeat (`NUM_SEQ) begin
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {cmd==i; mode==0; inp_valid==2'b11; ce==1;}) 
          `uvm_error("SEQ", "Randomization failed")
        finish_item(req);
      end
    end
  endtask
endclass

class alu_logic_rotate_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_logic_rotate_seq)
  function new(string name="alu_logic_rotate_seq"); super.new(name); endfunction
  virtual task body();
    int i;
    for (i = 12; i <= 13; i++) begin
      repeat (`NUM_SEQ) begin
        req = alu_seq_item::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {cmd==i; mode==0; inp_valid==2'b11; ce==1;}) 
          `uvm_error("SEQ", "Randomization failed")
        finish_item(req);
      end
    end
  endtask
endclass

// --- Wait Cycle Sequence ---
class alu_wait_cycle_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_wait_cycle_seq)
  
  function new(string name="alu_wait_cycle_seq"); 
    super.new(name); 
  endfunction

  virtual task body();
    repeat(`NUM_SEQ)begin
    	req=alu_seq_item::type_id::create("req");
    	start_item(req);
    	if (!req.randomize() with {cmd==0; mode==1; inp_valid==2'b01; ce==1;}) 
          `uvm_error("SEQ", "Randomization failed")
        finish_item(req);
        repeat(10)begin
        	start_item(req);
        	finish_item(req);
        end
        start_item(req);
    	if (!req.randomize() with {cmd==0; mode==1; inp_valid==2'b10; ce==1;}) 
          `uvm_error("SEQ", "Randomization failed")
        finish_item(req);
        start_item(req);
    	if (!req.randomize() with {cmd==0; mode==1; inp_valid==2'b00; ce==1;}) 
          `uvm_error("SEQ", "Randomization failed")
        finish_item(req);
    end
  endtask
endclass
