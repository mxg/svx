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
// List Iterators Unit Test
//----------------------------------------------------------------------
module list_iterators_unit_test;
  `include "svunit_defines.svh"
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  string name = "list_iterators_ut";
  svunit_testcase svunit_ut;

  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  int_vector vec;
  int unsigned vector_size;

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    vec = new();

    //randomize the size of the test vector;
    vector_size = $urandom() % 1000;
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
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
  // forward iteration
  //--------------------------------------------------------------------    
    `SVTEST(forward_iteration)
  
      int unsigned iter_count;
      int unsigned i;
      int last_item;
  
      list_fwd_iterator#(int, int_traits) iter = new();

      // We could bind the vector using the iterator constructor.  We do
      // it here using bind_list() to ensure that function works
      // correctly.
  
      iter.bind_list(vec);

      // Fill the vector with random numbers
      for(i = 0; i < vector_size; i++) begin
        vec.appendc($urandom());
      end

      // Iterate through the vector
      void'(iter.first());
      while(!iter.at_end()) begin
        iter_count++;
        void'(iter.next());
      end

      `FAIL_IF(iter_count != vector_size)

      // Another idiom for traversing the vector
      iter_count = 0;
      void'(iter.first());
      do begin
        iter_count++;
        void'(iter.next());
      end while(!iter.at_end());

      `FAIL_IF(iter_count != vector_size)

      // Reset to the first item in the list and then move to the last item.
      `FAIL_IF(!iter.first())
      `FAIL_IF(!iter.skip(vec.size() - 1))

      // We should be pointing to the last item
      `FAIL_IF(!iter.is_last())

      // Let's make sure the last item is the one we think it is
      last_item = vec.read(vec.size() - 1);
      `FAIL_IF(last_item != iter.get())

      // at_end() is one past the end.  So we should not yet be at the end
      `FAIL_IF(iter.at_end())

      // Let's move to the end and ensure we got there.
      `FAIL_IF(!iter.next())
      `FAIL_IF(!iter.at_end())

    `SVTEST_END

  //--------------------------------------------------------------------    
  // backward iteration
  //--------------------------------------------------------------------    
    `SVTEST(backward_iteration)

      int unsigned iter_count;
      int unsigned i;
      int first_item;
      list_bkwd_iterator#(int, int_traits) iter = new();
      iter.bind_list(vec);

      // The vector was filled with random numbers in the last test, so
      // we don't need to fill it again.
  
      // Iterate through the vector
      iter_count = 0;
      void'(iter.last());
      while(!iter.at_beginning()) begin
        void'(iter.prev());
        iter_count++;
      end

      `FAIL_IF(iter_count != vector_size)

      // Another idiom for traversing in the backward direction
      iter_count = 0;
      void'(iter.last());
      do begin
        void'(iter.prev());
        iter_count++;
      end while(!iter.at_beginning());

      `FAIL_IF(iter_count != vector_size)

       // Reset to the last item in the list and then skip backwards to
       // the first item.
  
      `FAIL_IF(!iter.last())
      `FAIL_IF(!iter.skip(-(vec.size() - 1)))

      // We should be pointing to the first item
      `FAIL_IF(!iter.is_first())

      // Let's make sure the first item is the one we think it is
      first_item = vec.read(0);
      `FAIL_IF(first_item != iter.get())

      // at_beginning() is one past the beginning.  So we should not yet
      // be at the beginning.
      `FAIL_IF(iter.at_beginning())

      // Let's move to the end and ensure we got there.
      `FAIL_IF(!iter.prev())
      `FAIL_IF(!iter.at_beginning())

    `SVTEST_END

  //--------------------------------------------------------------------
  // begin_and_end
  //--------------------------------------------------------------------
    `SVTEST(begin_and_end)

      list_fwd_iterator#(int, int_traits) fwd_iter = new(vec);
      list_bkwd_iterator#(int, int_traits) bkwd_iter = new(vec);

      // beginning...
      `FAIL_IF(!fwd_iter.first())
      `FAIL_IF(fwd_iter.get() !=  vec.read(0))
      `FAIL_IF(!fwd_iter.next())

      // ending...
      `FAIL_IF(!bkwd_iter.last())
      `FAIL_IF(bkwd_iter.get() != vec.read(vec.size() - 1))
      `FAIL_IF(!bkwd_iter.prev())

    `SVTEST_END

  //--------------------------------------------------------------------
  // zero_length
  //--------------------------------------------------------------------
    `SVTEST(zero_length)
  
      list_fwd_iterator#(int, int_traits) fwd_iter = new(vec);
      list_bkwd_iterator#(int, int_traits) bkwd_iter = new(vec);
      list_bidir_iterator#(int, int_traits) bidir_iter = new(vec);
      list_random_iterator#(int, int_traits) random_iter = new(vec);

      // empty the vector
      vec.clear();
      `FAIL_IF(vec.size() != 0)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      `FAIL_IF(fwd_iter.first())
      `FAIL_IF(fwd_iter.next())
      `FAIL_IF(fwd_iter.is_last()) 
      `FAIL_IF(!fwd_iter.at_end())

      `FAIL_IF(fwd_iter.get() != int_traits::empty)
  
      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      `FAIL_IF(bkwd_iter.last())
      `FAIL_IF(bkwd_iter.prev())
      `FAIL_IF(bkwd_iter.is_first())
      `FAIL_IF(!bkwd_iter.at_beginning())

      // There is no current item
      `FAIL_IF(bkwd_iter.get() != int_traits::empty)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      `FAIL_IF(bidir_iter.first())
      `FAIL_IF(bidir_iter.next())
      `FAIL_IF(bidir_iter.is_last()) 
      `FAIL_IF(!bidir_iter.at_end())
      `FAIL_IF(bidir_iter.last())
      `FAIL_IF(bidir_iter.prev())
      `FAIL_IF(bidir_iter.is_first())
      `FAIL_IF(!bidir_iter.at_beginning())

      // There is no current item
      `FAIL_IF(bidir_iter.get() != int_traits::empty)      

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      `FAIL_IF(random_iter.random())
      `FAIL_IF(random_iter.get() != int_traits::empty)

    `SVTEST_END

  //--------------------------------------------------------------------
  // unbound
  //
  // This test is similar to the zero_length test (above).  If the
  // iterator is not bound to a list then you cannot set the position to
  // first or last or anywhere in between because there is no first or
  // last or in between.  All of the position related functions should
  // fail.
  //--------------------------------------------------------------------
    `SVTEST(unbound)

      // create an iterator that is not bound to a list
      list_fwd_iterator#(int, int_traits) fwd_iter = new(null);
      list_bkwd_iterator#(int, int_traits) bkwd_iter = new(null);

      `FAIL_IF(fwd_iter.first())
      `FAIL_IF(fwd_iter.next())
      `FAIL_IF(fwd_iter.is_last()) 
      `FAIL_IF(!fwd_iter.at_end()) 

      // There is no current item
      `FAIL_IF(fwd_iter.get() != int_traits::empty)
  
      `FAIL_IF(bkwd_iter.last())
      `FAIL_IF(bkwd_iter.prev())
      `FAIL_IF(bkwd_iter.is_first())
      `FAIL_IF(!bkwd_iter.at_beginning())

      // There is no current item
      `FAIL_IF(bkwd_iter.get() != int_traits::empty)
      
    `SVTEST_END

  //--------------------------------------------------------------------
  // bidir_fwd_bkwd
  //--------------------------------------------------------------------
    `SVTEST(bidir_fwd_bkwd)

      list_bidir_iterator#(int, int_traits) iter;
      int unsigned iter_count;
      int unsigned i;

      // Make sure the vector is empty and then Fill it with random
      // numbers
      vec.clear();
      for(i = 0; i < vector_size; i++) begin
        vec.appendc($urandom());
      end

      iter = new(vec);

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the forward direction
      iter_count = 0;
      void'(iter.first());
      while(!iter.at_end()) begin
        void'(iter.next());
        iter_count++;
      end

      `FAIL_IF(iter_count != vector_size)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the forward direction using the
      // alternate idiom
      iter_count = 0;
      void'(iter.first());
      do begin
        void'(iter.next());
        iter_count++;
      end while(!iter.at_end());

      `FAIL_IF(iter_count != vector_size)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the backward direction
      iter_count = 0;
      void'(iter.last());
      while(!iter.at_beginning()) begin
        void'(iter.prev());
        iter_count++;
      end

      `FAIL_IF(iter_count != vector_size)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the backward direction using the
      // alternate idiom
      iter_count = 0;
      void'(iter.last());
      do begin
        void'(iter.prev());
        iter_count++;
      end while(!iter.at_beginning());

      `FAIL_IF(iter_count != vector_size)

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

      // Find the middle of the map
      `FAIL_IF(!iter.first())
      `FAIL_IF(!iter.skip(vec.size()/2))

    `SVTEST_END

  //--------------------------------------------------------------------
  // random
  //--------------------------------------------------------------------
    `SVTEST(random)

      list_random_iterator#(int, int_traits) iter;
      int t;
      int unsigned i;
      int unsigned iterations;
      int array1[];
      int array2[];
      int seed;

      iter = new(vec);

      // randomize the number of iterations
      iterations = $urandom() % vector_size;
      array1 = new [iterations];
      array2 = new [iterations];
      seed = $random();

      // Use the default seed (which is 1) to generate a stream of
      // randomized acesses.
      iter.set_default_seed();
      for(i = 0; i < iterations; i++) begin
        `FAIL_IF(!iter.random())
        t = iter.get();
        array1[i] = t;
      end

      // Change the seed to get a different stream of accesses.
      iter.set_seed(seed);
      for(i = 0; i < iterations; i++) begin
        `FAIL_IF(!iter.random())
        t = iter.get();
        array2[i] = t;
      end

      // Go back to the default seed to get the same stream as the first set.
      iter.set_seed(1);
      for(i = 0; i < iterations; i++) begin
        `FAIL_IF(!iter.random())
        t = iter.get();
        `FAIL_IF(t != array1[i])
      end

      // Repeat the non-default seed to make sure that we can still get the same stream.
      iter.set_seed(seed);
      for(i = 0; i < iterations; i++) begin
        `FAIL_IF(!iter.random())
        t = iter.get();
        `FAIL_IF(t != array2[i])
      end
     
    `SVTEST_END

  //--------------------------------------------------------------------
  // one
  //
  // Check the pathological case where the map has only one entry.  In
  // that situation first() and last() point to the same element.  
  //
  // One_map, created in the setup task, has only one entry in it.
  //--------------------------------------------------------------------
    `SVTEST(one)

      int unsigned iter_count;
      int t;

      vector#(int, int_traits) one_list;

      list_fwd_iterator#(int, int_traits) fwd_iter;
      list_bkwd_iterator#(int, int_traits) bkwd_iter;
      list_bidir_iterator#(int, int_traits) bidir_iter;

      // create a list with a single element in it.
      one_list = new();
      one_list.write(0, $random());

      // create the iterators and bind them to the list
      fwd_iter = new(one_list);
      bkwd_iter = new(one_list);
      bidir_iter = new(one_list);

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // First and last should be the same element
      void'(fwd_iter.first());
      void'(bkwd_iter.last());

      `FAIL_IF(!fwd_iter.is_last())
      `FAIL_IF(!bkwd_iter.is_first())
      `FAIL_IF(fwd_iter.get() != bkwd_iter.get())

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the foward direction
      iter_count = 0;
      void'(fwd_iter.first());
      while(!fwd_iter.at_end()) begin
        void'(fwd_iter.next());
        iter_count++;
      end

      `FAIL_IF(iter_count != 1)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the backward direction
      iter_count = 0;
      void'(bkwd_iter.last());
      while(!bkwd_iter.at_beginning()) begin
        void'(bkwd_iter.prev());
        iter_count++;
      end

      `FAIL_IF(iter_count != 1)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // First and last should be the same element
      void'(bidir_iter.first());
      t = bidir_iter.get();
      void'(bidir_iter.last());

      `FAIL_IF(t != bidir_iter.get())

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the foward direction using the
      // bidirectional iterator
      iter_count = 0;
      void'(bidir_iter.first());
      while(!bidir_iter.at_end()) begin
        void'(bidir_iter.next());
        iter_count++;
      end

      `FAIL_IF(iter_count != 1)

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      // Iterate through the list in the backward direction using the
      // bidirectional iterator
      iter_count = 0;
      void'(bidir_iter.last());
      while(!bidir_iter.at_beginning()) begin
        void'(bidir_iter.prev());
        iter_count++;
      end

      `FAIL_IF(iter_count != 1)

    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule

