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

module sorter_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  import test_utils::*;
  string name = "sorter_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================

  class coordinate;
    rand int x;
    rand int y;

    constraint c { (x < 1000 && x > -1000) && (y < 1000 & y > -1000); };
  endclass

  class coordinate_traits;

    typedef coordinate empty_t;
    const static empty_t empty = null;

    static function bit equal(coordinate a, coordinate b);
      return ((a.x == b.x) && (a.y == b.y));
    endfunction
    
    static function int compare(coordinate a,  b);
      if(equal(a,b))
	return 0;
      if(a.x > b.x)
	return 1;
      if(a.x < b.x)
	return -1;
    endfunction

    static function void sort(ref coordinate vec[$]);
      sorter#(coordinate,coordinate_traits)::sort(vec);
    endfunction
    
  endclass

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
  // int_sort
  //--------------------------------------------------------------------
    `SVTEST(int_sort)

      int i;
      const int N = 50;
      vector#(int, int_traits) v = new();

      for(i = 0; i < N; i++) begin
        v.appendc($random());
      end

      v.sort();

      // make sure the new array is sorted
      for(i = 0; i < N-1; i++) begin
        `FAIL_UNLESS(v.read(i) <= v.read(i+1))
      end

    `SVTEST_END

  //--------------------------------------------------------------------
  // worst_case__sort
  //
  // Sort a list that is already sorted in reverse order
  //--------------------------------------------------------------------
    `SVTEST(worst_case_sort)

      int i;
      const int N = 50;
      vector#(int, int_traits) v = new();

      for(i = 0; i < N; i++) begin
        v.appendc(N-i);
      end

      v.sort();

      // make sure the new array is sorted
      for(i = 0; i < N-1; i++) begin
        `FAIL_UNLESS(v.read(i) <= v.read(i+1))
      end

    `SVTEST_END

  //--------------------------------------------------------------------
  // coordinate_sort
  //--------------------------------------------------------------------
    `SVTEST(coordinate_sort)

      int unsigned i;
      coordinate c;
  

      vector#(coordinate, coordinate_traits) v = new();
      list_fwd_iterator#(coordinate, coordinate_traits) iter = new(v);
      const int N=20;

      for(i = 0; i < N; i++) begin
	    c = new();
	    void'(c.randomize());
        v.appendc(c);
      end

      v.sort();

      //i = 0;
      //while(!iter.at_end()) begin
      //  c = iter.get();
      //  $display("%2d : %10d:%10d", i, c.x, c.y);
      //  i++;
      //  iter.next();
      //end

      // make sure the new array is sorted
      for(i = 0; i < N-1; i++) begin
        `FAIL_UNLESS(coordinate_traits::compare(v.read(i), v.read(i+1)) < 0)
      end

    `SVTEST_END

  //--------------------------------------------------------------------
  // coordinate_worst_case_sort
  //--------------------------------------------------------------------
    `SVTEST(coordinate_worst_case_sort)

      int unsigned i;
      coordinate c;
  

      vector#(coordinate, coordinate_traits) v = new();
      list_fwd_iterator#(coordinate, coordinate_traits) iter = new(v);
      const int N=20;

      for(i = 0; i < N; i++) begin
	    c = new();
	    void'(c.randomize());
	    c.x = N-i;
        v.appendc(c);
      end

      v.sort();

      // make sure the new array is sorted
      for(i = 0; i < N-1; i++) begin
        `FAIL_UNLESS(coordinate_traits::compare(v.read(i), v.read(i+1)) < 0)
      end

    `SVTEST_END

  //--------------------------------------------------------------------
  // string sort
  //--------------------------------------------------------------------
    `SVTEST(string_sort)

      int unsigned i;
      rand_string r = new();
      vector#(string, string_traits) v = new();
      list_fwd_iterator#(string, string_traits) iter = new(v);
      const int N=20;

      for(i = 0; i < N; i++) begin
        v.appendc(r.rand_string());
      end

      v.sort();

      //i = 0;
      //while(!iter.at_end()) begin
      //  $display("%0d : %s", i, iter.get());
      //  i++;
      //  iter.next();
      //end

      // make sure the new array is sorted
      for(i = 0; i < N-1; i++) begin
        `FAIL_UNLESS(v.read(i) <= v.read(i+1))
      end

    `SVTEST_END
      
  `SVUNIT_TESTS_END

endmodule
