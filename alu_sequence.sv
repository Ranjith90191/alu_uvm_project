// ============================================================
// alu_base_sequence.sv
// ============================================================
class alu_base_sequence extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_base_sequence)

  function new(string name = "alu_base_sequence");
    super.new(name);
  endfunction

  virtual task body();
    repeat (`NUM_SEQ) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {cmd==0; mode==1; inp_valid==2'b11; ce==1;}) begin
        `uvm_error("ALU_SEQ", "Randomization failed")
      end
      finish_item(req);
    end
  endtask

endclass