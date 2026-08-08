class alu_output_monitor extends uvm_monitor;
    `uvm_component_utils(alu_output_monitor)

    virtual alu_if.MON vif;
    uvm_analysis_port #(alu_seq_item) output_broadcaster;

    function new(string name="alu_output_monitor", uvm_component parent);
        super.new(name, parent);
        output_broadcaster = new("output_broadcaster", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("ALU_MON", ("Virtual interface not set for: " + get_full_name() + ".vif"));
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        alu_seq_item out_pkt;
        forever begin
            @(vif.mon_cb);
            out_pkt = alu_seq_item::type_id::create("out_pkt");
            out_pkt.res = vif.res;
            out_pkt.cout = vif.cout;
            out_pkt.oflow = vif.oflow;
            out_pkt.G = vif.G;
            out_pkt.L = vif.L;
            out_pkt.E = vif.E;
            out_pkt.err = vif.err;
            `uvm_info("MON", $sformatf("Output: res=%0d cout=%0d oflow=%0d G=%0d L=%0d E=%0d err=%0d", vif.res, vif.cout, vif.oflow, vif.G, vif.L, vif.E, vif.err), UVM_LOW)
            output_broadcaster.write(out_pkt);
        end
    endtask
endclass