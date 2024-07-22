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

module mem_field_unit_test;
  `include "svunit_defines.svh"
  import svunit_pkg::svunit_testcase;

    // the svx library
  import svx::*;
  `include "svx_macros.svh"

  // the facility under test
  import mem_map::*;

  import test_utils::*;
  
  string name = "mem_map_ut";
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

  // define some memory spaces we'll use in the tests

  class region extends mem_region#(16);
    function new(string name, mem_space_t parent, addr_t _offset, size_t _size);
      super.new(name, parent, _offset, _size);
    endfunction
  endclass

  class register extends mem_register#(16);
    function new(string name, mem_space_t parent, addr_t _offset, size_t _size);
      super.new(name, parent, _offset, _size);
    endfunction
  endclass

  class treg extends mem_register #(16);

    function new(string name, mem_space_t parent, addr_t _offset, size_t _size);
      super.new(name, parent, _offset, _size);
    endfunction

  endclass

  class region_with_overlaps extends mem_region #(16);

    treg r1;
    treg r2;
    treg r3;
    treg r4;

    function new(string name, mem_space#(16) parent, addr_t _offset, size_t _size);
      super.new(name, parent, _offset, _size);

      r1 = new("r1", this, 'h08, 4);
      r2 = new("r2", this, 'h06, 4); // overlaps on the left
      r3 = new("r3", this, 'h0a, 2); // overlaps on the right
      r4 = new("r4", this, 'h09, 1); // overlaps in the middle
      
    endfunction
  endclass

  class region_no_overlaps extends mem_region #(16);

    treg r1;
    treg r2;
    treg r3;
    treg r4;

    function new(string name, mem_space#(16) parent, addr_t _offset, size_t _size);
      super.new(name, parent, _offset, _size);

      r1 = new("r1", this, 'h08, 4);
      r2 = new("r2", this, 'h00, 8);
      r3 = new("r3", this, 'h0c, 2);
      r4 = new("r4", this, 'h0f, 1);
      
    endfunction
  endclass

  class region_some_overlaps extends mem_region #(16);

    treg r1;
    treg r2;
    treg r3;
    treg r4;

    function new(string name, mem_space#(16) parent, addr_t _offset, size_t _size);
      super.new(name, parent, _offset, _size);

      r1 = new("r1", this, 'hf0, 4);
      r2 = new("r2", this, 'hf0, 8);
      r3 = new("r3", this, 'hf8, 2);
      r4 = new("r4", this, 'hff, 1);
      
    endfunction
  endclass

  class reg32 extends mem_register#(32);
    function new(string name, mem_space_t parent, addr_t _offset, size_t _size);
      super.new(name, parent, _offset, _size);
    endfunction
  endclass

  class peripheral extends mem_region#(32);

    reg32 data;
    reg32 ctrl;
    reg32 status;

    function new(string name, mem_space_t parent, addr_t _offset, size_t _size);
      super.new(name, parent, _offset, _size);

      data = new("data", this, 0, 4);
      ctrl = new("ctrl", this, 4, 4);
      status = new("status", this, 8, 4);
    endfunction
  endclass

  class a_bus extends mem_view#(32);

    peripheral p1;
    peripheral p2;

    function new(string name, mem_space_t parent, addr_t _offset, size_t _size);
      super.new(name, parent, _offset, _size);

      p1 = new("p1", this, 'h0000_ff00, 'h0000_00ff);
      p2 = new("p2", this, 'h0000_f100, 'h0000_00ff);
    endfunction
  endclass

  class b_bus extends mem_view#(32);
    function new(string name, mem_space_t parent, addr_t _offset, size_t _size);
      super.new(name, parent, _offset, _size);
    endfunction
  endclass

  class sys_region extends mem_region #(32)	;

    a_bus a;
    b_bus b;

  function new(string name, mem_space_t parent, addr_t _offset, size_t _size);
    super.new(name, parent, _offset, _size);

    a = new("bus_a", this, 'h0000_0000, 'h1_0000_0000);
    b = new("bus_b", this, 'h0000_0000, 'h1_0000_0000);
  endfunction

  endclass



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
  // construction
  //--------------------------------------------------------------------
    `SVTEST(construction)

      
      mem_region#(16) rg;
      mem_region#(16) sub_rg;

      rg = new("top", null, 'h0000, 'h0100);
      rg.add_register("ra", 'h0000, 'h0004);
      `FAIL_IF(rg.get_error())
   
      rg.add_register("rb", 'h0004, 'h0004);
      `FAIL_IF(rg.get_error())

      rg.add_register("rc", 'h0008, 'h0004);
      `FAIL_IF(rg.get_error())

      rg.add_register("rd", 'h000c, 'h0004);
      `FAIL_IF(rg.get_error())

      // create a disconnected sub-region
      sub_rg = new("sub_region_1", null,'h1000, 'h1000);
      
      sub_rg.add_register("rf", 'h0000, 'h0004);
      `FAIL_IF(rg.get_error())

      sub_rg.add_register("rg", 'h0004, 'h0004);
      `FAIL_IF(rg.get_error())

      // connect the sub-region into the top region
      rg.insert_space(sub_rg);

      void'(rg.calculate_and_check());
      `FAIL_IF(rg.get_error())
      
    `SVTEST_END

  //--------------------------------------------------------------------
  // overlap
  //--------------------------------------------------------------------
    `SVTEST(overlap)
      bit ok;
      bit overlap;
      region_with_overlaps rg;

      rg = new("region_with_overlaps", null, 0, 32);
      ok = rg.calculate_and_check();
      `FAIL_IF(ok)

      overlap = rg.overlaps(rg.r1, rg.r2); // should overlap
      `FAIL_IF(!overlap)

      overlap = rg.overlaps(rg.r1, rg.r3); // should overlap
      `FAIL_IF(!overlap)

      overlap = rg.overlaps(rg.r1, rg.r4); // should overlap
      `FAIL_IF(!overlap)

      rg.clear_error();
      overlap = rg.overlaps(rg.r2, rg.r3); // should NOT overlap
      `FAIL_IF(overlap)

      overlap = rg.overlaps(rg.r2, rg.r4); // should overlap
      `FAIL_IF(!overlap)

      overlap = rg.overlaps(rg.r3, rg.r4); // should NOT overlap
      `FAIL_IF(overlap)

    `SVTEST_END

  //--------------------------------------------------------------------
  // no_overlap
  //--------------------------------------------------------------------
    `SVTEST(no_overlap)
      bit ok;
      bit overlap;
      region_no_overlaps rg;

      rg = new("region_no_overlaps", null, 0, 32);
      ok = rg.calculate_and_check();
      `FAIL_IF(!ok)

      overlap = rg.overlaps(rg.r1, rg.r2);
      `FAIL_IF(overlap)

      overlap = rg.overlaps(rg.r1, rg.r3);
      `FAIL_IF(overlap)

      overlap = rg.overlaps(rg.r1, rg.r4);
      `FAIL_IF(overlap)

      overlap = rg.overlaps(rg.r2, rg.r3);
      `FAIL_IF(overlap)

      overlap = rg.overlaps(rg.r2, rg.r4);
      `FAIL_IF(overlap)

      overlap = rg.overlaps(rg.r3, rg.r4);
      `FAIL_IF(overlap)

    `SVTEST_END

  //--------------------------------------------------------------------
  // some_overlap
  //--------------------------------------------------------------------
    `SVTEST(some_overlap)
      bit ok;
      bit overlap;
      region_some_overlaps rg;

      rg = new("region_some_overlaps", null, 0, 32);
      ok = rg.calculate_and_check();
      `FAIL_IF(ok)

      overlap = rg.overlaps(rg.r1, rg.r2); // should overlap
      `FAIL_IF(!overlap)

      overlap = rg.overlaps(rg.r1, rg.r3);
      `FAIL_IF(overlap)

      overlap = rg.overlaps(rg.r1, rg.r4);
      `FAIL_IF(overlap)

      overlap = rg.overlaps(rg.r2, rg.r3);
      `FAIL_IF(overlap)

      overlap = rg.overlaps(rg.r2, rg.r4);
      `FAIL_IF(overlap)

      overlap = rg.overlaps(rg.r3, rg.r4);
      `FAIL_IF(overlap)

    `SVTEST_END

  //--------------------------------------------------------------------
  // hier
  //--------------------------------------------------------------------
    `SVTEST(hier)
      sys_region sys;

      sys = new("system", null, 'h0000_0000, 'h1_0000_0000);
      void'(sys.calculate_and_check());
      sys.dump();



    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
