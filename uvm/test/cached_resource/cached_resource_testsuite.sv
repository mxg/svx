module cached_resource_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "cached_resource_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  cached_resource_unit_test cached_resource_ut();


  //===================================
  // Build
  //===================================
  function void build();
    cached_resource_ut.build();
    cached_resource_ut.__register_tests();
    svunit_ts = new(name);
    svunit_ts.add_testcase(cached_resource_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    cached_resource_ut.run();
    svunit_ts.report();
  endtask

endmodule
