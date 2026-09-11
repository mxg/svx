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

//----------------------------------------------------------------------
// Algorithm test
//----------------------------------------------------------------------

`include "svx_macros.svh"

package algo_utils;

  import svx::*;

  //--------------------------------------------------------------------
  // some predicates
  //--------------------------------------------------------------------
  class lt_100 extends predicate#(uint32_t);
    function bit is_true(uint32_t t);
      return (t < 100);
    endfunction
  endclass

  class gt_0 extends predicate#(uint8_t);
    function bit is_true(uint8_t t);
      return (t > 0);
    endfunction
  endclass

  class eq_0 extends predicate#(uint8_t);
    function bit is_true(uint8_t t);
      return (t == 0);
    endfunction
  endclass

  class is_even extends predicate#(uint8_t);
    function bit is_true(uint8_t t);
      return ((t & 'h01) == 'h00);
    endfunction
  endclass

  class match_name extends predicate#(tree);
    function bit is_true(tree t);
      return (t.get_name() == "C");
    endfunction
  endclass

  class print extends fcn#(uint64_t);
    function void f(uint64_t t);
      $write(" %16x", t);
    endfunction
  endclass
  
endpackage

module algo_unit_test;
`include "svunit_defines.svh"
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
  import algo_utils::*;
  
  string name = "algo_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  vector_uint32 vec;
  index_t vector_size;

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
    vec = new();
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */

   //randomize the size of the test vector;
    vector_size = index_t'($urandom()) % index_t'(100);
    // Fill the vector with random numbers
    for(index_t i = 0; i < vector_size; i++) begin
      vec.appendc(int32_t'($urandom() % 200));
    end    
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */

  endtask

  function automatic uint64_t rand64();
    uint64_t val = (uint64_t'($urandom()) << 32) |  uint64_t'($urandom());
    return val;
  endfunction

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
  // basic_algo
  //--------------------------------------------------------------------
    `SVTEST(basic_algo)
      list_uint32_iterator iter;
      uint32_t count;
      uint32_t actual_count;

      // predicates
      lt_100 p;
      always_true#(uint32_t) p_true;
      always_false#(uint32_t) p_false;

      iter = new(vec);
      // print vector
      actual_count = 0;
      $write("vector: [%0d] ", vector_size);
      void'(iter.first());
      while(!iter.at_end()) begin
	if(iter.get() < 100)
	  actual_count++;
        void'(iter.next());
      end

      p = new();
      count = algo#(uint32_t, uint32_traits)::count(iter, p);
      `FAIL_IF(count != actual_count)

      p_true = new();
      count = algo#(uint32_t, uint32_traits)::count(iter, p_true);
      `FAIL_IF(count != uint32_t'(vector_size))

      p_false = new();
      count = algo#(uint32_t, uint32_traits)::count(iter, p_false);
      `FAIL_IF(count != 0)
  
    `SVTEST_END

  //--------------------------------------------------------------------
  // preds
  //--------------------------------------------------------------------
    `SVTEST(preds)
      uint32_t count;
      bit is_true;
      gt_0 p0 = new();

      // Create a vector from a constant list
      vector#(uint8_t, uint8_traits) v = 
	 vector#(uint8_t, uint8_traits)::create({8'h1, 8'h2, 8'h3, 8'h4, 
                                                 8'h5, 8'h6, 8'h7, 8'h8});
      list_uint8_iterator iter = new(v);

      // How many elements in the vector are greater than 0?
      count = algo#(uint8_t, uint8_traits)::count(iter, p0);
      `FAIL_UNLESS(count == 8);

      // Are none of the elements in the vector greater than 0?
      is_true = algo#(uint8_t, uint8_traits)::none_of(iter, p0);
      `FAIL_UNLESS(is_true == 0);

      // Are all the elements in the vector greater than 0?
      is_true = algo#(uint8_t, uint8_traits)::all_of(iter, p0);
      `FAIL_UNLESS(is_true == 1);

      // Is at least one element in the list greater than 0?
      is_true = algo#(uint8_t, uint8_traits)::any_of(iter, p0);
      `FAIL_UNLESS(is_true == 1);

    `SVTEST_END

  //--------------------------------------------------------------------
  // for_each
  //--------------------------------------------------------------------
    `SVTEST(for_each)


      vector_uint64 vec = new();
      list_uint64_iterator iter = new(vec);
      print p = new();
      size_t vector_size = size_t'($urandom()) % 25;
	
      // populate the vector
      for(index_t idx = 0; idx < vector_size; idx++) begin
	vec.appendc(rand64());
      end

      // Use for_each to print the vector
      $write("vector:");
      algo#(uint64_t, uint64_traits)::for_each(iter, p);
      $display();

      vec.sort();

      // Make sure the vector is indeed sorted
      for(index_t ix = 0; ix < vec.size() - 1; ix++) begin
	`FAIL_UNLESS(vec.read(ix) <= vec.read(ix+1));
      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // minimum
  //--------------------------------------------------------------------
    `SVTEST(minimum)
      vector_int32 vec;
      list_int32_iterator iter;
      int32_t min;

      vec = vector_int32::create('{-19, 111, 32, 1064, 9, -666, 27, 1012});
      iter = new(vec);

      min = algo#(int32_t, int32_traits)::min(iter);

      `FAIL_UNLESS(min == -666);

      vec = vector_int32::create('{-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5});
      iter = new(vec);

      min = algo#(int32_t, int32_traits)::min(iter);

      `FAIL_UNLESS(min == -5);  

    `SVTEST_END

  //--------------------------------------------------------------------
  // maximum
  //--------------------------------------------------------------------
    `SVTEST(maximum)
      vector_int32 vec;
      list_int32_iterator iter;
      int32_t max;

      vec = vector_int32::create('{144, 2022, -37, -988, 101, 17, 0, 3333, 98, 7});
      iter = new(vec);

      max = algo#(int32_t, int32_traits)::max(iter);

      `FAIL_UNLESS(max == 3333);

      vec = vector_int32::create('{-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5});
      iter = new(vec);

      max = algo#(int32_t, int32_traits)::max(iter);

      `FAIL_UNLESS(max == 5);
  
    `SVTEST_END

  //--------------------------------------------------------------------
  // combined_pred
  //--------------------------------------------------------------------
    `SVTEST(combined_pred)
      vector_uint8 vec = vector_uint8::create('{'h00, 'h55, 'hf2, 'h01, 'hc4, 'h16});
      list_uint8_iterator iter = new(vec);

      gt_0 p1 = new();
      is_even p2 = new();
      eq_0 p3 = new();
      and_pred#(uint8_t) p4 = new(p1, p2); // x > 0 && x is even
      or_pred#(uint8_t) p5 = new(p2, p3);  // x is even || x == 0
      not_pred#(uint8_t) p6 = new(p2);     // !(x is even)

      uint32_t count;

      count = algo#(uint8_t, uint8_traits)::count(iter, p4);
      `FAIL_UNLESS(count == 3);

      count = algo#(uint8_t, uint8_traits)::count(iter, p5);
      `FAIL_UNLESS(count == 4);

      count = algo#(uint8_t, uint8_traits)::count(iter, p6);
      `FAIL_UNLESS(count == 2);
    `SVTEST_END

  //--------------------------------------------------------------------
  // find
  //
  // find an item a vector
  //--------------------------------------------------------------------
    `SVTEST(find)
      vector_uint32 vec = vector_uint32::create('{100, 0, 400, 38, 97, 308});
      list_uint32_iterator iter = new(vec);
      lt_100 p = new();
      
      algo#(uint32_t, uint32_traits)::find(iter, p);
      `FAIL_UNLESS(iter.get() == 0);
      
    `SVTEST_END

  //--------------------------------------------------------------------
  // find_tree
  //
  // Find a node in a tree using the tree iterator and algo#()
  //--------------------------------------------------------------------
    `SVTEST(find_tree)

      match_name p;
      tree_iterator iter;
      tree t;

      // create a small tree
      tree t1 = new("A", null);
      tree t2 = new("B", t1);
      tree t3 = new("C", t1);
      tree t4 = new("D", t3);
      tree t5 = new("E", t3);

      p = new();
      iter = new(t1);
  
      algo#(tree, class_traits#(tree))::find(iter, p);

      t = iter.get();
      `FAIL_UNLESS_STR_EQUAL(t.get_name(), "C");
  
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
