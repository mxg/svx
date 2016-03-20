module apps_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "apps_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  mem_unit_test mem_ut();
  mem_field_unit_test mem_field_ut();
  mem_bounded_unit_test mem_bounded_ut();


  //===================================
  // Build
  //===================================
  function void build();
    mem_ut.build();
    mem_field_ut.build();
    mem_bounded_ut.build();
    svunit_ts = new(name);
    svunit_ts.add_testcase(mem_ut.svunit_ut);
    svunit_ts.add_testcase(mem_field_ut.svunit_ut);
    svunit_ts.add_testcase(mem_bounded_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    mem_ut.run();
    mem_field_ut.run();
    mem_bounded_ut.run();
    svunit_ts.report();
  endtask

endmodule
