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

module mem_unit_test;
  `include "svunit_defines.svh"
  import svunit_pkg::svunit_testcase;

  // the svx library
  import svx::*;
  `include "svx_macros.svh"

  // The facility under test
  import mem::*;
  
  import test_utils::*;
  
  string name = "mem_ut";
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
  // parameters
  //
  // Define a memory with erroneous parameters and make sure the errors
  // are caught.
  //--------------------------------------------------------------------
    `SVTEST(parameters)

      mem#(16,6,8,8) m1;
      mem#(16,20,8,2) m2;
      mem#(0,0,0,0) m3;

      m1 = new();
      m2 = new();
      m3 = new();

      `FAIL_UNLESS(m1.last_operation_failed() && (m1.get_last_error() == ERROR_PARAMETERS_WRONG))
      `FAIL_UNLESS(m2.last_operation_failed() && (m2.get_last_error() == ERROR_PARAMETERS_WRONG))
      `FAIL_UNLESS(m3.last_operation_failed() && (m3.get_last_error() == ERROR_PARAMETERS_WRONG))
      
    `SVTEST_END

  //--------------------------------------------------------------------
  // masks
  //--------------------------------------------------------------------
    `SVTEST(masks)

      typedef mem#(16,4,4,2) mem1_t;
      typedef mem#(19,7,3,4) mem2_t;
      typedef mem#(128, 32, 64, 8) mem3_t;

      `FAIL_UNLESS(mem1_t::page_addr_mask  == 'h000f)
      `FAIL_UNLESS(mem1_t::block_addr_mask == 'h000f)
      `FAIL_UNLESS(mem1_t::byte_addr_mask  == 'h00ff)
      `FAIL_UNLESS(mem1_t::word_addr_mask  == 'h0001)

      `FAIL_UNLESS(mem2_t::page_addr_mask  == 'h007f)
      `FAIL_UNLESS(mem2_t::block_addr_mask == 'h0007)
      `FAIL_UNLESS(mem2_t::byte_addr_mask  == 'h01ff)
      `FAIL_UNLESS(mem2_t::word_addr_mask  == 'h0003)

      `FAIL_UNLESS(mem3_t::page_addr_mask  == 'h0000_0000_0000_0000_0000_0000_ffff_ffff)
      `FAIL_UNLESS(mem3_t::block_addr_mask == 'h0000_0000_0000_0000_ffff_ffff_ffff_ffff)
      `FAIL_UNLESS(mem3_t::byte_addr_mask  == 'h0000_0000_0000_0000_0000_0000_ffff_ffff)
      `FAIL_UNLESS(mem3_t::word_addr_mask  == 'h0000_0000_0000_0000_0000_0000_0000_0007)

    `SVTEST_END

  //--------------------------------------------------------------------
  // small_mem
  //
  // Write a swath of memory and read it back.  Compare read data with
  // original data to make sure that it is the same.
  //--------------------------------------------------------------------
    `SVTEST(small_mem)

      typedef mem#(16,4,4,2) mem_t;
      typedef mem_t::addr_t addr_t;
      typedef mem_t::word_t word_t;

      int unsigned i;
      word_t word;
      addr_t base_addr;
      word_t array[1000];
      mem_t m = new();

      base_addr = ($random() & 'hfffc);
      for(i = 0; i < 1000; i++) begin
        word = $random();
        array[i] = word;
        m.write(base_addr + i*2, word);
        if(m.last_operation_failed()) begin
          $display("error %s", m.get_last_op_string());
          `FAIL_IF(m.last_operation_failed())
        end
      end

      for(i = 0; i < 1000; i++) begin
        word = m.read(base_addr + i*2);
        if(m.last_operation_failed()) begin
          $display("error %s", m.get_last_op_string());
          `FAIL_IF(m.last_operation_failed())
        end
        `FAIL_IF(word != array[i])
      end

    `SVTEST_END

  //--------------------------------------------------------------------
  // pages
  //
  // Write some words on each page in the memory
  //--------------------------------------------------------------------
    `SVTEST(pages)

      typedef mem#(16,4,4,2) mem_t;
      typedef mem_t::addr_t addr_t;
      typedef mem_t::word_t word_t;
      typedef mem_t::page_key_t page_key_t;
      typedef mem_t::block_addr_t block_addr_t;
      typedef mem_t::byte_addr_t byte_addr_t;

      mem_t m;

      int unsigned page;
      int unsigned idx;
      block_addr_t block_addr;
      byte_addr_t byte_addr;
      addr_t addr;
      word_t word;

      word_t word_array[(1 << 4)];
      addr_t addr_array[(1 << 4)];

      m = new();

      for(page = 0; page <= page_key_t'('1); page++) begin
        block_addr = $urandom();
        byte_addr = $urandom() & ~(byte_addr_t'('h3));
        addr = m.construct_addr(page, block_addr, byte_addr);
        word = $urandom();
        m.write(addr, word);
        if(m.last_operation_failed()) begin
          $display("error %s", m.get_last_op_string());
          `FAIL_IF(m.last_operation_failed)
        end
      end

      for(idx = 0; idx < page_key_t'('1); idx++) begin
        word = m.read(addr_array[idx]);
        if(m.last_operation_failed()) begin
          $display("error %s", m.get_last_op_string());
          `FAIL_IF(m.last_operation_failed)
        end
        `FAIL_IF(word != word_array[idx])
      end

    `SVTEST_END

  //--------------------------------------------------------------------
  // big_mem
  //
  // Model a large address space
  //--------------------------------------------------------------------
    `SVTEST(big_mem)

      typedef mem#(64,40, 16,8) mem_t;
      typedef mem_t::addr_t addr_t;
      typedef mem_t::word_t word_t;
      typedef mem_t::page_key_t page_key_t;
      typedef mem_t::block_addr_t block_addr_t;
      typedef mem_t::byte_addr_t byte_addr_t;

      mem_t m;
      int unsigned idx;
      addr_t addr;
      word_t word;
      word_t word_array[10000];
      addr_t addr_array[10000];

      m = new();

      for(idx = 0; idx < 10000; idx++) begin
        addr = (($urandom() << 32) | $urandom()) & ~mem_t::word_addr_mask;
        word = ($urandom() << 32) | $urandom();
        word_array[idx] = word;
        addr_array[idx] = addr;
        m.write(addr, word);
        if(m.last_operation_failed()) begin
          $display("error %s", m.get_last_op_string());
          `FAIL_IF(m.last_operation_failed)
        end
      end

      for(idx = 0; idx < 10000; idx++) begin
        word = m.read(addr_array[idx]);
        if(m.last_operation_failed()) begin
          $display("error %s", m.get_last_op_string());
          `FAIL_IF(m.last_operation_failed)
        end
        `FAIL_IF(word != word_array[idx])
      end

    `SVTEST_END

  //--------------------------------------------------------------------
  // security
  //--------------------------------------------------------------------
    `SVTEST(security)
  
      typedef mem#(16,8,4,2) mem_t;
      typedef mem_t::addr_t addr_t;
      typedef mem_t::word_t word_t;
      typedef mem_t::page_key_t page_key_t;
      typedef mem_t::block_addr_t block_addr_t;
      typedef mem_t::byte_addr_t byte_addr_t;

      addr_t addr;
      restrict_t r;

      mem_t m = new();

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      // randomly choose and address on whose page we'll set a
      // restriction.  The address must be word aligned.
      addr = $urandom() & 'hfffc;
      m.set_page_restriction(addr, RESTRICT_READ_WRITE);

      // intentionally violate the restriction
      m.write(addr, ($urandom() & 'hffff));

      `FAIL_UNLESS(m.last_operation_failed() && (m.get_last_error() == ERROR_PAGE_SECURITY_VIOLATION))

      r = m.get_addr_restriction(addr);

      `FAIL_UNLESS(r == RESTRICT_READ_WRITE)
      `FAIL_UNLESS(!m.is_writable(addr))
      `FAIL_UNLESS(!m.is_readable(addr))

      // OK, let's lift the restrictions and try again
      m.clear_page_restriction(addr);
      m.write(addr, ($urandom() & 'hffff));

      `FAIL_IF(m.last_operation_failed())
      `FAIL_UNLESS(m.is_writable(addr))
      `FAIL_UNLESS(m.is_readable(addr))

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      // set a restriction on a random block on a random page
      addr = $urandom() & 'hffff;
      m.set_block_restriction(addr, RESTRICT_READ_WRITE);

      // intentionally violate the restriction
      m.write(addr, ($urandom() & 'hffff));

      `FAIL_UNLESS(m.last_operation_failed() && (m.get_last_error() == ERROR_BLOCK_SECURITY_VIOLATION))

      r = m.get_addr_restriction(addr);

      `FAIL_UNLESS(r == RESTRICT_READ_WRITE)
      `FAIL_UNLESS(!m.is_writable(addr))
      `FAIL_UNLESS(!m.is_readable(addr))

      // OK, let's lift the restrictions and try again
      m.clear_block_restriction(addr);
      m.write(addr, ($urandom() & 'hffff));

      `FAIL_IF(m.last_operation_failed())
      `FAIL_UNLESS(m.is_writable(addr))
      `FAIL_UNLESS(m.is_readable(addr))

      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      // set a restriction on a random word on a random block on a random page
      // make sure the address is word aligned
      addr = $urandom() & 'hfffc;
      m.set_word_restriction(addr, RESTRICT_READ_WRITE);

      // intentionally violate the restriction
      m.write(addr, ($urandom() & 'hffff));

      `FAIL_UNLESS(m.last_operation_failed() && (m.get_last_error() == ERROR_WORD_SECURITY_VIOLATION))

      r = m.get_addr_restriction(addr);

      `FAIL_UNLESS(r == RESTRICT_READ_WRITE)
      `FAIL_UNLESS(!m.is_writable(addr))
      `FAIL_UNLESS(!m.is_readable(addr))

      // We should be able to write the address before and the one after
      // the restricted address.
      m.write(addr-2, ($urandom() & 'hffff));
      `FAIL_IF(m.last_operation_failed())

      m.write(addr+2, ($urandom() & 'hffff));
      `FAIL_IF(m.last_operation_failed())

      // OK, let's lift the restrictions and try again
      m.clear_word_restriction(addr);
      m.write(addr, ($urandom() & 'hffff));

      `FAIL_IF(m.last_operation_failed())
      `FAIL_UNLESS(m.is_writable(addr))
      `FAIL_UNLESS(m.is_readable(addr))

    `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
