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

module queue_unit_test;
  import svunit_pkg::svunit_testcase;

    // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  string name = "queue_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  queue#(int, int_traits) my_queue;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_queue = new(/* New arguments if needed */);
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

    parameter int unsigned QUEUE_SIZE = 25;

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
  // empty_queue
  //--------------------------------------------------------------------
    `SVTEST(empty_queue)
      begin

        // queue should be empty at this point
        `FAIL_IF(!my_queue.is_empty())

        // get() should return an empty object
        `FAIL_IF(my_queue.get() != int_traits::empty)
      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // fifo behavior
  //--------------------------------------------------------------------
    `SVTEST(fifo)
      begin
        int unsigned i;
        int value;
        int array[QUEUE_SIZE];

        // fill queue from the front
        for(i = 0; i < QUEUE_SIZE; i++) begin
          value = $random();
          array[i] = value;
          my_queue.put(value);
        end

        // Do we have the right number of items in the queue?
        `FAIL_IF(my_queue.size() != QUEUE_SIZE)

        // pop the back of the queue.  All the items should be
        // in the same order as the array
        for(i = 0; i < QUEUE_SIZE; i++) begin
          value = my_queue.get();
          `FAIL_IF(value != array[i])
        end

        // queue should be empty again
        `FAIL_IF(!my_queue.is_empty())

      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // peek
  //--------------------------------------------------------------------
    `SVTEST(peek)
      begin

        const string str = "abcdef";
        string_queue q = new();

        // The queue is empty, so a peek should return the empty item
        `FAIL_IF(q.peek() != string_traits::empty)

        // put an item in the queue and peek it a few times.  Each peek
        // should give the same answer.
        q.put(str);
        `FAIL_IF(q.peek() != str)
        `FAIL_IF(q.peek() != str)
        `FAIL_IF(q.peek() != str)
        `FAIL_IF(q.get() != str)
        // should be empty now...
        `FAIL_IF(q.peek() != string_traits::empty)

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
        queue#(int, int_traits) cloned_queue;
	
        cloned_queue = my_queue.clone();

        `FAIL_IF(my_queue.size() != cloned_queue.size())
	`FAIL_IF(!my_queue.equal(cloned_queue))
      end

    `SVTEST_END      

  `SVUNIT_TESTS_END

endmodule

module fixed_size_queue_unit_test;
  import svunit_pkg::svunit_testcase;

    // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  string name = "fixed_size_queue_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  fixed_size_queue#(int, int_traits) fq;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    fq = new(4);
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
  // full
  //--------------------------------------------------------------------
    `SVTEST(full)
      int unsigned i;
      int t;

      `FAIL_IF(fq.size != 0)
      `FAIL_IF(!fq.is_empty())

      for(i = 0; i < 4; i++) begin
        fq.put(i);
      end

      `FAIL_IF(fq.size() != 4)
      `FAIL_IF(fq.size != fq.get_max_size())
      `FAIL_IF(fq.peek() != 0)
      
      // Try to stuff another entry into an already full queue.
      fq.put(5);

      `FAIL_IF(fq.last_push_succeeded())

      // OK, let's remove one element from the queue an try to put
      // another in.
      t = fq.get();

      `FAIL_IF(t != 0)
      `FAIL_IF(fq.is_full())
      `FAIL_IF(fq.is_empty())
      
      fq.put(6);
 
      `FAIL_IF(!fq.last_push_succeeded())
      `FAIL_IF(!fq.is_full())

    `SVTEST_END


  //--------------------------------------------------------------------
  // clone
  //--------------------------------------------------------------------
    `SVTEST(clone)
      fixed_size_queue#(int, int_traits) cloned_queue;

      cloned_queue = fq.clone();

      `FAIL_IF(!fq.equal(cloned_queue))
      `FAIL_IF(!cloned_queue.equal(fq))
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
