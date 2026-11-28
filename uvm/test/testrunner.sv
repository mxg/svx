
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
  agreement_testsuite agreement_ts();
  cached_resource_testsuite cached_resource_ts();
  cl_testsuite cl_ts();
  plugins_testsuite plugins_ts();
  sqr_aggregator_testsuite sqr_aggregator_ts();


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
    agreement_ts.build();
    svunit_tr.add_testsuite(agreement_ts.svunit_ts);
    cached_resource_ts.build();
    svunit_tr.add_testsuite(cached_resource_ts.svunit_ts);
    cl_ts.build();
    svunit_tr.add_testsuite(cl_ts.svunit_ts);
    plugins_ts.build();
    svunit_tr.add_testsuite(plugins_ts.svunit_ts);
    sqr_aggregator_ts.build();
    svunit_tr.add_testsuite(sqr_aggregator_ts.svunit_ts);
  endfunction


  //===================================
  // Run
  //===================================
  task run();
    agreement_ts.run();
    cached_resource_ts.run();
    cl_ts.run();
    plugins_ts.run();
    sqr_aggregator_ts.run();
    svunit_tr.report();
  endtask


endmodule
