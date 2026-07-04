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
// range unit test
//----------------------------------------------------------------------

module range_unit_test;
`include "svunit_defines.svh"
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  string name = "range_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  uint32_vector vec;
  index_t vector_size;
  list_bidir_uint32_iterator iter;

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
    vec = new();
    iter = new(vec);
  endfunction

  //===================================
  // Setup for running the Unit Tests
  //==ector_siz
  // ==================v===============
  task setup();
    index_t i;
    svunit_ut.setup();
    /* Place Setup Code Here */

    //randomize the size of the test vector;
    vector_size = index_t'($urandom()) % index_t'(100);
    // Fill the vector with random numbers
    for(i = 0; i < vector_size; i++) begin
      vec.appendc(int32_t'($urandom() % 1000));
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

    `SVTEST(basic_range)
      index_t ub;
      index_t lb;
      range#(uint32_t, uint32_traits) rg;
      list_bidir_uint32_iterator iter;
  
      ub = index_t'($urandom()) % vector_size;
      lb = index_t'($urandom()) % ub;
      $display("vector size = %0d, lower bound = %0d, upper bound = %0d",
	       vector_size, lb, ub);
      iter = new(vec);
      rg = new(iter, lb, ub);
  
      // print range
      $write("range:");
      void'(rg.first());
      while(!rg.at_end()) begin
	$write(" %4d", rg.get());
        void'(rg.next());
      end
      $display();

      // print vector
      $write("vector:");
      void'(iter.first());
      while(!iter.at_end()) begin
	$write(" %4d", iter.get());
        void'(iter.next());
      end
      $display();

    `SVTEST_END

   `SVTEST(bkwd_range)
      index_t ub;
      index_t lb;
      range#(uint32_t, uint32_traits) rg;
      list_bidir_uint32_iterator iter;
  
      ub = index_t'($urandom()) % vector_size;
      lb = index_t'($urandom()) % ub;
      $display("vector size = %0d, lower bound = %0d, upper bound = %0d",
	       vector_size, lb, ub);
      iter = new(vec);
      rg = new(iter, lb, ub);
  
      // print vector
      $write("vector:");
      void'(iter.first());
      while(!iter.at_end()) begin
	$write(" %4d", iter.get());
        void'(iter.next());
      end
      $display();

      // print range in reverse order
      $write("range:");
      void'(rg.last());
      while(!rg.at_beginning()) begin
	$write(" %4d", rg.get());
        void'(rg.prev());
      end
      $display();

    `SVTEST_END      

  `SVUNIT_TESTS_END

endmodule
