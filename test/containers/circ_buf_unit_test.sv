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

module circ_buf_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"
  
  string name = "circ_buf_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */

  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */

  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN

    `SVTEST(push_pop)
      int32_t val;
      circ_buf#(int32_t, int32_traits, 4) cb = new();
  
      cb.push_tail(1000);
      cb.push_tail(485);
      cb.push_tail(8922);

      `FAIL_UNLESS(cb.size() == 3);

      val = cb.pop_head();
      `FAIL_UNLESS(val == 1000);
      `FAIL_UNLESS(cb.size() == 2);
  
      val = cb.pop_head();
      `FAIL_UNLESS(val == 485);
      `FAIL_UNLESS(cb.size() == 1);

      val = cb.pop_head();
      `FAIL_UNLESS(val == 8922);
      `FAIL_UNLESS(cb.size() == 0);
      `FAIL_UNLESS(cb.is_empty());

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      cb.push_tail(86);
      cb.push_tail(-389);
      `FAIL_UNLESS(cb.size() == 2);

      cb.push_tail(777);
      cb.push_tail(9112);

      `FAIL_UNLESS(cb.size() == 4);
      `FAIL_UNLESS(cb.is_full());
      `FAIL_UNLESS(!cb.is_empty());

      val = cb.pop_head();
      `FAIL_UNLESS(val == 86);
      `FAIL_UNLESS(cb.size() == 3);

      val = cb.pop_head();
      `FAIL_UNLESS(val == -389);
      `FAIL_UNLESS(cb.size() == 2);
  
      val = cb.pop_head();
      `FAIL_UNLESS(val == 777);
      `FAIL_UNLESS(cb.size() == 1);
  
      val = cb.pop_head();
      `FAIL_UNLESS(val == 9112);
      `FAIL_UNLESS(cb.size() == 0);
      `FAIL_UNLESS(cb.is_empty());

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      cb.push_tail(600);
      `FAIL_UNLESS(cb.size() == 1);

      cb.push_tail(-111);
      `FAIL_UNLESS(cb.size() == 2);

      val = cb.pop_head();
      `FAIL_UNLESS(val == 600);
      `FAIL_UNLESS(cb.size() == 1);

      val = cb.pop_head();
      `FAIL_UNLESS(val == -111);
      `FAIL_UNLESS(cb.size() == 0);
  
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
