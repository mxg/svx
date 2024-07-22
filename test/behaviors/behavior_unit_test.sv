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

module behavior_unit_test;
  import svunit_pkg::svunit_testcase;

    // the library we are testing
  import svx::*;
  `include "svx_macros.svh"
  
  string name = "behavior_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  fcn_behavior my_fcn_behavior;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_fcn_behavior = new(/* New arguments if needed */);
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

  class int_fcn_behavior extends fcn_behavior#(int);
    function bit fcn();
      c -= 5;
      return 0;
    endfunction
  endclass

  class int_task_behavior extends task_behavior#(int);
    task tsk();
      #2;
      c -= 5;
    endtask
  endclass

  class int_process_behavior extends process_behavior#(int);
    int_task_behavior beh;

    function new(int_task_behavior b = null);
      super.new(b);
      if(b == null) begin
        beh = new();
        set_behavior(beh);
      end
      
    endfunction
  endclass

  `SVUNIT_TESTS_BEGIN

  //--------------------------------------------------------------------
  // fcn_behavior
  //--------------------------------------------------------------------
    `SVTEST(fcn_behavior_test)

      int_fcn_behavior f = new();
      f.bind_context(12);
      f.exec();

      `FAIL_IF(f.get_context() != 7)

      f.apply(22);

      `FAIL_IF(f.get_context() != 17);

    `SVTEST_END

  //--------------------------------------------------------------------
  // task_behavior
  //--------------------------------------------------------------------
    `SVTEST(task_behavior_test)

      int_task_behavior f = new();
      f.bind_context(12);
      f.exec();

      `FAIL_IF(f.get_context() != 7)

      f.apply(22);

      `FAIL_IF(f.get_context() != 17);

    `SVTEST_END

  //--------------------------------------------------------------------
  // process_behavior
  //--------------------------------------------------------------------
    `SVTEST(process_behavior_test)

      int_task_behavior t = new();
      int_process_behavior f = new(t);
      f.bind_context(12);
      f.start();
      f.await();

      `FAIL_IF(f.get_context() != 7)

      f.apply(22);
      f.await();
      `FAIL_IF(f.get_context() != 17);

    `SVTEST_END

  //--------------------------------------------------------------------
  // generic_beh
  //--------------------------------------------------------------------
    `SVTEST(generic_beh)

      generic_behavior gb;

      deque#(generic_behavior, class_traits#(generic_behavior)) vec = new();
      list_fwd_iterator#(generic_behavior, class_traits#(generic_behavior)) iter;

      int_fcn_behavior fi = new();
      int_task_behavior ti = new();

      fi.bind_context(99);
      ti.bind_context(47);

      vec.push_back(ti);
      vec.push_back(fi);

      iter = new(vec);
      void'(iter.first());
      do begin
        gb = iter.get();
        gb.exec();
        void'(iter.next());
      end while(!iter.at_end());

      `FAIL_UNLESS(fi.get_context() == 94)
      `FAIL_UNLESS(ti.get_context() == 42)
      
    `SVTEST_END

  //--------------------------------------------------------------------
  // generic_nb_beh
  //--------------------------------------------------------------------
    `SVTEST(generic_nb_beh)

      generic_behavior gb;

      deque#(generic_behavior, class_traits#(generic_behavior)) vec = new();
      list_fwd_iterator#(generic_behavior, class_traits#(generic_behavior)) iter;

      int_fcn_behavior fi = new();
      int_task_behavior ti = new();

      fi.bind_context(99);
      ti.bind_context(47);

      vec.push_back(ti);
      vec.push_back(fi);

      iter = new(vec);
      void'(iter.first());
      do begin
        gb = iter.get();
        gb.nb_exec();
        void'(iter.next());
      end while(!iter.at_end());

      // have to wait for the task to finish because it was
      // launched in non-blocking mode
      ti.wait_until_done();

      `FAIL_UNLESS(fi.get_context() == 94)
      `FAIL_UNLESS(ti.get_context() == 42)
      
    `SVTEST_END				     

  `SVUNIT_TESTS_END


endmodule
