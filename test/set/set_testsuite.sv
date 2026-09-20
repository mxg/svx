module set_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "set_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  set_unit_test set_ut();


  //===================================
  // Build
  //===================================
  function void build();
    set_ut.build();
    set_ut.__register_tests();
    svunit_ts = new(name);
    svunit_ts.add_testcase(set_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    set_ut.run();
    svunit_ts.report();
  endtask

endmodule
