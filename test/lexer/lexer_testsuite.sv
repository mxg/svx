module lexer_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "lexer_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  ctypes_unit_test ctypes_ut();
  lexer_core_unit_test lexer_core_ut();


  //===================================
  // Build
  //===================================
  function void build();
    ctypes_ut.build();
    lexer_core_ut.build();
    svunit_ts = new(name);
    svunit_ts.add_testcase(ctypes_ut.svunit_ut);
    svunit_ts.add_testcase(lexer_core_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    ctypes_ut.run();
    lexer_core_ut.run();
    svunit_ts.report();
  endtask

endmodule
