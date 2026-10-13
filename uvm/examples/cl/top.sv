module top;

  `include "uvm_macros.svh"
  `include "svx_macros.svh"  

  import uvm_pkg::*;
  import svx::*;
  import svx_uvm_pkg::*;

  cl_parse clp;

  initial begin
    clp = new();
    clp.parse();
  end

endmodule
