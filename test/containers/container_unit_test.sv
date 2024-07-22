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

//----------------------------------------------------------------------
// Container test
//
// Test base container class
//----------------------------------------------------------------------

`include "svunit_defines.svh"

module container_unit_test;
  import svunit_pkg::svunit_testcase;

  // The library we are testing
  import svx::*;
  `include "svx_macros.svh"


  string name = "container_ut";
  svunit_testcase svunit_ut;

  class bucket extends container;
    function size_t size();
      return 15;
    endfunction

    function bit equal();
      return 0;
    endfunction

    function void clear();
    endfunction
	
  endclass

  class int_container extends typed_container#(int, int_traits);
    function size_t size();
      return 32;
    endfunction
  endclass

  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  bucket my_bucket;
  int_container my_int_container;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_bucket = new();
    my_int_container = new();
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
  // test: container_test
  //
  // This test confirms the existence of the container base class and
  // that the virtual function size() is present.
  //--------------------------------------------------------------------
  `SVTEST(container_test)
    begin
      `FAIL_IF(my_bucket.size() != 15)
    end
  `SVTEST_END

  //--------------------------------------------------------------------
  // test: typed_container_test
  //--------------------------------------------------------------------
  `SVTEST(typed_container_test)
    begin
      `FAIL_IF(my_int_container.size() != 32)
    end
  `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
