
module testrunner();
  import svunit_pkg::svunit_testrunner;
`ifdef RUN_SVUNIT_WITH_UVM
  import uvm_pkg::*;
  import svunit_uvm_mock_pkg::svunit_uvm_test_inst;
  import svunit_uvm_mock_pkg::uvm_report_mock;
`endif

  string name = "testrunner";
  svunit_testrunner svunit_tr;


  //==================================
  // These are the test suites that we
  // want included in this testrunner
  //==================================
//  apps_testsuite apps_ts();
  behaviors_testsuite behaviors_ts();
  containers_testsuite containers_ts();
  iterators_testsuite iterators_ts();
  lexer_testsuite lexer_ts();
  linked_testsuite linked_ts();


  //===================================
  // Main
  //===================================
  initial
  begin

    `ifdef RUN_SVUNIT_WITH_UVM_REPORT_MOCK
      uvm_report_cb::add(null, uvm_report_mock::reports);
    `endif

    build();

    `ifdef RUN_SVUNIT_WITH_UVM
      svunit_uvm_test_inst("svunit_uvm_test");
    `endif

    run();
    $finish();
  end


  //===================================
  // Build
  //===================================
  function void build();
    svunit_tr = new(name);
//    apps_ts.build();
//    svunit_tr.add_testsuite(apps_ts.svunit_ts);
    behaviors_ts.build();
    svunit_tr.add_testsuite(behaviors_ts.svunit_ts);
    containers_ts.build();
    svunit_tr.add_testsuite(containers_ts.svunit_ts);
    iterators_ts.build();
    svunit_tr.add_testsuite(iterators_ts.svunit_ts);
    lexer_ts.build();
    svunit_tr.add_testsuite(lexer_ts.svunit_ts);
    linked_ts.build();
    svunit_tr.add_testsuite(linked_ts.svunit_ts);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
//    apps_ts.run();
    behaviors_ts.run();
    containers_ts.run();
    iterators_ts.run();
    lexer_ts.run();
    linked_ts.run();
    svunit_tr.report();
  endtask


endmodule
