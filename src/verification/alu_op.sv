`ifndef ALU_OP_SV
`define ALU_OP_SV

typedef enum bit [`CW-1:0] {
  OP_ADD      = 4'b0000,
  OP_SUB      = 4'b0001,
  OP_ADD_CIN  = 4'b0010,
  OP_SUB_CIN  = 4'b0011,
  OP_INC_A    = 4'b0100,
  OP_DEC_A    = 4'b0101,
  OP_INC_B    = 4'b0110,
  OP_DEC_B    = 4'b0111,
  OP_CMP      = 4'b1000,
  OP_MUL_INC  = 4'b1001,
  OP_MUL_SHL  = 4'b1010
} alu_arith_op_e;

typedef enum bit [`CW-1:0] {
  OP_AND      = 4'b0000,
  OP_NAND     = 4'b0001,
  OP_OR       = 4'b0010,
  OP_NOR      = 4'b0011,
  OP_XOR      = 4'b0100,
  OP_XNOR     = 4'b0101,
  OP_NOT_A    = 4'b0110,
  OP_NOT_B    = 4'b0111,
  OP_SHR1_A   = 4'b1000,
  OP_SHL1_A   = 4'b1001,
  OP_SHR1_B   = 4'b1010,
  OP_SHL1_B   = 4'b1011,
  OP_ROL_A_B  = 4'b1100,
  OP_ROR_A_B  = 4'b1101
} alu_logic_op_e;

typedef enum bit [1:0] {
  IV_CLEAR  = 2'b00,
  IV_A_ONLY = 2'b01,
  IV_B_ONLY = 2'b10,
  IV_BOTH   = 2'b11
} alu_inp_valid_e;

`endif
