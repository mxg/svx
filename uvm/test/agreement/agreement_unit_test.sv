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
// agreement_unit_test
//
// Unit tests for the agreement.  Participants are plain uvm_objects.
// Each test creates its own agreement, so tests do not affect one
// another.  Waiters are started with fork/join_none and record the
// time they were released, so a test can check both whether and when
// a waiter was released.
//----------------------------------------------------------------------

module agreement_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import uvm_pkg::*;
  import svx::*;
  import svx_uvm_pkg::*;
 `include "svx_macros.svh"

  string name = "agreement_ut";
  svunit_testcase svunit_ut;

  //--------------------------------------------------------------------
  // participant
  //
  // uvm_object is virtual, so participants need a concrete class.
  //--------------------------------------------------------------------
  class participant extends uvm_object;
    function new(string name = "participant");
      super.new(name);
    endfunction
  endclass

  //--------------------------------------------------------------------
  // agreement_catcher
  //
  // Count and swallow the agreement's debug messages.
  //--------------------------------------------------------------------
  class agreement_catcher extends uvm_report_catcher;

    int unsigned n_msgs;

    function new(string name = "agreement_catcher");
      super.new(name);
    endfunction

    function action_e catch();
      string id = get_id();
      if(id == "SVX/AGREE" || id == "SVX/DISAGREE" ||
         id == "SVX/ALL_IN_AGREEMENT" || id == "SVX/CLEAR") begin
        n_msgs++;
        return CAUGHT;
      end
      return THROW;
    endfunction

  endclass

  //--------------------------------------------------------------------
  // waiter
  //
  // Wait for an agreement in a separate process and record when the
  // wait completed.
  //--------------------------------------------------------------------
  class waiter;
    bit  is_released;
    time release_time;

    function bit released();
      return is_released;
    endfunction

    function void start(agreement a);
      fork
        begin
          a.wait_for_agreement(null);
          release_time = $time;
          is_released = 1;
        end
      join_none
    endfunction
  endclass

  agreement_catcher catcher;
  participant p1, p2, p3;

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
    catcher = new();
    p1 = new("p1");
    p2 = new("p2");
    p3 = new("p3");
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
    catcher.n_msgs = 0;
    agreement::clr_debug_all();
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
  // initial_state
  //
  // A new agreement has no disagreements, and waiting on it returns
  // without advancing time.
  //--------------------------------------------------------------------
    `SVTEST(initial_state)
      agreement a = new("a");
      waiter w = new();
      time t0 = $time;

      `FAIL_UNLESS(a.num_disagreements() == 0)
      w.start(a);
      #1;
      `FAIL_UNLESS(w.released())
      `FAIL_UNLESS(w.release_time == t0)
    `SVTEST_END

  //--------------------------------------------------------------------
  // votes
  //
  // Only transitions change the count: disagreeing twice counts once,
  // and agreeing without having disagreed has no effect.
  //--------------------------------------------------------------------
    `SVTEST(votes)
      agreement a = new("a");

      a.disagree(p1);
      `FAIL_UNLESS(a.num_disagreements() == 1)
      a.disagree(p1);
      `FAIL_UNLESS(a.num_disagreements() == 1)
      a.agree(p1);
      `FAIL_UNLESS(a.num_disagreements() == 0)
      a.agree(p1);
      `FAIL_UNLESS(a.num_disagreements() == 0)

      // Agreeing first must not take the count below zero.
      a.agree(p2);
      `FAIL_UNLESS(a.num_disagreements() == 0)
      a.disagree(p2);
      `FAIL_UNLESS(a.num_disagreements() == 1)
      a.agree(p2);
      `FAIL_UNLESS(a.num_disagreements() == 0)
    `SVTEST_END

  //--------------------------------------------------------------------
  // several_participants
  //--------------------------------------------------------------------
    `SVTEST(several_participants)
      agreement a = new("a");

      a.disagree(p1);
      a.disagree(p2);
      a.disagree(p3);
      `FAIL_UNLESS(a.num_disagreements() == 3)
      a.agree(p2);
      `FAIL_UNLESS(a.num_disagreements() == 2)
      a.agree(p1);
      `FAIL_UNLESS(a.num_disagreements() == 1)
      a.agree(p3);
      `FAIL_UNLESS(a.num_disagreements() == 0)
    `SVTEST_END

  //--------------------------------------------------------------------
  // clear_votes
  //
  // clear() discards votes as well as the count, so a participant
  // that disagreed before clear() and agrees after it does not take
  // the count below zero.
  //--------------------------------------------------------------------
    `SVTEST(clear_votes)
      agreement a = new("a");

      a.disagree(p1);
      a.disagree(p2);
      a.clear(null);
      `FAIL_UNLESS(a.num_disagreements() == 0)
      a.agree(p1);
      `FAIL_UNLESS(a.num_disagreements() == 0)
      a.disagree(p1);
      `FAIL_UNLESS(a.num_disagreements() == 1)
    `SVTEST_END

  //--------------------------------------------------------------------
  // instances_independent
  //
  // Votes belong to one agreement; another agreement is unaffected.
  //--------------------------------------------------------------------
    `SVTEST(instances_independent)
      agreement a = new("a");
      agreement b = new("b");

      a.disagree(p1);
      `FAIL_UNLESS(a.num_disagreements() == 1)
      `FAIL_UNLESS(b.num_disagreements() == 0)
      b.agree(p1);
      `FAIL_UNLESS(a.num_disagreements() == 1)
    `SVTEST_END

  //--------------------------------------------------------------------
  // wait_released_by_last_agree
  //
  // A waiter stays blocked while anyone disagrees and is released in
  // the time step of the last agree().
  //--------------------------------------------------------------------
    `SVTEST(wait_released_by_last_agree)
      agreement a = new("a");
      waiter w = new();
      time t0 = $time;

      a.disagree(p1);
      a.disagree(p2);
      w.start(a);
      #10;
      `FAIL_IF(w.released())
      a.agree(p1);
      #10;
      `FAIL_IF(w.released())
      a.agree(p2);
      #1;
      `FAIL_UNLESS(w.released())
      `FAIL_UNLESS(w.release_time == t0 + 20)
    `SVTEST_END

  //--------------------------------------------------------------------
  // several_waiters
  //
  // Any number of processes may wait; all are released together.
  //--------------------------------------------------------------------
    `SVTEST(several_waiters)
      agreement a = new("a");
      waiter w[3];
      time t0 = $time;

      a.disagree(p1);
      foreach(w[i]) begin
        w[i] = new();
        w[i].start(a);
      end
      #5;
      a.agree(p1);
      #1;
      foreach(w[i]) begin
        `FAIL_UNLESS(w[i].released())
        `FAIL_UNLESS(w[i].release_time == t0 + 5)
      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // wait_yields_first
  //
  // wait_for_agreement() yields before testing, so a participant that
  // disagrees in the same time step, after the waiter has started
  // running, is still counted.  The #0 lets the waiter process run
  // before the disagree().
  //--------------------------------------------------------------------
    `SVTEST(wait_yields_first)
      agreement a = new("a");
      waiter w = new();
      time t0 = $time;

      w.start(a);
      #0;
      a.disagree(p1);
      #5;
      `FAIL_IF(w.released())
      a.agree(p1);
      #1;
      `FAIL_UNLESS(w.released())
      `FAIL_UNLESS(w.release_time == t0 + 5)
    `SVTEST_END

  //--------------------------------------------------------------------
  // disagree_again
  //
  // After an agreement is reached, a new disagreement blocks new
  // waiters again.
  //--------------------------------------------------------------------
    `SVTEST(disagree_again)
      agreement a = new("a");
      waiter w1 = new();
      waiter w2 = new();

      a.disagree(p1);
      w1.start(a);
      #1;
      a.agree(p1);
      #1;
      `FAIL_UNLESS(w1.released())

      a.disagree(p1);
      w2.start(a);
      #5;
      `FAIL_IF(w2.released())
      a.agree(p1);
      #1;
      `FAIL_UNLESS(w2.released())
    `SVTEST_END

  //--------------------------------------------------------------------
  // debug_messages
  //
  // Debug messages are issued only when debug is on for the instance
  // or for every agreement.
  //--------------------------------------------------------------------
    `SVTEST(debug_messages)
      agreement a = new("a");
      agreement b = new("b");

      a.disagree(p1);
      a.agree(p1);
      `FAIL_UNLESS(catcher.n_msgs == 0)

      a.set_debug();
      a.disagree(p1);
      a.agree(p1);
      `FAIL_UNLESS(catcher.n_msgs == 2)
      b.disagree(p1);
      `FAIL_UNLESS(catcher.n_msgs == 2)

      a.clr_debug();
      agreement::set_debug_all();
      b.agree(p1);
      `FAIL_UNLESS(catcher.n_msgs == 3)
      agreement::clr_debug_all();
      b.disagree(p1);
      `FAIL_UNLESS(catcher.n_msgs == 3)
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
