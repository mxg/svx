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

module permute_iterator_unit_test;
  `include "svunit_defines.svh"
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  string name = "permute_iterator_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================

  vector#(string, string_traits) vec;
  longint fact;

  //===================================
  // Build
  //===================================
  function void build();
    string msg;
    svunit_ut = new(name);

    vec = new();
    vec.write(0, "A");
    vec.write(1, "B");
    vec.write(2, "C");
    vec.write(3, "D");
//    vec.write(4, "E");
//    vec.write(5, "F");
//    vec.write(6, "G");

    fact = factorial(vec.size());

    $sformat(msg, "permutation vector size = %0d, permutations = %0d", vec.size(), fact);
    `INFO(msg);

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


  //--------------------------------------------------------------------
  // factorial
  //
  // A little utility to compute n!
  //--------------------------------------------------------------------
  function longint unsigned factorial(int unsigned n);
    return (n <= 2)
      ? n
      : (n * factorial(n-1));
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
  // forward
  //
  // We iterate through the set of permutations in the foward direction
  // -- starting with permutation 0 and ending with permutation (n!-1).
  // A string that uniquely represents each iteration is stored in an
  // assciative array.  If all the permutations were visited correctly
  // then the size of the associative array should be the same as the
  // number of permutations generated.  if more than one permutation
  // index (incorrectly) generates the same permutation string then this
  // test will fail.
  //--------------------------------------------------------------------    
    `SVTEST(forward)

      int unsigned i;
      longint unsigned iter_count;
      permute_fwd_iterator#(string, string_traits) iter;
      string permutation;
      int perm_map[string];

      iter = new(vec);

      iter.first();
      while(!iter.at_end()) begin
        permutation = "";
        for(i = 0; i < vec.size(); i++) begin
          permutation = { permutation, "-", iter.get_nth(i) };
        end
        perm_map[permutation] = iter_count;
        iter_count++;
        iter.next();
      end

      `FAIL_IF(iter_count != factorial(vec.size()))
      `FAIL_IF(perm_map.size() != factorial(vec.size()))

      // Another idiom for traversing the vector
      perm_map.delete(); // clean out the map from the previous part of the test.
      iter_count = 0;
      iter.first();
      do begin
        permutation = "";
        for(i = 0; i < vec.size(); i++) begin
          permutation = { permutation, "-", iter.get_nth(i) };
        end
        perm_map[permutation] = iter_count;
        iter_count++;
        iter.next();
      end while(!iter.at_end());

      `FAIL_IF(iter_count != fact)
      `FAIL_IF(perm_map.size() != fact)

     // Reset to the first item in the list and then move to the last item.
      `FAIL_IF(!iter.first())
      `FAIL_IF(!iter.skip(factorial(vec.size()) - 1))

      // We should be pointing to the last item
      `FAIL_IF(!iter.is_last())

      `FAIL_IF(iter.at_end())

      // Let's move to the end and ensure we got there.
      `FAIL_IF(!iter.next())
      `FAIL_IF(!iter.at_end())
      
    `SVTEST_END

  //--------------------------------------------------------------------
  // backward
  //--------------------------------------------------------------------    
   `SVTEST(backward)

      int unsigned iter_count;
      int unsigned i;
      string permutation;
      int perm_map[string];

      permute_bkwd_iterator#(string, string_traits) iter = new();
      iter.bind_vector(vec);

      // The vector was filled with random numbers in the last test, so
      // we don't need to fill it again.
  
      // Iterate through the vector
      iter_count = 0;
      iter.last();
      while(!iter.at_beginning()) begin
        permutation = "";
        for(i = 0; i < vec.size(); i++) begin
          permutation = { permutation, "-", iter.get_nth(i) };
        end
        perm_map[permutation] = iter_count;
        iter.prev();
        iter_count++;
      end

      `FAIL_IF(iter_count != fact)
      `FAIL_IF(perm_map.size() != fact)

      // Another idiom for traversing in the backward direction
      perm_map.delete();
      iter_count = 0;
      iter.last();
      do begin
        permutation = "";
        for(i = 0; i < vec.size(); i++) begin
          permutation = { permutation, "-", iter.get_nth(i) };
        end
        perm_map[permutation] = iter_count;
        iter.prev();
        iter_count++;
      end while(!iter.at_beginning());

      `FAIL_IF(iter_count != fact)
      `FAIL_IF(perm_map.size() != fact)

       // Reset to the last item in the list and then skip backwards to
       // the first item.
  
      `FAIL_IF(!iter.last())
      `FAIL_IF(!iter.skip(-(fact - 1)))

      // We should be pointing to the first item
      `FAIL_IF(!iter.is_first())

      // at_beginning() is one past the beginning.  So we should not yet
      // be at the beginning.
      `FAIL_IF(iter.at_beginning())

      // Let's move to the beginning and ensure we got there.
      `FAIL_IF(!iter.prev())
      `FAIL_IF(!iter.at_beginning())

    `SVTEST_END

  //--------------------------------------------------------------------
  // random
  //--------------------------------------------------------------------
    `SVTEST(random)

      permute_random_iterator#(string, string_traits) iter;
      int unsigned i;
      int unsigned j;
      int unsigned iterations;
      int seed;

      iter = new(vec);

      // randomize the number of iterations

      seed = $random();

      // Use the default seed (which is 1) to generate a stream of
      // randomized acesses.
      iter.set_default_seed();
      for(i = 0; i < iterations; i++) begin
        `FAIL_IF(!iter.random())
        $write("%6d:", iter.get_permutation_index());
        for(j = 0; j < vec.size(); j++) begin
          $write(" %s", iter.get_nth(j));
        end
      end

      // Change the seed to get a different stream of accesses.
      iter.set_seed(seed);
      for(i = 0; i < iterations; i++) begin
        `FAIL_IF(!iter.random())
        $write("%6d:", iter.get_permutation_index());
        for(j = 0; j < vec.size(); j++) begin
          $write(" %s", iter.get_nth(j));
        end
      end

    `SVTEST_END

  //--------------------------------------------------------------------
  // bidir_fwd_bkwd
  //--------------------------------------------------------------------
    `SVTEST(bidir_fwd_bkwd)

      permute_bidir_iterator#(string, string_traits) iter;
      int unsigned iter_count;
      int unsigned i;

      iter = new(vec);

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the forward direction
      iter_count = 0;
      iter.first();
      while(!iter.at_end()) begin
        iter.next();
        iter_count++;
      end

      `FAIL_IF(iter_count != fact)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the forward direction using the
      // alternate idiom
      iter_count = 0;
      iter.first();
      do begin
        iter.next();
        iter_count++;
      end while(!iter.at_end());

      `FAIL_IF(iter_count != fact)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the backward direction
      iter_count = 0;
      iter.last();
      while(!iter.at_beginning()) begin
        iter.prev();
        iter_count++;
      end

      `FAIL_IF(iter_count != fact)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the backward direction using the
      // alternate idiom
      iter_count = 0;
      iter.last();
      do begin
        iter.prev();
        iter_count++;
      end while(!iter.at_beginning());

      `FAIL_IF(iter_count != fact)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // back-and-forth

      // advance from the beginning and then back
      // We should end up where we started
      `FAIL_IF(!iter.first())
      `FAIL_IF(!iter.next())
      `FAIL_IF(!iter.next())
      `FAIL_IF(iter.is_first())
      `FAIL_IF(!iter.prev())
      `FAIL_IF(!iter.prev())
      `FAIL_IF(!iter.is_first())

      // Retard from the end and then back
      // We should end up where we started
      `FAIL_IF(!iter.last())
      `FAIL_IF(!iter.prev())
      `FAIL_IF(!iter.prev())
      `FAIL_IF(iter.is_last())
      `FAIL_IF(!iter.next())
      `FAIL_IF(!iter.next())
      `FAIL_IF(!iter.is_last())

      // Find the middle of the permutation set
      `FAIL_IF(!iter.first())
      `FAIL_IF(!iter.skip(fact/2))

    `SVTEST_END

  //--------------------------------------------------------------------
  // one
  //
  // Check the pathological case where the permutation vector has only
  // one entry.  In that situation first() and last() point to the same
  // permutation, as there is only one.
  //
  // One_map, created in the setup task, has only one entry in it.
  //--------------------------------------------------------------------
    `SVTEST(one)

      int unsigned iter_count;
      string t;

      vector#(string, string_traits) one_list;

      permute_fwd_iterator#(string, string_traits) fwd_iter;
      permute_bkwd_iterator#(string, string_traits) bkwd_iter;
      permute_bidir_iterator#(string, string_traits) bidir_iter;

      // create a list with a single element in it.
      one_list = new();
      one_list.write(0, "A");

      // create the iterators and bind them to the list
      fwd_iter = new(one_list);
      bkwd_iter = new(one_list);
      bidir_iter = new(one_list);

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // First and last should be the same element
      fwd_iter.first();
      bkwd_iter.last();

      `FAIL_IF(!fwd_iter.is_last())
      `FAIL_IF(!bkwd_iter.is_first())
      `FAIL_IF(fwd_iter.get() != bkwd_iter.get())

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the foward direction
      iter_count = 0;
      fwd_iter.first();
      while(!fwd_iter.at_end()) begin
        fwd_iter.next();
        iter_count++;
      end

      `FAIL_IF(iter_count != 1)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the backward direction
      iter_count = 0;
      bkwd_iter.last();
      while(!bkwd_iter.at_beginning()) begin
        bkwd_iter.prev();
        iter_count++;
      end

      `FAIL_IF(iter_count != 1)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // First and last should be the same element
      bidir_iter.first();
      t = bidir_iter.get();
      bidir_iter.last();

      `FAIL_IF(t != bidir_iter.get())

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the foward direction using the
      // bidirectional iterator
      iter_count = 0;
      bidir_iter.first();
      while(!bidir_iter.at_end()) begin
        bidir_iter.next();
        iter_count++;
      end

      `FAIL_IF(iter_count != 1)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the backward direction using the
      // bidirectional iterator
      iter_count = 0;
      bidir_iter.last();
      while(!bidir_iter.at_beginning()) begin
        bidir_iter.prev();
        iter_count++;
      end

      `FAIL_IF(iter_count != 1)

    `SVTEST_END


  `SVUNIT_TESTS_END

endmodule

