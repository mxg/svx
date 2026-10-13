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

module ctypes_unit_test;
  import svunit_pkg::svunit_testcase;

  // the library we are testing
  import svx::*;
 `include "svx_macros.svh"

  import test_utils::*;

  string name = "ctypes_ut";
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
  // alphanumeric
  //--------------------------------------------------------------------

    `SVTEST(alphanumeric)
      byte c;

      for(c = "A"; c <= "Z"; c++) begin
        `FAIL_IF(!`isalpha(c))
        `FAIL_IF(!`isupper(c))
        `FAIL_IF(!`isalnum(c))
        `FAIL_IF(!`isprint(c))
      end

      for(c = "a"; c <= "z"; c++) begin
        `FAIL_IF(!`isalpha(c))
        `FAIL_IF(!`islower(c))
        `FAIL_IF(!`isalnum(c))
        `FAIL_IF(!`isprint(c))
      end

      for(c = "0"; c <= "9"; c++) begin
        `FAIL_IF(!`isdigit(c))
        `FAIL_IF(!`isxdigit(c))
        `FAIL_IF(!`isalnum(c))
        `FAIL_IF(!`isprint(c))
      end

      for(c = "A"; c <= "F"; c++) begin
        `FAIL_IF(!`isxdigit(c))
        `FAIL_IF(!`isalnum(c))
        `FAIL_IF(!`isprint(c))
      end

      for(c = "a"; c <= "f"; c++) begin
        `FAIL_IF(!`isxdigit(c))
        `FAIL_IF(!`isalnum(c))
        `FAIL_IF(!`isprint(c))
      end

      for(c = "0"; c <= "7"; c++) begin
        `FAIL_IF(!`isodigit(c))
        `FAIL_IF(!`isalnum(c))
        `FAIL_IF(!`isprint(c))
      end

    `SVTEST_END

  //--------------------------------------------------------------------
  // punctuation
  //--------------------------------------------------------------------
    `SVTEST(punctuation)
      byte c;

      for(c = 33; c <= 47; c++) begin
        `FAIL_IF(!`ispunct(c))
        `FAIL_IF(!`isprint(c))
      end

      for(c = 58; c <= 64; c++) begin
        `FAIL_IF(!`ispunct(c))
        `FAIL_IF(!`isprint(c))
      end

      for(c = 123; c <= 126; c++) begin
        `FAIL_IF(!`ispunct(c))
        `FAIL_IF(!`isprint(c))
      end

    `SVTEST_END

  //--------------------------------------------------------------------
  // punctuation
  //--------------------------------------------------------------------
    `SVTEST(special)
      byte c;
      byte chars[4] = {"x", "X", "z", "Z"};
      int unsigned i;

      foreach(chars[i]) begin
        c = chars[i];
        `FAIL_IF(!`islogic(c))
        `FAIL_IF(!`isprint(c))
      end

      for(c = 0; c <= 30; c++) begin
        `FAIL_IF(`isprint(c))
      end

      for(c = 9; c <= 13; c++) begin
        `FAIL_IF(`isprint(c))
        `FAIL_IF(!`isspace(c))
      end

      c = " ";
      `FAIL_IF(!`isblank(c))
      `FAIL_IF(!`isspace(c))

      c = 127;
      `FAIL_IF(`isalpha(c))
      `FAIL_IF(`isblank(c))
      `FAIL_IF(`isupper(c))
      `FAIL_IF(`islower(c))
      `FAIL_IF(`isdigit(c))
      `FAIL_IF(`isxdigit(c))
      `FAIL_IF(`isspace(c))
      `FAIL_IF(`ispunct(c))
      `FAIL_IF(`isalnum(c))
      `FAIL_IF(`isprint(c))
      `FAIL_IF(`isodigit(c))
      `FAIL_IF(`islogic(c))
  
    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
