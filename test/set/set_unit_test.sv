`include "svunit_defines.svh"

module set_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"
  

  string name = "set_ut";
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
  // basic
  //--------------------------------------------------------------------
    `SVTEST(basic)
      set#(uint32_t, uint32_traits) s = new();

      s.insert(15);
      s.insert(92);
      s.insert(26);
      s.insert(57);

      `FAIL_UNLESS(s.size() == 4);
      `FAIL_UNLESS(s.contains(92));
      `FAIL_UNLESS(!s.contains(3000));
  
    `SVTEST_END

  //--------------------------------------------------------------------
  // from_vector
  //--------------------------------------------------------------------
    `SVTEST(from_vector)

      vector_uint32 vec = vector_uint32::create('{1, 2, 3, 4, 5});
      set#(uint32_t, uint32_traits) s = new();
      s.from_vector(vec);

      `FAIL_UNLESS(s.contains(1));
      `FAIL_UNLESS(s.contains(2));
      `FAIL_UNLESS(s.contains(3));
      `FAIL_UNLESS(s.contains(4));
      `FAIL_UNLESS(s.contains(5));
      
    `SVTEST_END

  //--------------------------------------------------------------------
  // set_intersection
  //--------------------------------------------------------------------
    `SVTEST(set_intersection)

      set#(uint32_t, uint32_traits) s1;
      set#(uint32_t, uint32_traits) s2;
      set#(uint32_t, uint32_traits) result;

      // Setup first set
      vector_uint32 vec = vector_uint32::create('{1, 2, 3, 4, 5});
      s1 = new();
      s1.from_vector(vec);

      // Setup second set
      vec = vector_uint32::create('{2, 3, 6});
      s2 = new();
      s2.from_vector(vec);
      
      result = s1.intersection(s2);

      `FAIL_UNLESS(!result.contains(1));
      `FAIL_UNLESS(result.contains(2));
      `FAIL_UNLESS(result.contains(3));
      `FAIL_UNLESS(!result.contains(4));
      `FAIL_UNLESS(!result.contains(5));
      `FAIL_UNLESS(!result.contains(6));
  
    `SVTEST_END

  //--------------------------------------------------------------------
  // set_union
  //--------------------------------------------------------------------
    `SVTEST(set_union)

      set#(uint32_t, uint32_traits) s1;
      set#(uint32_t, uint32_traits) s2;
      set#(uint32_t, uint32_traits) result;

      // Setup first set
      vector_uint32 vec = vector_uint32::create('{1, 2, 3});
      s1 = new();
      s1.from_vector(vec);

      // Setup second set
      vec = vector_uint32::create('{2, 3, 4, 5});
      s2 = new();
      s2.from_vector(vec);
      
      result = s1.set_union(s2);

      `FAIL_UNLESS(result.contains(1));
      `FAIL_UNLESS(result.contains(2));
      `FAIL_UNLESS(result.contains(3));
      `FAIL_UNLESS(result.contains(4));
      `FAIL_UNLESS(result.contains(5));
  
    `SVTEST_END

  //--------------------------------------------------------------------
  // set_difference
  //--------------------------------------------------------------------
    `SVTEST(set_difference)

      set#(uint32_t, uint32_traits) s1;
      set#(uint32_t, uint32_traits) s2;
      set#(uint32_t, uint32_traits) result;

      // Setup first set
      vector_uint32 vec = vector_uint32::create('{1, 2, 3, 4, 5});
      s1 = new();
      s1.from_vector(vec);

      // Setup second set
      vec = vector_uint32::create('{0, 3, 5});
      s2 = new();
      s2.from_vector(vec);
      
      result = s1.difference(s2);

      `FAIL_UNLESS(!result.contains(0));
      `FAIL_UNLESS(result.contains(1));
      `FAIL_UNLESS(result.contains(2));
      `FAIL_UNLESS(!result.contains(3));
      `FAIL_UNLESS(result.contains(4));
      `FAIL_UNLESS(!result.contains(5));
  
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
