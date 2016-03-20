module iterators_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "iterators_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  list_iterators_unit_test list_iterators_ut();
  map_iterators_unit_test map_iterators_ut();
  permute_iterator_unit_test permute_iterator_ut();


  //===================================
  // Build
  //===================================
  function void build();
    list_iterators_ut.build();
    map_iterators_ut.build();
    permute_iterator_ut.build();
    svunit_ts = new(name);
    svunit_ts.add_testcase(list_iterators_ut.svunit_ut);
    svunit_ts.add_testcase(map_iterators_ut.svunit_ut);
    svunit_ts.add_testcase(permute_iterator_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    list_iterators_ut.run();
    map_iterators_ut.run();
    permute_iterator_ut.run();
    svunit_ts.report();
  endtask

endmodule
