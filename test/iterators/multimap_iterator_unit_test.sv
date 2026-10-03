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

module multimap_iterator_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
  `include "svx_macros.svh"

  string name = "multimap_iterator_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  multimap#(string, int32_t, int32_traits) mm;

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
    mm = new();

    // populate the multimap
    mm.insert("X", 1);
    mm.insert("B", 2);
    mm.insert("F", 3);
    mm.insert("B", 4);
    mm.insert("R", 5);
    mm.insert("B", 6);
    mm.insert("F", 7);
    mm.insert("J", 8);
    
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
  // forward
  //--------------------------------------------------------------------
    `SVTEST(forward)
      size_t count;
      multimap_iterator#(string, int32_t, int32_traits) iter = new(mm);

      count = 0;
      void'(iter.first());
      while(!iter.at_end()) begin
	void'(iter.next());
	count++;
      end

      `FAIL_UNLESS(count == mm.size());
    `SVTEST_END

  //--------------------------------------------------------------------
  // reverse
  //--------------------------------------------------------------------
    `SVTEST(reverse)
      size_t count;
      multimap_iterator#(string, int32_t, int32_traits) iter = new(mm);

      count = 0;
      void'(iter.last());
      while(!iter.at_beginning()) begin
	void'(iter.prev());
	count++;
      end

      `FAIL_UNLESS(count == mm.size());
    `SVTEST_END      

  //--------------------------------------------------------------------
  // get_forward
  //--------------------------------------------------------------------
    `SVTEST(get_forward)
      int32_t n;
      multimap_iterator#(string, int32_t, int32_traits) iter = new(mm);
  
      `FAIL_UNLESS(iter.first() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 2);
      `FAIL_UNLESS(iter.next() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 4);
      `FAIL_UNLESS(iter.next() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 6);
      `FAIL_UNLESS(iter.next() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 3);
      `FAIL_UNLESS(iter.next() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 7);
      `FAIL_UNLESS(iter.next() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 8);
      `FAIL_UNLESS(iter.next() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 5);
      `FAIL_UNLESS(iter.next() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 1);
      `FAIL_UNLESS(iter.next() == 0); 
      `FAIL_UNLESS(iter.at_end() == 1);
     
    `SVTEST_END

  //--------------------------------------------------------------------
  // get_reverse
  //--------------------------------------------------------------------
    `SVTEST(get_reverse)
      int32_t n;
      multimap_iterator#(string, int32_t, int32_traits) iter = new(mm);
  
      `FAIL_UNLESS(iter.last() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 1);
      `FAIL_UNLESS(iter.prev() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 5);
      `FAIL_UNLESS(iter.prev() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 8);
      `FAIL_UNLESS(iter.prev() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 7);
      `FAIL_UNLESS(iter.prev() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 3);
      `FAIL_UNLESS(iter.prev() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 6);
      `FAIL_UNLESS(iter.prev() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 4);
      `FAIL_UNLESS(iter.prev() == 1);
      n = iter.get();
      `FAIL_UNLESS(n == 2);
      `FAIL_UNLESS(iter.prev() == 0);
      `FAIL_UNLESS(iter.at_beginning() == 1);
      
    `SVTEST_END

  //--------------------------------------------------------------------
  // set
  //--------------------------------------------------------------------
    `SVTEST(set)
      int32_t n;
      multimap_iterator#(string, int32_t, int32_traits) iter = new(mm);

      `FAIL_UNLESS(iter.first() == 1);
      `FAIL_UNLESS(iter.next() == 1);
      `FAIL_UNLESS(iter.next() == 1);
      `FAIL_UNLESS(iter.next() == 1);
      `FAIL_UNLESS(iter.next() == 1);
      `FAIL_UNLESS(iter.next() == 1);

      n = iter.get();
      `FAIL_UNLESS(n == 8);

      iter.set(11);
      n = mm.get("J");
      `FAIL_UNLESS(n == 11);

    `SVTEST_END

  //--------------------------------------------------------------------
  // skip
  //--------------------------------------------------------------------
    `SVTEST(skip)
      int32_t n;
      multimap_iterator#(string, int32_t, int32_traits) iter = new(mm);

      `FAIL_UNLESS(iter.first() == 1);
      `FAIL_UNLESS(iter.skip(5));
      n = iter.get();
      `FAIL_UNLESS(n == 11);

      `FAIL_UNLESS(iter.skip(-2) == 1);
       n = iter.get();
      `FAIL_UNLESS(n == 3);

      `FAIL_UNLESS(iter.skip(40) == 0);
      `FAIL_UNLESS(iter.at_end() == 1);
    
    `SVTEST_END
      
  `SVUNIT_TESTS_END

endmodule
