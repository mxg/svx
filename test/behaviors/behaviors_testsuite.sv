module behaviors_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "behaviors_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  behavior_unit_test behavior_ut();
  concurrency_unit_test concurrency_ut();
  mapper_unit_test mapper_ut();


  //===================================
  // Build
  //===================================
  function void build();
    behavior_ut.build();
    concurrency_ut.build();
    mapper_ut.build();
    svunit_ts = new(name);
    svunit_ts.add_testcase(behavior_ut.svunit_ut);
    svunit_ts.add_testcase(concurrency_ut.svunit_ut);
    svunit_ts.add_testcase(mapper_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    behavior_ut.run();
    concurrency_ut.run();
    mapper_ut.run();
    svunit_ts.report();
  endtask

endmodule
