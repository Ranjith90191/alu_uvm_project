// ============================================================
// alu_if.sv
// ============================================================
`include "alu_defines.svh"

interface alu_if(input logic clk);
  logic [`DW-1:0] OA;
  logic [`DW-1:0] OB;
  logic mode;
  logic cin;
  logic [`CW-1:0] cmd;
  logic rst, ce;
  logic [1:0] inp_valid;

  logic [2*`DW-1:0] res;
  logic cout, oflow, G, L, E, err;

  // rst intentionally excluded from both clocking blocks -- it's driven
  // directly by alu_top (async, outside clocking discipline) and only
  // ever read here via the modports' plain 'input rst'. Previously it
  // was both a drv_cb output AND a modport-level input -- a conflict
  // that silently made the driver's rst writes dead.
  clocking drv_cb @(posedge clk);
    default input #1 output #1;
    output OA, OB, mode, cmd, cin, inp_valid, ce;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1 output #1;
    input OA, OB, mode, cmd, ce, cin, inp_valid, res, cout, oflow, G, L, E, err;
  endclocking

  modport DRV(clocking drv_cb, input rst);
  modport MON(clocking mon_cb, input rst);

endinterface