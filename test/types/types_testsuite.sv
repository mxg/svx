module types_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "types_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  type_handle_unit_test type_handle_ut();
  type_match_unit_test type_match_ut();
  typeid_unit_test typeid_ut();


  //===================================
  // Build
  //===================================
  function void build();
    type_handle_ut.build();
    type_handle_ut.__register_tests();
    type_match_ut.build();
    type_match_ut.__register_tests();
    typeid_ut.build();
    typeid_ut.__register_tests();
    svunit_ts = new(name);
    svunit_ts.add_testcase(type_handle_ut.svunit_ut);
    svunit_ts.add_testcase(type_match_ut.svunit_ut);
    svunit_ts.add_testcase(typeid_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    type_handle_ut.run();
    type_match_ut.run();
    typeid_ut.run();
    svunit_ts.report();
  endtask

endmodule
