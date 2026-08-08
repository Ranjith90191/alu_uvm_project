class alu_base_seq_item extends uvm_sequence_item; ;
    //INPUTS
    rand bit [`DW-1:0] OA;
    rand bit [`DW-1:0] OB;
    rand bit mode;
    rand bit cin;
    rand bit [`CW-1:0] cmd;
    rand bit rst;
    rand bit [1:0] inp_valid;
    rand bit ce;//Tie CE to 1 deafault
    //OUTPUTS  
    logic [2*`DW-1:0] res;
    logic cout,oflow,G,L,E,err;

    //constraint operation_const{cmd==0;mode==1;inp_valid==2'b11;} //Default

    function new(string name = "alu_base_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(alu_base_seq_item)
        `uvm_field_int(OA, UVM_ALL_ON)
        `uvm_field_int(OB, UVM_ALL_ON)
        `uvm_field_int(mode, UVM_ALL_ON)
        `uvm_field_int(cin, UVM_ALL_ON)
        `uvm_field_int(cmd, UVM_ALL_ON)
        `uvm_field_int(rst, UVM_ALL_ON)
        `uvm_field_int(inp_valid, UVM_ALL_ON)
        `uvm_field_int(res, UVM_ALL_ON)
        `uvm_field_int(cout, UVM_ALL_ON)
        `uvm_field_int(oflow, UVM_ALL_ON)
        `uvm_field_int(G, UVM_ALL_ON)
        `uvm_field_int(L, UVM_ALL_ON)  
        `uvm_field_int(E, UVM_ALL_ON)
        `uvm_field_int(err, UVM_ALL_ON)
    `uvm_object_utils_end

endclass