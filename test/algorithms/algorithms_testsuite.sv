module algorithms_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "algorithms_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  algo_unit_test algo_ut();


  //===================================
  // Build
  //===================================
  function void build();
    algo_ut.build();
    algo_ut.__register_tests();
    svunit_ts = new(name);
    svunit_ts.add_testcase(algo_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    algo_ut.run();
    svunit_ts.report();
  endtask

endmodule
