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

`include "svunit_defines.svh"

//----------------------------------------------------------------------
// plugins_unit_test
//
// Unit tests for plugins.  plugins::install() reads every +plugin
// value in the resource database, and the resource database is
// global, so this is the only test file that puts +plugin values on a
// command line.  The tests run in order: the first checks that
// nothing is installed when there are no plugins, the second parses
// a command line with plugins and installs them.
//----------------------------------------------------------------------

`include "uvm_macros.svh"

//----------------------------------------------------------------------
// plugins_ut_pkg
//
// Plugin components for the tests.  The factory registers them under
// their type names, which are what +plugin names.
//----------------------------------------------------------------------
package plugins_ut_pkg;
  import uvm_pkg::*;

  class svx_ut_plugin_a extends uvm_component;
    `uvm_component_utils(svx_ut_plugin_a)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class svx_ut_plugin_b extends uvm_component;
    `uvm_component_utils(svx_ut_plugin_b)
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass
endpackage

module plugins_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import uvm_pkg::*;
  import svx::*;
  import svx_uvm_pkg::*;
  import plugins_ut_pkg::*;
 `include "svx_macros.svh"

  string name = "plugins_ut";
  svunit_testcase svunit_ut;

  //--------------------------------------------------------------------
  // plugin_catcher
  //
  // Count and swallow messages from plugins, the command line parser,
  // and the factory's warning about an unregistered type.
  //--------------------------------------------------------------------
  class plugin_catcher extends uvm_report_catcher;

    int unsigned n_plugin_errors;
    int unsigned n_cl_errors;
    int unsigned n_plugin_infos;

    function new(string name = "plugin_catcher");
      super.new(name);
    endfunction

    function void clear();
      n_plugin_errors = 0;
      n_cl_errors = 0;
      n_plugin_infos = 0;
    endfunction

    function action_e catch();
      string id = get_id();
      if(id == "SVX/PLUGIN") begin
        if(get_severity() == UVM_ERROR) n_plugin_errors++;
        if(get_severity() == UVM_INFO)  n_plugin_infos++;
        return CAUGHT;
      end
      if(id == SVX_CL_MSG_ID && get_severity() == UVM_ERROR) begin
        n_cl_errors++;
        return CAUGHT;
      end
      if(id == "BDTYP")
        return CAUGHT;
      return THROW;
    endfunction

  endclass

  plugin_catcher catcher;

  //--------------------------------------------------------------------
  // count_plugins
  //
  // The number of children of uvm_top whose names start with
  // "svx_ut_plugin_".
  //--------------------------------------------------------------------
  function automatic int count_plugins();
    uvm_component children[$];
    int n;
    uvm_top.get_children(children);
    foreach(children[i]) begin
      string cn = children[i].get_name();
      if(cn.len() >= 14 && cn.substr(0, 13) == "svx_ut_plugin_")
        n++;
    end
    return n;
  endfunction

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
    catcher = new();
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    // Catchers are global and are consulted in the order they were
    // added, so each test file's catcher is active only during its
    // own tests.
    uvm_report_cb::add(null, catcher);
    catcher.clear();
  endtask


  //===================================
  // Here we deconstruct anything we
  // need after running the Unit Tests
  //===================================
  task teardown();
    uvm_report_cb::delete(null, catcher);
    svunit_ut.teardown();
  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //===================================
  `SVUNIT_TESTS_BEGIN

  //--------------------------------------------------------------------
  // no_plugins
  //
  // With no +plugin on the command line, install() creates nothing
  // and reports no errors.
  //--------------------------------------------------------------------
    `SVTEST(no_plugins)
      plugins::install();
      `FAIL_UNLESS(catcher.n_plugin_errors == 0)
      `FAIL_UNLESS(count_plugins() == 0)
    `SVTEST_END

  //--------------------------------------------------------------------
  // install_plugins
  //
  // +plugin may be repeated.  Each registered type is created under
  // uvm_top with its type name as its instance name; a type the
  // factory does not know is an error.
  //--------------------------------------------------------------------
    `SVTEST(install_plugins)
      cl_parse p;
      uvm_component c;
      svx_ut_plugin_a pa;
      svx_ut_plugin_b pb;

      cl_mgr::clr_parse_flag();
      p = cl_parse::get();
      p.set_args({"Vtestrunner",
                  "+plugin=svx_ut_plugin_a",
                  "+plugin=svx_ut_plugin_b",
                  "+plugin=svx_ut_no_such_plugin"});
      p.parse();
      `FAIL_UNLESS(catcher.n_cl_errors == 0)

      plugins::install();
      `FAIL_UNLESS(catcher.n_plugin_errors == 1)
      `FAIL_UNLESS(count_plugins() == 2)
      c = uvm_top.lookup("svx_ut_plugin_a");
      `FAIL_UNLESS($cast(pa, c))
      c = uvm_top.lookup("svx_ut_plugin_b");
      `FAIL_UNLESS($cast(pb, c))
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
