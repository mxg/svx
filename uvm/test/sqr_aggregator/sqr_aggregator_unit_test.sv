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
// sqr_aggregator_unit_test
//
// Unit tests for the sequencer aggregator.  Each test creates its own
// aggregator.  Sequencers are real uvm_sequencer objects; they are
// created before run_test() would be called, so no phasing is needed.
// Each sequencer gets a unique name so tests cannot see one another's
// sequencers.
//----------------------------------------------------------------------

module sqr_aggregator_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import uvm_pkg::*;
  import svx::*;
  import svx_uvm_pkg::*;
 `include "svx_macros.svh"

  string name = "sqr_aggregator_ut";
  svunit_testcase svunit_ut;

  typedef uvm_sequencer#(uvm_sequence_item) sqr_t;
  typedef sqr_aggregator::deque_t deque_t;

  //--------------------------------------------------------------------
  // box
  //
  // A component to give sequencers a parent, so they have
  // hierarchical paths for the regular expression tests.
  //--------------------------------------------------------------------
  class box extends uvm_component;
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  //--------------------------------------------------------------------
  // aggr_catcher
  //
  // Count and swallow the aggregator's errors and warnings.
  //--------------------------------------------------------------------
  class aggr_catcher extends uvm_report_catcher;

    int unsigned n_errors;
    int unsigned n_warnings;

    function new(string name = "aggr_catcher");
      super.new(name);
    endfunction

    function void clear();
      n_errors = 0;
      n_warnings = 0;
    endfunction

    function action_e catch();
      if(get_id() != "SVX/SQR_AGGR")
        return THROW;
      case(get_severity())
        UVM_ERROR:   begin n_errors++;   return CAUGHT; end
        UVM_WARNING: begin n_warnings++; return CAUGHT; end
        default:     return THROW;
      endcase
    endfunction

  endclass

  aggr_catcher catcher;
  int unsigned sqr_count;

  //--------------------------------------------------------------------
  // new_sqr
  //
  // Create a sequencer with a unique name under the given parent
  // (null means directly under uvm_top).
  //--------------------------------------------------------------------
  function automatic sqr_t new_sqr(uvm_component parent = null);
    sqr_t s;
    sqr_count++;
    s = new($sformatf("sqr_%0d", sqr_count), parent);
    return s;
  endfunction

  //--------------------------------------------------------------------
  // CHECK_NAME / CHECK_PATH
  //
  // `FAIL_UNLESS stringifies its expression, which breaks on string
  // literals, so look the sequencer up first and compare afterwards.
  //--------------------------------------------------------------------
`define CHECK_NAME(SA, NAME, EXPECTED)          \
  begin                                         \
    uvm_sequencer_base r__ = SA.lookup_name(NAME); \
    `FAIL_UNLESS(r__ == EXPECTED)               \
  end

`define CHECK_PATH(SA, PATH, EXPECTED)          \
  begin                                         \
    uvm_sequencer_base r__ = SA.lookup_path(PATH); \
    `FAIL_UNLESS(r__ == EXPECTED)               \
  end

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
  // lookup_by_name_and_path
  //--------------------------------------------------------------------
    `SVTEST(lookup_by_name_and_path)
      sqr_aggregator sa = new();
      sqr_t s1 = new_sqr();
      sqr_t s2 = new_sqr();

      sa.add(s1, "one", "k");
      sa.add(s2, "two", "k");
      `CHECK_NAME(sa, "one", s1)
      `CHECK_NAME(sa, "two", s2)
      `FAIL_UNLESS(sa.lookup_path(s1.get_full_name()) == s1)
      `FAIL_UNLESS(sa.lookup_path(s2.get_full_name()) == s2)
      `FAIL_UNLESS(catcher.n_errors == 0)
      `FAIL_UNLESS(catcher.n_warnings == 0)
    `SVTEST_END

  //--------------------------------------------------------------------
  // lookup_kind_order
  //
  // Sequencers of one kind come back in the order they were added;
  // other kinds are kept separate.
  //--------------------------------------------------------------------
    `SVTEST(lookup_kind_order)
      sqr_aggregator sa = new();
      sqr_t s1 = new_sqr();
      sqr_t s2 = new_sqr();
      sqr_t s3 = new_sqr();
      deque_t q;

      sa.add(s1, "", "mem");
      sa.add(s2, "", "cfg");
      sa.add(s3, "", "mem");
      q = sa.lookup_kind("mem");
      `FAIL_UNLESS(q.size() == 2)
      `FAIL_UNLESS(q.read(0) == s1)
      `FAIL_UNLESS(q.read(1) == s3)
      q = sa.lookup_kind("cfg");
      `FAIL_UNLESS(q.size() == 1)
      `FAIL_UNLESS(q.read(0) == s2)
    `SVTEST_END

  //--------------------------------------------------------------------
  // lookup_kind_returns_copy
  //
  // Changing the deque returned by lookup_kind() does not change the
  // aggregator.
  //--------------------------------------------------------------------
    `SVTEST(lookup_kind_returns_copy)
      sqr_aggregator sa = new();
      sqr_t s1 = new_sqr();
      sqr_t s2 = new_sqr();
      deque_t q;

      sa.add(s1, "", "k");
      sa.add(s2, "", "k");
      q = sa.lookup_kind("k");
      void'(q.pop_front());
      q.clear();
      q = sa.lookup_kind("k");
      `FAIL_UNLESS(q.size() == 2)
    `SVTEST_END

  //--------------------------------------------------------------------
  // not_found
  //
  // Single lookups return null; lookups that can find several
  // sequencers return an empty deque, not null.
  //--------------------------------------------------------------------
    `SVTEST(not_found)
      sqr_aggregator sa = new();
      deque_t q;

      `CHECK_NAME(sa, "nope", null)
      `CHECK_PATH(sa, "no.such.path", null)
      q = sa.lookup_kind("nope");
      `FAIL_IF(q == null)
      `FAIL_UNLESS(q.size() == 0)
      q = sa.lookup_path_regex("^no_such_path$");
      `FAIL_IF(q == null)
      `FAIL_UNLESS(q.size() == 0)
      `FAIL_UNLESS(catcher.n_errors == 0)
    `SVTEST_END

  //--------------------------------------------------------------------
  // empty_name_and_kind
  //
  // An empty name or kind is not stored; the path always is.
  //--------------------------------------------------------------------
    `SVTEST(empty_name_and_kind)
      sqr_aggregator sa = new();
      sqr_t s1 = new_sqr();
      deque_t q;

      sa.add(s1, "", "");
      `FAIL_UNLESS(sa.lookup_path(s1.get_full_name()) == s1)
      `CHECK_NAME(sa, "", null)
      q = sa.lookup_kind("");
      `FAIL_UNLESS(q.size() == 0)
    `SVTEST_END

  //--------------------------------------------------------------------
  // null_sequencer
  //
  // Adding null is an error and stores nothing.
  //--------------------------------------------------------------------
    `SVTEST(null_sequencer)
      sqr_aggregator sa = new();
      deque_t q;

      sa.add(null, "n", "k");
      `FAIL_UNLESS(catcher.n_errors == 1)
      `CHECK_NAME(sa, "n", null)
      q = sa.lookup_kind("k");
      `FAIL_UNLESS(q.size() == 0)
    `SVTEST_END

  //--------------------------------------------------------------------
  // duplicate_in_kind
  //
  // Adding the same sequencer twice under one kind is an error and
  // does not add it again, but its new name is still registered.
  //--------------------------------------------------------------------
    `SVTEST(duplicate_in_kind)
      sqr_aggregator sa = new();
      sqr_t s1 = new_sqr();
      sqr_t s2 = new_sqr();
      deque_t q;

      // Duplicate as the only entry, and as the last of two entries.
      sa.add(s1, "n1", "k");
      sa.add(s1, "n2", "k");
      `FAIL_UNLESS(catcher.n_errors == 1)
      sa.add(s2, "", "k");
      sa.add(s2, "", "k");
      `FAIL_UNLESS(catcher.n_errors == 2)
      q = sa.lookup_kind("k");
      `FAIL_UNLESS(q.size() == 2)
      `CHECK_NAME(sa, "n2", s1)

      // The same sequencer under a different kind is fine.
      sa.add(s1, "", "other");
      `FAIL_UNLESS(catcher.n_errors == 2)
      q = sa.lookup_kind("other");
      `FAIL_UNLESS(q.size() == 1)
    `SVTEST_END

  //--------------------------------------------------------------------
  // name_replaced
  //
  // Adding a name already in use replaces the earlier sequencer, with
  // a warning.
  //--------------------------------------------------------------------
    `SVTEST(name_replaced)
      sqr_aggregator sa = new();
      sqr_t s1 = new_sqr();
      sqr_t s2 = new_sqr();

      sa.add(s1, "x", "");
      sa.add(s2, "x", "");
      `FAIL_UNLESS(catcher.n_warnings == 1)
      `FAIL_UNLESS(catcher.n_errors == 0)
      `CHECK_NAME(sa, "x", s2)
    `SVTEST_END

  //--------------------------------------------------------------------
  // lookup_path_regex
  //
  // Sequencers whose paths match a POSIX regular expression.
  //--------------------------------------------------------------------
    `SVTEST(lookup_path_regex)
      sqr_aggregator sa = new();
      box b1 = new("rx_box", null);
      box b2 = new("rx_other", null);
      sqr_t s1 = new_sqr(b1);
      sqr_t s2 = new_sqr(b1);
      sqr_t s3 = new_sqr(b2);
      deque_t q;

      sa.add(s1, "", "");
      sa.add(s2, "", "");
      sa.add(s3, "", "");
      q = sa.lookup_path_regex("^rx_box\\.");
      `FAIL_UNLESS(q.size() == 2)
      q = sa.lookup_path_regex("^rx_(box|other)\\.sqr_");
      `FAIL_UNLESS(q.size() == 3)
      q = sa.lookup_path_regex(s3.get_full_name());
      `FAIL_UNLESS(q.size() == 1)
      `FAIL_UNLESS(q.read(0) == s3)
    `SVTEST_END

  //--------------------------------------------------------------------
  // dump_terminates
  //
  // dump() walks all three tables.  Each loop must advance its
  // iterator; a missing next() hangs here.
  //--------------------------------------------------------------------
    `SVTEST(dump_terminates)
      sqr_aggregator sa = new();
      sqr_t s1 = new_sqr();
      sqr_t s2 = new_sqr();

      sa.add(s1, "a", "k1");
      sa.add(s2, "b", "k1");
      sa.add(s2, "",  "k2");
      sa.dump();
      `FAIL_UNLESS(catcher.n_errors == 0)
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
