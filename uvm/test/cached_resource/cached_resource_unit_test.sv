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
// cached_resource_unit_test
//
// Unit tests for the cached resource.  Each test publishes its own
// uint32_t resources with fresh names (cr_1, cr_2, ...) so tests do
// not see one another's resources.  Waiters run in separate processes
// and record when, and how many times, wait_for_change() returned.
//----------------------------------------------------------------------

module cached_resource_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import uvm_pkg::*;
  import svx::*;
  import svx_uvm_pkg::*;
 `include "svx_macros.svh"

  string name = "cached_resource_ut";
  svunit_testcase svunit_ut;

  typedef cached_resource#(uint32_t) cr_t;

  // Scope used for lookups.  Resources are published with scope "*",
  // so any lookup scope finds them.
  localparam string SCOPE = "cached_resource_ut";

  //--------------------------------------------------------------------
  // cr_catcher
  //
  // Count and swallow the cached resource's errors.
  //--------------------------------------------------------------------
  class cr_catcher extends uvm_report_catcher;

    int unsigned n_errors;

    function new(string name = "cr_catcher");
      super.new(name);
    endfunction

    function action_e catch();
      string id = get_id();
      if(get_severity() == UVM_ERROR &&
         id.len() >= 15 && id.substr(0, 14) == "SVX/CACHED_RSRC") begin
        n_errors++;
        return CAUGHT;
      end
      return THROW;
    endfunction

  endclass

  //--------------------------------------------------------------------
  // waiter
  //
  // Call wait_for_change() repeatedly in a separate process.  Records
  // the number of times it returned and the time of the first return.
  //--------------------------------------------------------------------
  class waiter;
    int unsigned n_wakes;
    time first_wake;

    function bit released();
      return (n_wakes > 0);
    endfunction

    function void start(cr_t cr);
      fork
        forever begin
          cr.wait_for_change();
          if(n_wakes == 0)
            first_wake = $time;
          n_wakes++;
        end
      join_none
    endfunction
  endclass

  cr_catcher catcher;
  int unsigned rsrc_count;

  //--------------------------------------------------------------------
  // new_name
  //
  // A fresh resource name for each test.
  //--------------------------------------------------------------------
  function automatic string new_name();
    rsrc_count++;
    return $sformatf("cr_%0d", rsrc_count);
  endfunction

  //--------------------------------------------------------------------
  // publish
  //
  // Put a new uint32_t resource with a fresh name into the resource
  // database and return the name.
  //--------------------------------------------------------------------
  function automatic string publish(uint32_t val);
    string n = new_name();
    uvm_resource_db#(uint32_t)::set("*", n, val);
    return n;
  endfunction

  //--------------------------------------------------------------------
  // value_of
  //
  // Read a cached resource; returns 'hdeadbeef if the read fails.
  //--------------------------------------------------------------------
  function automatic uint32_t value_of(cr_t cr);
    uint32_t v;
    if(!cr.read(v, null))
      return 'hdeadbeef;
    return v;
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
    catcher.n_errors = 0;
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
  // bind_at_construction
  //--------------------------------------------------------------------
    `SVTEST(bind_at_construction)
      string n = publish(5);
      cr_t cr = new(SCOPE, n);

      `FAIL_IF(cr.is_empty())
      `FAIL_UNLESS(value_of(cr) == 5)
      `FAIL_UNLESS(catcher.n_errors == 0)
    `SVTEST_END

  //--------------------------------------------------------------------
  // not_found
  //
  // Binding to a resource that does not exist is an error, and every
  // operation on the empty cache reports an error.  wait_for_change()
  // must return rather than block.
  //--------------------------------------------------------------------
    `SVTEST(not_found)
      string n = new_name();
      cr_t cr = new(SCOPE, n);
      uint32_t v;
      time t0 = $time;

      `FAIL_UNLESS(cr.is_empty())
      `FAIL_UNLESS(catcher.n_errors == 1)
      `FAIL_IF(cr.read(v, null))
      `FAIL_UNLESS(catcher.n_errors == 2)
      cr.write(3, null);
      `FAIL_UNLESS(catcher.n_errors == 3)
      cr.wait_for_change();
      `FAIL_UNLESS($time == t0)
      `FAIL_UNLESS(catcher.n_errors == 4)
      `FAIL_IF(cr.get_the_latest(v))
      `FAIL_UNLESS(catcher.n_errors == 5)
    `SVTEST_END

  //--------------------------------------------------------------------
  // late_binding
  //
  // With leave_unbound set, construction does not look the resource
  // up; refresh() binds once the resource exists.
  //--------------------------------------------------------------------
    `SVTEST(late_binding)
      string n = new_name();
      cr_t cr = new(SCOPE, n, 1);

      `FAIL_UNLESS(cr.is_empty())
      `FAIL_UNLESS(catcher.n_errors == 0)
      uvm_resource_db#(uint32_t)::set("*", n, 11);
      cr.refresh();
      `FAIL_IF(cr.is_empty())
      `FAIL_UNLESS(value_of(cr) == 11)
      `FAIL_UNLESS(catcher.n_errors == 0)
    `SVTEST_END

  //--------------------------------------------------------------------
  // shared_value
  //
  // Cached resources bound to the same resource share its value.
  //--------------------------------------------------------------------
    `SVTEST(shared_value)
      string n = publish(1);
      cr_t cr1 = new(SCOPE, n);
      cr_t cr2 = new(SCOPE, n);
      uint32_t v;

      cr1.write(42, null);
      `FAIL_UNLESS(value_of(cr2) == 42)
      `FAIL_UNLESS(uvm_resource_db#(uint32_t)::read_by_name(SCOPE, n, v))
      `FAIL_UNLESS(v == 42)
    `SVTEST_END

  //--------------------------------------------------------------------
  // no_crosstalk
  //
  // Two resources of the same type are cached independently.
  //--------------------------------------------------------------------
    `SVTEST(no_crosstalk)
      string na = publish(1);
      string nb = publish(2);
      cr_t cra = new(SCOPE, na);
      cr_t crb = new(SCOPE, nb);

      `FAIL_UNLESS(value_of(cra) == 1)
      `FAIL_UNLESS(value_of(crb) == 2)
      cra.write(10, null);
      `FAIL_UNLESS(value_of(crb) == 2)
    `SVTEST_END

  //--------------------------------------------------------------------
  // stays_bound_until_refresh
  //
  // A higher-precedence resource added later is not seen until
  // get_the_latest() or refresh() repeats the lookup.
  //--------------------------------------------------------------------
    `SVTEST(stays_bound_until_refresh)
      string n = publish(1);
      cr_t cr1 = new(SCOPE, n);
      cr_t cr2 = new(SCOPE, n);
      uint32_t v;

      uvm_resource_db#(uint32_t)::set_override("*", n, 2);
      `FAIL_UNLESS(value_of(cr1) == 1)
      `FAIL_UNLESS(cr1.get_the_latest(v))
      `FAIL_UNLESS(v == 2)
      `FAIL_UNLESS(value_of(cr1) == 2)

      `FAIL_UNLESS(value_of(cr2) == 1)
      cr2.refresh();
      `FAIL_UNLESS(value_of(cr2) == 2)
      `FAIL_UNLESS(catcher.n_errors == 0)
    `SVTEST_END

  //--------------------------------------------------------------------
  // read_only
  //
  // Writing a read-only resource is an error, changes nothing, and
  // wakes no one.
  //--------------------------------------------------------------------
    `SVTEST(read_only)
      string n = publish(7);
      uvm_resource#(uint32_t) r = uvm_resource_db#(uint32_t)::get_by_name(SCOPE, n);
      cr_t cr = new(SCOPE, n);
      cr_t crw = new(SCOPE, n);
      waiter w = new();

      r.set_read_only();
      w.start(cr);
      #1;
      crw.write(8, null);
      #5;
      `FAIL_UNLESS(catcher.n_errors == 1)
      `FAIL_UNLESS(value_of(cr) == 7)
      `FAIL_IF(w.released())
    `SVTEST_END

  //--------------------------------------------------------------------
  // wait_released_by_write
  //--------------------------------------------------------------------
    `SVTEST(wait_released_by_write)
      string n = publish(0);
      cr_t cr = new(SCOPE, n);
      cr_t crw = new(SCOPE, n);
      waiter w = new();
      time t0 = $time;

      w.start(cr);
      #5;
      `FAIL_IF(w.released())
      crw.write(1, null);
      #1;
      `FAIL_UNLESS(w.n_wakes == 1)
      `FAIL_UNLESS(w.first_wake == t0 + 5)
      `FAIL_UNLESS(value_of(cr) == 1)
    `SVTEST_END

  //--------------------------------------------------------------------
  // same_value_no_wake
  //--------------------------------------------------------------------
    `SVTEST(same_value_no_wake)
      string n = publish(3);
      cr_t cr = new(SCOPE, n);
      cr_t crw = new(SCOPE, n);
      waiter w = new();

      w.start(cr);
      #1;
      crw.write(3, null);
      #5;
      `FAIL_IF(w.released())
    `SVTEST_END

  //--------------------------------------------------------------------
  // broadcast
  //
  // Every waiter on a resource is released by one write.
  //--------------------------------------------------------------------
    `SVTEST(broadcast)
      string n = publish(0);
      cr_t crw = new(SCOPE, n);
      cr_t cr[3];
      waiter w[3];
      time t0 = $time;

      foreach(cr[i]) begin
        cr[i] = new(SCOPE, n);
        w[i] = new();
        w[i].start(cr[i]);
      end
      #2;
      crw.write(9, null);
      #1;
      foreach(w[i]) begin
        `FAIL_UNLESS(w[i].n_wakes == 1)
        `FAIL_UNLESS(w[i].first_wake == t0 + 2)
      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // writes_in_one_time_step
  //
  // Several writes in one time step are seen as one change, and the
  // waiter reads the last value written.
  //--------------------------------------------------------------------
    `SVTEST(writes_in_one_time_step)
      string n = publish(0);
      cr_t cr = new(SCOPE, n);
      cr_t crw = new(SCOPE, n);
      waiter w = new();

      w.start(cr);
      #2;
      crw.write(1, null);
      #0;
      crw.write(2, null);
      #0;
      crw.write(3, null);
      #1;
      `FAIL_UNLESS(w.n_wakes == 1)
      `FAIL_UNLESS(value_of(cr) == 3)
    `SVTEST_END

  //--------------------------------------------------------------------
  // change_while_busy
  //
  // A change made while the reader was not waiting is not lost: the
  // next wait_for_change() returns in the same time step.
  //--------------------------------------------------------------------
    `SVTEST(change_while_busy)
      string n = publish(0);
      cr_t cr = new(SCOPE, n);
      cr_t crw = new(SCOPE, n);
      time t0;

      #1;
      crw.write(5, null);
      #3;
      t0 = $time;
      cr.wait_for_change();
      `FAIL_UNLESS($time == t0)
      `FAIL_UNLESS(value_of(cr) == 5)
    `SVTEST_END

  //--------------------------------------------------------------------
  // read_catches_up
  //
  // A reader that has read the new value does not get a wakeup for
  // it later.
  //--------------------------------------------------------------------
    `SVTEST(read_catches_up)
      string n = publish(0);
      cr_t cr = new(SCOPE, n);
      cr_t crw = new(SCOPE, n);
      waiter w = new();

      crw.write(5, null);
      `FAIL_UNLESS(value_of(cr) == 5)
      w.start(cr);
      #5;
      `FAIL_IF(w.released())
    `SVTEST_END

  //--------------------------------------------------------------------
  // resource_db_write_no_wake
  //
  // A write made through uvm_resource_db changes the value but does
  // not release waiters.
  //--------------------------------------------------------------------
    `SVTEST(resource_db_write_no_wake)
      string n = publish(0);
      cr_t cr = new(SCOPE, n);
      waiter w = new();

      w.start(cr);
      #1;
      void'(uvm_resource_db#(uint32_t)::write_by_name(SCOPE, n, 77));
      #5;
      `FAIL_IF(w.released())
      `FAIL_UNLESS(value_of(cr) == 77)
    `SVTEST_END

  //--------------------------------------------------------------------
  // own_write_no_wake
  //
  // A write marks the writer as having seen the change: the writing
  // instance does not wake itself, but other instances do wake.
  //--------------------------------------------------------------------
    `SVTEST(own_write_no_wake)
      string n = publish(0);
      cr_t crw = new(SCOPE, n);
      cr_t cr = new(SCOPE, n);
      waiter w_self = new();
      waiter w_other = new();

      crw.write(4, null);
      w_self.start(crw);
      w_other.start(cr);
      #5;
      `FAIL_IF(w_self.released())
      `FAIL_UNLESS(w_other.n_wakes == 1)
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
