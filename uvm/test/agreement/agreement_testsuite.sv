module agreement_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "agreement_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  agreement_unit_test agreement_ut();


  //===================================
  // Build
  //===================================
  function void build();
    agreement_ut.build();
    agreement_ut.__register_tests();
    svunit_ts = new(name);
    svunit_ts.add_testcase(agreement_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    agreement_ut.run();
    svunit_ts.report();
  endtask

endmodule
