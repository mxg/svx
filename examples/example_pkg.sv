package example_pkg;

  /* verilator lint_off IMPORTSTAR */
  `include "svx_macros.svh"
  import svx::*;
  /* verilator lint_on IMPORTSTAR */
  
  virtual class example;

    function void exec();
      setup();
      run();
      show();
    endfunction

    pure virtual function void setup();
    pure virtual function void run();
    pure virtual function void show();
  endclass

endpackage

    
    
