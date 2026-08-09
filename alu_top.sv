// ============================================================
// alu_top.sv
// ============================================================
  `include "alu_defines.svh"
module alu_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import alu_pkg::*;

  logic clk;
  initial clk = 1'b0;
  always #5 clk = ~clk;

  alu_if vif_i (.clk(clk));

  initial begin
    vif_i.rst = 1'b0;
    //repeat (5) @(posedge clk);
    //vif_i.rst = 1'b0;
  end

  ALU_DESIGN #(
    .DW(`DW),
    .CW(`CW)
  ) dut (
    .CLK       (clk),
    .RST       (vif_i.rst),
    .CE        (vif_i.ce),
    .MODE      (vif_i.mode),
    .CIN       (vif_i.cin),
    .CMD       (vif_i.cmd),
    .INP_VALID (vif_i.inp_valid),
    .OPA       (vif_i.OA),
    .OPB       (vif_i.OB),
    .RES       (vif_i.res),
    .COUT      (vif_i.cout),
    .OFLOW     (vif_i.oflow),
    .G         (vif_i.G),
    .E         (vif_i.E),
    .L         (vif_i.L),
    .ERR       (vif_i.err)
  );

  initial begin
    uvm_config_db#(virtual alu_if)::set(null, "*", "vif", vif_i);
  end

  initial begin
    run_test();
  end

endmodule
