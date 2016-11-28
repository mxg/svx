module containers_testsuite;
  import svunit_pkg::svunit_testsuite;

  string name = "containers_ts";
  svunit_testsuite svunit_ts;
  
  
  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  container_unit_test container_ut();
  type_handle_unit_test type_handle_ut();
  vector_unit_test vector_ut();
  map_unit_test map_ut();
  singleton_map_unit_test singleton_map_ut();
  queue_unit_test queue_ut();
  fixed_size_queue_unit_test fixed_size_queue_ut();
  deque_unit_test deque_ut();
  stack_unit_test stack_ut();
  sorter_unit_test sorter_ut();
  dictionary_unit_test dictionary_ut();


  //===================================
  // Build
  //===================================
  function void build();
    container_ut.build();
    type_handle_ut.build();
    vector_ut.build();
    map_ut.build();
    singleton_map_ut.build();
    queue_ut.build();
    fixed_size_queue_ut.build();
    deque_ut.build();
    stack_ut.build();
    sorter_ut.build();
    dictionary_ut.build();
    svunit_ts = new(name);
    svunit_ts.add_testcase(container_ut.svunit_ut);
    svunit_ts.add_testcase(type_handle_ut.svunit_ut);
    svunit_ts.add_testcase(vector_ut.svunit_ut);
    svunit_ts.add_testcase(map_ut.svunit_ut);
    svunit_ts.add_testcase(singleton_map_ut.svunit_ut);
    svunit_ts.add_testcase(queue_ut.svunit_ut);
    svunit_ts.add_testcase(fixed_size_queue_ut.svunit_ut);
    svunit_ts.add_testcase(deque_ut.svunit_ut);
    svunit_ts.add_testcase(stack_ut.svunit_ut);
    svunit_ts.add_testcase(sorter_ut.svunit_ut);
    svunit_ts.add_testcase(dictionary_ut.svunit_ut);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    svunit_ts.run();
    container_ut.run();
    type_handle_ut.run();
    vector_ut.run();
    map_ut.run();
    singleton_map_ut.run();
    queue_ut.run();
    fixed_size_queue_ut.run();
    deque_ut.run();
    stack_ut.run();
    sorter_ut.run();
    dictionary_ut.run();
    svunit_ts.report();
  endtask

endmodule
