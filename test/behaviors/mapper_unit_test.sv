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

module mapper_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
  `include "svx_macros.svh"

  string name = "mapper_ut";
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
    automatic master_process mp = master_process::get_master_process();
    svunit_ut.setup();
    /* Place Setup Code Here */
    mp.reboot();
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */
  endtask

  class thingy;
    int t;
  endclass

  class add_five extends fcn_behavior#(thingy);
    virtual function bit fcn();
      c.t += 5;
      return 1;
    endfunction
  endclass

  class delays extends task_behavior#(int unsigned);
    virtual task tsk();
      #c;  // delay
    endtask
  endclass

  class int_reduce extends reduce_behavior#(int);
    function int reduce(int t, int accum);
      return t + accum;
    endfunction
  endclass

  class delay_task extends task_behavior#(int unsigned);
    virtual task tsk();
      int unsigned d = get_context();
      #d;  // delay
    endtask
  endclass

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
  // simple_map_reduce
  //--------------------------------------------------------------------
    `SVTEST(simple_map_reduce)

      int unsigned i;
      vector#(thingy, class_traits#(thingy)) v = new();
      list_fwd_iterator#(thingy, class_traits#(thingy)) iter = new(v);
      thingy t;
      int a[5] = '{4, 11, 99, 0, -14};

      for(i = 0; i < 5; i++) begin
        t = new();
        t.t = a[i];
        v.appendc(t);
      end

      map_fcn#(thingy, class_traits#(thingy), add_five)::map(v);

      i = 0;
      void'(iter.first());
      while(!iter.at_end()) begin
        t = iter.get();
        `FAIL_UNLESS(t.t == (a[i]+5))
        void'(iter.next());
        i++;
     end
      
    `SVTEST_END

  //--------------------------------------------------------------------
  // task_map_reduce
  //
  // Map a vector of ints to a task that delays.  Each int reparesents a
  // delay time. The final time must be the start time - the sum of the
  // delays.
  //--------------------------------------------------------------------
    `SVTEST(task_map_reduce)

      time t1;
      time t2;
      int unsigned i;
      int unsigned d;
      int unsigned total_delay;
      vector#(int unsigned, int_unsigned_traits) delay_v = new();
      list_fwd_iterator#(int unsigned, int_unsigned_traits) iter = new(delay_v);

      t1 = $time;

      for(i = 0; i < 5; i++) begin
        d = ($urandom() % 90) + 10;
        delay_v.appendc(d);
        total_delay += d;
      end
      
      map_task#(int unsigned, int_unsigned_traits, delays)::map(delay_v);

      t2 = $time;
      `FAIL_UNLESS((t2 -t1) == total_delay)

    `SVTEST_END

  //--------------------------------------------------------------------
  // simple_map_concurrent
  //
  // Spawn a bunch of concurrent processes, each of which will delay a
  // randomized amount of time.  Since the processes operate in
  // parallel, the final time should be the maximum of the randomized
  // delays.
  //--------------------------------------------------------------------
    `SVTEST(simple_map_concurrent)

      time t1;
      time t2;
      int unsigned i;
       int unsigned d;
      int unsigned max;
      vector#(int unsigned, int_unsigned_traits) v = new();
      list_fwd_iterator#(int unsigned, int_unsigned_traits) iter = new(v);

      max = 0;
      for(i = 0; i < 10; i++) begin
        d = ($urandom() % 90) + 10;
        v.appendc(d);
	if(d > max)
	  max = d;
      end
      
      map_concurrent#(int unsigned, int_unsigned_traits, delay_task)::map(v);

      t2 = $time;
      `FAIL_UNLESS((t2 - t1) == max);

    `SVTEST_END
  //--------------------------------------------------------------------
  // simple_reduce
  //--------------------------------------------------------------------
    `SVTEST(simple_reduce)

      int i;
      int result;
      int sum;
      vector#(int, int_traits) v = new();

      for(i = 0; i < 100; i++) begin
        sum += i;
        v.appendc(i);
      end

      result = reduce#(int, int, int_traits, int_reduce)::reduce(v);

      `FAIL_UNLESS(sum == result)

    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
