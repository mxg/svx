module plugins_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "plugins_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  plugins_unit_test plugins_ut();


  //===================================
  // Build
  //===================================
  function void build();
    plugins_ut.build();
    plugins_ut.__register_tests();
    svunit_ts = new(name);
    svunit_ts.add_testcase(plugins_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    plugins_ut.run();
    svunit_ts.report();
  endtask

endmodule
