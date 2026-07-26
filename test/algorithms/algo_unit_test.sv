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
  uint32_vector vec;
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

    `SVTEST(basic_algo)
      list_bidir_uint32_iterator iter;
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
	$write(" %4d", iter.get());
	if(iter.get() < 100)
	  actual_count++;
        void'(iter.next());
      end
      $display();

      p = new();
      count = algo#(uint32_t, uint32_traits)::count(iter, p);
      $display("count predicate = %0d", count);
      `FAIL_IF(count != actual_count)

      p_true = new();
      count = algo#(uint32_t, uint32_traits)::count(iter, p_true);
      $display("count true = %0d", count);
      `FAIL_IF(count != uint32_t'(vector_size))

      p_false = new();
      count = algo#(uint32_t, uint32_traits)::count(iter, p_false);
      $display("count false = %0d", count);
      `FAIL_IF(count != 0)
  
    `SVTEST_END

    `SVTEST(preds)
      uint32_t count;
      bit is_true;
      gt_0 p0 = new();

      // Create a vector from a constant list
      vector#(uint8_t, uint8_traits) v = 
	 vector#(uint8_t, uint8_traits)::create({8'h1, 8'h2, 8'h3, 8'h4, 8'h5, 8'h6, 8'h7, 8'h8});
      list_bidir_uint8_iterator iter = new(v);

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

  `SVUNIT_TESTS_END

endmodule
