module linked_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "linked_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  node_unit_test node_ut();
  tree_unit_test tree_ut();
  tree_iterator_unit_test tree_iterator_ut();


  //===================================
  // Build
  //===================================
  function void build();
    node_ut.build();
    tree_ut.build();
    tree_iterator_ut.build();
    svunit_ts = new(name);
    svunit_ts.add_testcase(node_ut.svunit_ut);
    svunit_ts.add_testcase(tree_ut.svunit_ut);
    svunit_ts.add_testcase(tree_iterator_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    node_ut.run();
    tree_ut.run();
    tree_iterator_ut.run();
    svunit_ts.report();
  endtask

endmodule
