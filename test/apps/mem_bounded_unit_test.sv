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
// Copyright 2016 NVIDIA Corporation
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

module mem_bounded_unit_test;
`include "svunit_defines.svh"
  import svunit_pkg::svunit_testcase;

   // the svx library
  import svx::*;
  `include "svx_macros.svh"

  // The facility under test
  import mem::*;
  
  import test_utils::*;
  
  string name = "mem_bounded_ut";
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

  //--------------------------------------------------------------------
  // set_bounds
  //--------------------------------------------------------------------
    `SVTEST(set_bounds)

      mem_bounded#(16,4,4,2) m = new('h3000, 'h3fff);
      `FAIL_IF(m.get_lower_bound() != 'h3000)
      `FAIL_IF(m.get_upper_bound() != 'h3fff)
      `FAIL_IF(m.get_bounds_lock() == 1)
      m.set_bounds('h2000, 'h2f00);
      `FAIL_IF(m.get_lower_bound() != 'h2000)
      `FAIL_IF(m.get_upper_bound() != 'h2f00)
      `FAIL_IF(m.get_bounds_lock() == 1)

      // lock bounds
      m.set_bounds_lock();
      `FAIL_IF(m.get_bounds_lock() == 0)
      // try to change the bounds even though they are locked
      m.set_bounds('h4211, 'hff00);
      // The bounds should not have changed
      `FAIL_IF(m.get_lower_bound() != 'h2000)
      `FAIL_IF(m.get_upper_bound() != 'h2f00)

    `SVTEST_END

  //--------------------------------------------------------------------
  // read_write
  //--------------------------------------------------------------------
    `SVTEST(read_write)

      typedef mem_bounded#(16,4,4,2) mem_t;
      mem_t::word_t data;
      mem_t m = new('h3000, 'h3fff);

      `FAIL_IF(m.get_bounds_lock() == 1)
      data = $urandom();
      m.write('h30c0, data);
      `FAIL_IF(m.get_bounds_lock() == 0)

      // write below the boundary
      m.write('h1fff, data);
      `FAIL_UNLESS(m.last_operation_failed())

      // write above the boundary
      m.write('hffff, data);
      `FAIL_UNLESS(m.last_operation_failed())

    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
