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

module vector_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  import test_utils::*;

  string name = "vector_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  vector#(int32_t, int32_traits) vi;

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    vi = new();
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


  parameter index_t VECTOR_SIZE = 17;
  parameter index_t OTHER_SIZE = 9;

  `SVUNIT_TESTS_BEGIN

  // Note:
  //
  //  The tests are arranged in the order in which they must be run.
  //  Some tests depend on the state of the previous test


  //--------------------------------------------------------------------
  // zero_size
  //
  // A newly created empty vectore should have a size of zero
  //--------------------------------------------------------------------
    `SVTEST(zero_size)
      `FAIL_IF(vi.size() != 0)
    `SVTEST_END

  //--------------------------------------------------------------------
  // fill_vector
  //
  // Populate the vector with a fixed number of items with known
  // values.  Ensure that the vector is filled correctly and each item
  // is at the right index.  Tests the read() and write() methods.
  // Also tests array extension -- the extend() method.
  //--------------------------------------------------------------------
    `SVTEST(fill_vector)
      begin
        index_t i;
        int32_t value;
        int32_t array[VECTOR_SIZE];

        for(i = 0; i < VECTOR_SIZE; i++) begin
          value = $random();
          array[i[4:0]] = value;
          vi.write(i, value);
        end

        `FAIL_IF(vi.size() != VECTOR_SIZE);

        // check to see if everything in the vector is in the right place
        for(i = 0; i < VECTOR_SIZE; i++) begin
	  value = vi.read(i);
          `FAIL_IF(!int32_traits::equal(value,array[i[4:0]]))
        end

      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // clone
  //
  // Clone the vector and ensure that the cloned copy is identical to
  // the original
  //--------------------------------------------------------------------
    `SVTEST(clone)
      begin
        index_t i;
        vector#(int32_t, int32_traits) cloned_vector;
        cloned_vector = vi.clone();

        `FAIL_IF(vi.size() != cloned_vector.size())
	`FAIL_IF(!vi.equal(cloned_vector))

	// Arbitrarily change one of the items in the cloned vector.
	// Now, vi and cloned_vector should NOT be equal
	cloned_vector.write(1, cloned_vector.read(1) + 7);
	`FAIL_IF(vi.equal(cloned_vector))
      end

    `SVTEST_END

  //--------------------------------------------------------------------
  // real_vector
  //--------------------------------------------------------------------
    `SVTEST(real_vector_test)
      begin
        index_t i;
        vector#(real, real_traits) vr = new();
        real array[VECTOR_SIZE];
        real value;

        for(i = 0; i < VECTOR_SIZE; i++) begin
          value = real'(i * 20);
          array[i[4:0]] = value;
          vr.write(i, value);
        end

        `FAIL_IF(vr.size() != VECTOR_SIZE)

        for(i = 0; i < VECTOR_SIZE; i++) begin
          `FAIL_IF(!real_traits::equal(vr.read(i), array[i[4:0]]))
        end
      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // string_vector
  //--------------------------------------------------------------------
    `SVTEST(string_vector_test)
      begin
        rand_string rs; // random string generator
        index_t i;
        vector#(string, string_traits) vs = new();
        string array[VECTOR_SIZE];
        string value;

        rs = new();
        for(i = 0; i < VECTOR_SIZE; i++) begin
          value = rs.rand_string();
          array[i[4:0]] = value;
          vs.write(i, value);
        end

        `FAIL_IF(vs.size() != VECTOR_SIZE)

        for(i = 0; i < VECTOR_SIZE; i++) begin
          `FAIL_IF(!string_traits::equal(vs.read(i), array[i[4:0]]))
        end
      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // append
  //--------------------------------------------------------------------
    `SVTEST(append)
      begin
        index_t i;
        uint32_vector v_a = new();
        uint32_vector v_b = new();
        uint32_t value;
        uint32_t array[VECTOR_SIZE + OTHER_SIZE];
        v_a.extend(VECTOR_SIZE);
        v_b.extend(OTHER_SIZE);

        // Fill vector A
        for(i = 0; i < VECTOR_SIZE; i++) begin
          value = $urandom();
          array[i[4:0]] = value;
          v_a.write(i, int32_t'(value));
        end

        // Fill vector B
        for(i = 0; i < OTHER_SIZE; i++) begin
          value = $urandom();
          array[5'(VECTOR_SIZE + i)] = value;
          v_b.write(i, int32_t'(value));
        end

        // Append B to A
        v_a.append(v_b);

        // Now, let's see if the combined vector is correct.
        `FAIL_IF(v_a.size() != (VECTOR_SIZE + OTHER_SIZE))

        for(i = 0; i < (VECTOR_SIZE + OTHER_SIZE); i++) begin
          `FAIL_IF(!int32_traits::equal(v_a.read(i), array[i[4:0]]))
        end

      end
    `SVTEST_END


  //--------------------------------------------------------------------
  // appendc
  //
  // OK, we'll do the same thing as the append test, except we will use
  // appendc to add new items to the end of the vector
  //--------------------------------------------------------------------
    `SVTEST(appendc)
      begin
        index_t i;
        uint32_vector v_a = new();
        uint32_t value;
        uint32_t array[VECTOR_SIZE + OTHER_SIZE];
        v_a.extend(VECTOR_SIZE);

        // Fill vector A
        for(i = 0; i < VECTOR_SIZE; i++) begin
          value = $urandom();
          array[i[4:0]] = value;
          v_a.write(i, value);
        end

        // Append items to v_a
        for(i = 0; i < OTHER_SIZE; i++) begin
          value = $urandom();
          array[5'(VECTOR_SIZE + i)] = value;
          v_a.appendc(value);
        end

        // Now, let's see of the combined vector is correct.
        `FAIL_IF(v_a.size() != (VECTOR_SIZE + OTHER_SIZE))

        for(i = 0; i < (VECTOR_SIZE + OTHER_SIZE); i++) begin
          `FAIL_IF(!int32_traits::equal(v_a.read(i),array[i[4:0]]))
        end

      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // sort
  //
  // Make sure the sort function works correctly
  //--------------------------------------------------------------------
    `SVTEST(sort)
      begin
	uint32_t a;
	uint32_t b;

	vi.sort();
	`FAIL_UNLESS(vi.size() == VECTOR_SIZE);

	for(index_t ix = 0; ix < (VECTOR_SIZE-1); ix++) begin
	  a = vi.read(ix);
	  b = vi.read(ix+1);
	end
      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // out_of_bounds
  //
  // Ensure that reading and writing outside the bounds of a vector
  // does the right thing.
  //--------------------------------------------------------------------
    `SVTEST(out_of_bounds)
      begin
        // Reading outside the bounds of the vector should return the
        // empty element.xs
	index_t ix = VECTOR_SIZE + 5;
	uint32_t a = vi.read(ix);
	`FAIL_UNLESS(a == int32_traits::empty);

        // Writing outside the bounds of the vector should extend its
        // size.
	a = $urandom() % 100;
	vi.write(ix, a);
	`FAIL_UNLESS(vi.size() == (VECTOR_SIZE + 5 + 1));
      end
    `SVTEST_END

  //--------------------------------------------------------------------
  // clear
  //
  // test the clear() method by calling it and confirming that all of
  // the items have been cleared
  //--------------------------------------------------------------------
    `SVTEST(clear)
      begin
        vi.clear();
        `FAIL_IF(vi.size() != 0)
      end
    `SVTEST_END
      
  `SVUNIT_TESTS_END

endmodule
