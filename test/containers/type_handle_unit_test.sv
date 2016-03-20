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

module type_handle_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
  `include "svx_macros.svh"

  import test_utils::*;  

  string name = "type_handle_ut";
  svunit_testcase svunit_ut;

  class base extends object;
    int i;
  endclass

  class c1 extends base;
    function new();
      i = 1;
    endfunction
  endclass

  class c2 extends base;
    function new();
      i = 2;
    endfunction
  endclass

  class c3 extends base;
    function new();
      i = 3;
    endfunction
  endclass

  class c1_container extends type_container#(c1);
  endclass

  class c2_container extends type_container#(c2);
  endclass

  class c3_container extends type_container#(c3);
  endclass

  map#(type_handle_base, base, void_traits) type_map;

  c1 c1_obj;
  c2 c2_obj;
  c3 c3_obj;
  c1_container c1c;
  c2_container c2c;
  c3_container c3c;

  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
    type_map = new();    
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    c1_obj = new();
    c2_obj = new();
    c3_obj = new();
    c1c = new();
    c2c = new();
    c3c = new();
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
  // set
  //--------------------------------------------------------------------
    `SVTEST(set)

      // Put object in their respective object containers
      c1c.set(c1_obj);
      c2c.set(c2_obj);
      c3c.set(c3_obj);

      `FAIL_IF(c1c.get() != c1_obj)
      `FAIL_IF(c2c.get() != c2_obj)
      `FAIL_IF(c3c.get() != c3_obj)
    `SVTEST_END

  //--------------------------------------------------------------------
  // map
  //--------------------------------------------------------------------
    `SVTEST(map)

     base t1;

      // create a map that maps types to objects
      type_map.insert(c1c.get_type_handle(), c1_obj);
      type_map.insert(c2c.get_type_handle(), c2_obj);
      type_map.insert(c3c.get_type_handle(), c3_obj);

      `FAIL_IF(type_map.size() != 3)

      t1 = type_map.get(c1c.get_type_handle());

      `FAIL_IF(!$cast(c1_obj, t1))
    `SVTEST_END

  //--------------------------------------------------------------------
  // get
  //--------------------------------------------------------------------
    `SVTEST(get)

      map_fwd_iterator#(type_handle_base, base, void_traits) iter = new(type_map);
      base b;
      int unsigned iter_count = 0;

      iter.first();
      while(!iter.at_end()) begin
        b = iter.get();
        iter.next();
        iter_count++;
      end
   
      `FAIL_IF(iter_count != type_map.size())
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
