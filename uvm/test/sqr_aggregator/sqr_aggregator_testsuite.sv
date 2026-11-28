module sqr_aggregator_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "sqr_aggregator_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  sqr_aggregator_unit_test sqr_aggregator_ut();


  //===================================
  // Build
  //===================================
  function void build();
    sqr_aggregator_ut.build();
    sqr_aggregator_ut.__register_tests();
    svunit_ts = new(name);
    svunit_ts.add_testcase(sqr_aggregator_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    sqr_aggregator_ut.run();
    svunit_ts.report();
  endtask

endmodule
