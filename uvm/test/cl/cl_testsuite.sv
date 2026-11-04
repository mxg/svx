module cl_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "cl_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  cl_parse_unit_test cl_parse_ut();


  //===================================
  // Build
  //===================================
  function void build();
    cl_parse_ut.build();
    cl_parse_ut.__register_tests();
    svunit_ts = new(name);
    svunit_ts.add_testcase(cl_parse_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    cl_parse_ut.run();
    svunit_ts.report();
  endtask

endmodule
