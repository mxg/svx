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

`include "svunit_defines.svh"

module deque_unit_test;
  import svunit_pkg::svunit_testcase;

    // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  string name = "deque_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  int_deque my_deque;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_deque = new();
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

  parameter int unsigned DEQUE_SIZE = 25;


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
  // Forward queue behavior
  //--------------------------------------------------------------------
    `SVTEST(fwd_queue)
      begin
        int unsigned i;
        int value;
        int array[DEQUE_SIZE];

        // fill deque from the front
        for(i = 0; i < DEQUE_SIZE; i++) begin
          value = $random();
          array[i] = value;
          my_deque.push_front(value);
        end

        // Do we have the right number of items in the deque?
        `FAIL_IF(my_deque.size() != DEQUE_SIZE)

        // pop the back of the queue.  All the items should be
        // in the same order as the array
        for(i = 0; i < DEQUE_SIZE; i++) begin
          value = my_deque.pop_back();
          `FAIL_IF(value != array[i])
        end

      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // Backward queue behavior
  //--------------------------------------------------------------------
    `SVTEST(bkwd_queue)
      begin
        int unsigned i;
        int value;
        int array[DEQUE_SIZE];

        // fill deque from the back
        for(i = 0; i < DEQUE_SIZE; i++) begin
          value = $random();
          array[i] = value;
          my_deque.push_back(value);
        end

        // Do we have the right number of items in the deque?
        `FAIL_IF(my_deque.size() != DEQUE_SIZE)

        // pop the back of the queue.  All the items should be
        // in the same order as the array
        for(i = 0; i < DEQUE_SIZE; i++) begin
          value = my_deque.pop_front();
          `FAIL_IF(value != array[i])
        end

      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // Reverse
  //--------------------------------------------------------------------
    `SVTEST(reverse)
      begin
        int unsigned i;
        int value;
        int array[DEQUE_SIZE];

        // fill deque from the back
        for(i = 0; i < DEQUE_SIZE; i++) begin
          value = $random();
          array[i] = value;
          my_deque.push_front(value);
        end

        // Do we have the right number of items in the deque?
        `FAIL_IF(my_deque.size() != DEQUE_SIZE)

        // pop the back of the queue.  All the items should be
        // in the opposite order as the array after reversal
        my_deque.reverse();
        for(i = 0; i < DEQUE_SIZE; i++) begin
          value = my_deque.pop_front();
          `FAIL_IF(value != array[i])
        end

      end
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
        deque#(int, int_traits) cloned_deque;
        cloned_deque = my_deque.clone();

        `FAIL_IF(my_deque.size() != cloned_deque.size())
	`FAIL_IF(!my_deque.equal(cloned_deque))
      end

    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
