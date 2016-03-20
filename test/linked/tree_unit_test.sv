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

module tree_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  import test_utils::*;  

  string name = "tree_ut";
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
  // create
  //--------------------------------------------------------------------
    `SVTEST(create)

      tree parent;
      tree c1, c2;

      parent = new("top", null);
      c1 = new("c1", parent);
      c2 = new("c2", parent);

      `FAIL_IF(c1.get_parent() != parent)
      `FAIL_IF(c2.get_parent() != parent)
      `FAIL_UNLESS_STR_EQUAL("top", parent.get_name())
      `FAIL_UNLESS_STR_EQUAL("c1", c1.get_name())
      `FAIL_UNLESS_STR_EQUAL("c2", c2.get_name())
      `FAIL_UNLESS_STR_EQUAL("top", parent.get_full_name())
      `FAIL_UNLESS_STR_EQUAL("top.c1", c1.get_full_name())
      `FAIL_UNLESS_STR_EQUAL("top.c2", c2.get_full_name())

    `SVTEST_END

  //--------------------------------------------------------------------
  // children
  //--------------------------------------------------------------------
    `SVTEST(children)

        tree top;
        tree child;
        deque#(tree, class_traits#(tree)) deq;

        top = new("top", null);
        child = new("c1", top);
        child = new("c2", top);
        child = new("c3", top);
        child = new("c4", top);

        deq = top.get_children();

        `FAIL_IF(deq.size() != 4)


    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
