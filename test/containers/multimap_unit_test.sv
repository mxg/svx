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
// Copyright 2026 Mark Glasser
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

module multimap_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
  `include "svx_macros.svh"
  
  string name = "multimap_ut";
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
  // empty_map
  //--------------------------------------------------------------------
    `SVTEST(empty_map)
      multimap#(int32_t, string, string_traits) m = new();
      string s;

      `FAIL_UNLESS(m.size() == 0);

      s = m.get(100);
      `FAIL_UNLESS_STR_EQUAL(s, "");
    `SVTEST_END

  //--------------------------------------------------------------------
  // basic
  //--------------------------------------------------------------------
    `SVTEST(basic)
      multimap#(string, int32_t, int32_traits) m = new();
      uint32_t n;
  
      m.insert("A", 4);
      m.insert("B", 5);
      m.insert("A", 11);
      m.insert("C", -9);
      m.insert("C", 88);

      `FAIL_UNLESS(m.size() == 5);

      // There is only possible value for "B"
      n = m.get("B");
     `FAIL_UNLESS(n == 5);

      // Return the last value of "A"
      n = m.get("A");
     `FAIL_UNLESS(n == 11);

    `SVTEST_END

  //--------------------------------------------------------------------
  // get_all
  //--------------------------------------------------------------------
    `SVTEST(get_all)

      multimap#(string, int32_t, int32_traits) m = new();
      deque#(int32_t, int32_traits) q;
      uint32_t n;
    
      m.insert("A", 100);
      m.insert("X", 200);
      m.insert("R", 300);
      m.insert("A", 400);
      m.insert("B", 500);
      m.insert("A", 600);

      `FAIL_UNLESS(m.size() == 6);

      q = m.get_all("A");

      `FAIL_UNLESS(q != null);
      `FAIL_UNLESS(q.size() == 3);

      n = q.pop_front();
      `FAIL_UNLESS(n == 100);
      n = q.pop_front();
      `FAIL_UNLESS(n == 400);
      n = q.pop_front();
      `FAIL_UNLESS(n == 600);
  
    `SVTEST_END

  //--------------------------------------------------------------------
  // delete_key
  //--------------------------------------------------------------------
    `SVTEST(delete_key)
      deque#(int32_t, int32_traits) q;
      bit ok;
      multimap#(string, int32_t, int32_traits) m = new();

      m.insert("fred", 4);
      m.insert("fred", 443);
      m.insert("fred", -99);
      m.insert("wilma", 4000);
      m.insert("barney", 20);
      m.insert("wilma", 328);
      m.insert("betty", 6188);
      m.insert("barney", 26); 

      `FAIL_UNLESS(m.size() == 8);

      q = m.get_all("fred");
      `FAIL_UNLESS(q != null);
      `FAIL_UNLESS(q.size() == 3);
      `FAIL_UNLESS(m.size_nonzero() == 1);

      ok = m.delete("fred");
      `FAIL_UNLESS(ok == 1);
      q = m.get_all("fred");
      `FAIL_UNLESS(q == null);

      `FAIL_UNLESS(m.size() == 5);
      m.clear();
      `FAIL_UNLESS(m.size() == 0)
      `FAIL_UNLESS(m.size_nonzero() == 0);
  
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
