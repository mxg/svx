
class test extends uvm_component;

  `uvm_component_utils(test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    uvm_root root = uvm_root::get();
    root.set_enable_print_topology (1);
  endfunction

endclass
