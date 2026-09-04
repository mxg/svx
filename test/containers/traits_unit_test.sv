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

module traits_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  string name = "traits_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  void_traits my_void_traits;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_void_traits = new(/* New arguments if needed */);
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
`SVTEST(int_traits_test)

      `FAIL_UNLESS(int_traits::is_void == 0);
      `FAIL_UNLESS(int_traits::is_integral == 1);
      `FAIL_UNLESS(int_traits::is_signed == 1);
      `FAIL_UNLESS(int_traits::is_unsigned == 0);
      `FAIL_UNLESS(int_traits::is_two_state == 1);
      `FAIL_UNLESS(int_traits::is_four_state == 0);
      `FAIL_UNLESS(int_traits::is_real == 0);
      `FAIL_UNLESS(int_traits::is_arithmetic == 1);
      `FAIL_UNLESS(int_traits::is_scalar == 1);
      `FAIL_UNLESS(int_traits::is_class == 0);
      `FAIL_UNLESS(int_traits::is_struct == 0);
      `FAIL_UNLESS(int_traits::is_packed == 0);
      `FAIL_UNLESS(int_traits::is_union == 0);

      `FAIL_UNLESS(int_traits::equal(42, 42));
      `FAIL_UNLESS(int_traits::compare(-19, 38) == -1);
      `FAIL_UNLESS(int_traits::compare(867, 278) == 1);
      `FAIL_UNLESS(int_traits::compare(8654, 8654) == 0);
  
  `SVTEST_END

   `SVTEST(uint64_traits_test)

      `FAIL_UNLESS(uint64_traits::is_void == 0);
      `FAIL_UNLESS(uint64_traits::is_integral == 1);
      `FAIL_UNLESS(uint64_traits::is_signed == 0);
      `FAIL_UNLESS(uint64_traits::is_unsigned == 1);
      `FAIL_UNLESS(uint64_traits::is_two_state == 1);
      `FAIL_UNLESS(uint64_traits::is_four_state == 0);
      `FAIL_UNLESS(uint64_traits::is_real == 0);
      `FAIL_UNLESS(uint64_traits::is_arithmetic == 1);
      `FAIL_UNLESS(uint64_traits::is_scalar == 1);
      `FAIL_UNLESS(uint64_traits::is_class == 0);
      `FAIL_UNLESS(uint64_traits::is_struct == 0);
      `FAIL_UNLESS(uint64_traits::is_packed == 0);
      `FAIL_UNLESS(uint64_traits::is_union == 0);
  
  `SVTEST_END

   `SVTEST(real_traits_test)

      `FAIL_UNLESS(real_traits::is_void == 0);
      `FAIL_UNLESS(real_traits::is_integral == 0);
      `FAIL_UNLESS(real_traits::is_signed == 1);
      `FAIL_UNLESS(real_traits::is_unsigned == 0);
      `FAIL_UNLESS(real_traits::is_two_state == 0);
      `FAIL_UNLESS(real_traits::is_four_state == 0);
      `FAIL_UNLESS(real_traits::is_real == 1);
      `FAIL_UNLESS(real_traits::is_arithmetic == 1);
      `FAIL_UNLESS(real_traits::is_scalar == 1);
      `FAIL_UNLESS(real_traits::is_class == 0);
      `FAIL_UNLESS(real_traits::is_struct == 0);
      `FAIL_UNLESS(real_traits::is_packed == 0);
      `FAIL_UNLESS(real_traits::is_union == 0);

      `FAIL_UNLESS(real_traits::equal(3.14159, 3.14159));
      `FAIL_UNLESS(real_traits::compare(8.52e12, 6.2589e4) == 1);
      `FAIL_UNLESS(real_traits::compare(19.72, 22.9092) == -1);
      `FAIL_UNLESS(real_traits::compare(7.98, 7.98) == 0);

  `SVTEST_END    

  `SVUNIT_TESTS_END

endmodule
