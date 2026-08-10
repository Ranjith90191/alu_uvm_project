
`ifndef ALU_COVERAGE_SV
`define ALU_COVERAGE_SV

class alu_coverage extends uvm_subscriber #(alu_seq_item);
  `uvm_component_utils(alu_coverage)

  alu_seq_item req;

  covergroup alu_input_cg;
    option.per_instance = 1;
    option.name = "ALU_Input_Coverage";

    cp_mode: coverpoint req.mode {
      bins arithmetic = {1'b1};
      bins logical    = {1'b0};
    }

    cp_arith_cmd: coverpoint req.cmd iff (req.mode == 1'b1) {
      bins add     = {4'b0000};
      bins sub     = {4'b0001};
      bins add_cin = {4'b0010};
      bins sub_cin = {4'b0011};
      bins inc_a   = {4'b0100};
      bins dec_a   = {4'b0101};
      bins inc_b   = {4'b0110};
      bins dec_b   = {4'b0111};
      bins cmp     = {4'b1000};
      bins mul_inc = {4'b1001};
      bins mul_shl = {4'b1010};
      ignore_bins unused = {[4'b1011:4'b1111]};
    }

    cp_logic_cmd: coverpoint req.cmd iff (req.mode == 1'b0) {
      bins op_and    = {4'b0000};
      bins op_nand   = {4'b0001};
      bins op_or     = {4'b0010};
      bins op_nor    = {4'b0011};
      bins op_xor    = {4'b0100};
      bins op_xnor   = {4'b0101};
      bins op_not_a  = {4'b0110};
      bins op_not_b  = {4'b0111};
      bins op_shr1_a = {4'b1000};
      bins op_shl1_a = {4'b1001};
      bins op_shr1_b = {4'b1010};
      bins op_shl1_b = {4'b1011};
      bins op_rol    = {4'b1100};
      bins op_ror    = {4'b1101};
      ignore_bins unused = {4'b1110, 4'b1111};
    }

    cp_inp_valid: coverpoint req.inp_valid {
      bins clear    = {2'b00};
      bins cap_a    = {2'b01};
      bins cap_b    = {2'b10};
      bins cap_both = {2'b11};
    }

    cp_cin: coverpoint req.cin {
      bins cin_0 = {1'b0};
      bins cin_1 = {1'b1};
    }

    cp_opa: coverpoint req.OA {
      bins all_zeros = {8'h00};
      bins all_ones  = {8'hFF};
      bins others    = {[8'h01:8'hFE]};
    }


    cp_opb: coverpoint req.OB {
      bins all_zeros = {8'h00};
      bins all_ones  = {8'hFF};
      bins others    = {[8'h01:8'hFE]};
    }

    cp_rot_err_cond: coverpoint req.OB[7:4] iff (req.mode == 1'b0 && (req.cmd == 4'b1100 || req.cmd == 4'b1101)) {
      bins valid_rotation = {4'h0};
      bins error_rotation = {[4'h1:4'hF]};
    }

    cr_arith_cin: cross cp_arith_cmd, cp_cin;

    cr_valid_mode: cross cp_inp_valid, cp_mode;

  endgroup

  function new(string name = "alu_coverage", uvm_component parent = null);
    super.new(name, parent);
    alu_input_cg = new();
  endfunction

  virtual function void write(alu_seq_item t);
    req = t;
    if (req.ce && !req.rst) begin
      alu_input_cg.sample();
    end
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV", $sformatf("ALU Input Coverage: %0.2f%%", alu_input_cg.get_coverage()), UVM_NONE);
  endfunction

endclass

`endif
