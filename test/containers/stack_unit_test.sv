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

module stack_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  string name = "stack_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  int_stack stk;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    stk = new();
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

  parameter int unsigned STACK_SIZE = 20;

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
  // push and pop
  //--------------------------------------------------------------------    
    `SVTEST(push_and_pop)
      int array[STACK_SIZE];
      int unsigned i;
      int val;
      int unsigned pop_count;

      // Populate the stack with random integers
      for(i = 0; i < STACK_SIZE; i++) begin
        val = $random() % 1000;
        stk.push(val);
        array[i] = val;
      end

      // Pop all the items off the stack.  Make sure that the items are
      // the same ones that we put in and they are in the correct order.
      while(!stk.is_empty()) begin
        val = stk.pop();
        pop_count++;
        `FAIL_IF(val != array[STACK_SIZE - pop_count])
      end

      `FAIL_IF(pop_count != STACK_SIZE)

    `SVTEST_END

  //--------------------------------------------------------------------
  // clone
  //
  // Clone the stack and ensure that the cloned copy is identical to
  // the original
  //--------------------------------------------------------------------
    `SVTEST(clone)
      begin
        int unsigned i;
        stack#(int, int_traits) cloned_stack;
        cloned_stack = stk.clone();

        `FAIL_IF(stk.size() != cloned_stack.size())
	`FAIL_IF(!stk.equal(cloned_stack))
      end

    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
