//======================================================================
//
//               .oooooo..o oooooo     oooo ooooooo  ooooo     
//              d8P'    `Y8  `888.     .8'   `8888    d8'      
//              Y88bo.        `888.   .8'      Y888..8P        
//               `"Y8888o.     `888. .8'        `8888'         
//                   `"Y88b     `888.8'        .8PY888.        
//              oo     .d8P      `888'        d8'  `888b       
//              8""88888P'        `8'       o888o  o88888o
//
//                  SystemVerilog Extension Library
//
//
// Copyright 2026 Mark Glasser
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
// implied.  See the License for the specific language governing
// permissions and limitations under the License.
//======================================================================

//----------------------------------------------------------------------
// testrunner
//----------------------------------------------------------------------
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
