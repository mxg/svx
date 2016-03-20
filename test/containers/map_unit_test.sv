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

module map_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
  `include "svx_macros.svh"

  import test_utils::*;

  string name = "map_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  rand_string rs;
  map#(string, int, int_traits) m;
  int array[string];

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
    rs = new();
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
  endtask

  parameter int unsigned MAP_SIZE = 20;

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
  // string_map
  //
  // Ensure basic functinality of a map that maps strings to integers.
  // Insert some randomly generated keys into the map and see that they
  // are all there.
  //--------------------------------------------------------------------

    `SVTEST(string_map)
      string s;
      string t;
      int unsigned i;

      m = new();

      // Load up the map
      for(i = 0; i < MAP_SIZE; i++) begin
        s = rs.rand_string();
        m.insert(s, i);
        array[s] = i;
      end 

      `FAIL_IF(m.size() != MAP_SIZE)

      foreach (array[s]) begin
	`FAIL_UNLESS(string_traits::equal(array[s], m.get(s)))
      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // exists
  //
  // Ensure that one of the items that we put into the string/int map
  // previously does indeed exist.  Also ensure that a hardcoded (not
  // randomly generated) string key does NOT exist.
  //--------------------------------------------------------------------
    `SVTEST(exists)
      int unsigned i;
      int unsigned n;
      string s;
      string t;
      const string s_cmp = "abcdef";

      // Randomly choose an item that is in the map
      n = $urandom() % MAP_SIZE;
      i = 0;
      foreach (array[t]) begin
        s = t;
        if(i == n)
          break;
        i++;
      end
        
      // Let's be sure that the item exists
      `FAIL_IF(!m.exists(s))

      // Let's see if an item DOESN"T exist.  Since the string keys are
      // randomly generated there is a low probability that the
      // hardcoded key is already in the map.
      `FAIL_IF(m.exists(s_cmp))
      
    `SVTEST_END

  //--------------------------------------------------------------------
  // clone
  //--------------------------------------------------------------------
    `SVTEST(clone)

      int unsigned i;
      int unsigned n;
      string s;
      map#(string, int, int_traits) cloned_map;

      cloned_map = m.clone();

      `FAIL_IF(m.size() != cloned_map.size())
      `FAIL_IF(!m.equal(cloned_map))

      // Arbitrarily change an element in the cloned_map.  The maps
      // should no longer be equal.

      // Randomly choose an item that is in the map
      n = $urandom() % MAP_SIZE;
      i = 0;
      foreach (array[t]) begin
        s = t;
        if(i == n)
          break;
        i++;
      end

      // Let's be sure that the item exists
      `FAIL_IF(!cloned_map.exists(s))

      // Replace the item with a (different) random number
      `FAIL_IF(cloned_map.insert(s, $random()))

      // The maps should no longer be equal
      `FAIL_IF(m.equal(cloned_map))

    `SVTEST_END
      
  //--------------------------------------------------------------------
  // delete
  //--------------------------------------------------------------------
    `SVTEST(delete)
      int unsigned i;
      int unsigned n;
      string s;
      string t;

     // The map should have all entries in it.
      `FAIL_IF(m.size() != MAP_SIZE)

      // Randomly choose an item that is in the map
      n = $urandom() % MAP_SIZE;
      i = 0;
      foreach (array[t]) begin
        s = t;
        if(i == n)
          break;
        i++;
      end

      `FAIL_IF(!m.exists(s))
      m.delete(s);
      // Let's make sure it's really gone
      `FAIL_IF(m.exists(s))
      `FAIL_IF(m.size() != (MAP_SIZE - 1))
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule

module singleton_map_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  string name = "singleton_map_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  singleton_map#(string, int, int_traits) sm;
  typedef singleton_map#(string, int, int_traits) map_t;


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
  // singleton

  // Ensure that each call to get() returns the same handle
  //--------------------------------------------------------------------

    `SVTEST(singleton)
      map_t m1;
      map_t m2;

      m1 = map_t::get_inst();
      m2 = map_t::get_inst();
      `FAIL_IF(m1 != m2)
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
