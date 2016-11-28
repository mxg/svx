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

module dictionary_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  import test_utils::*;

  string name = "dictionary_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  dictionary#(int, int_traits) dict;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    dict = new();
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

    `SVTEST(sort)

      string key;
      int val;
      int idx;
      string key_q[$];
      int val_q[$];
      string key_order[] = {"abc", "barney", "betty", "fred", "wilma", "xyz"};
      int val_order[] = {5, 1, 3, 0, 2, 4};
      map_fwd_iterator#(string, int, int_traits) iter = new();

      dict.insert("fred", 0);
      dict.insert("barney", 1);
      dict.insert("wilma", 2);
      dict.insert("betty", 3);
      dict.insert("xyz", 4);
      dict.insert("abc", 5);

      // make sure the dictionary is in sorted order.

      iter.bind_map(dict);
      iter.first();
      while(!iter.at_end()) begin
        key = iter.get_index();
        val = iter.get();
        key_q.push_back(key);
        val_q.push_back(val);
        iter.next();
      end

      idx = 0;
      while(key_q.size() > 0) begin
        key = key_q.pop_front();
        val = val_q.pop_front();
        `FAIL_IF(key != key_order[idx])
        `FAIL_IF(val != val_order[idx])
        idx++;
      end

    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
