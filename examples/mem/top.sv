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

import svx::*;
`include "svx_macros.svh"
import mem::*;

//----------------------------------------------------------------------
// class test
//----------------------------------------------------------------------
class test;

  parameter int unsigned ADDR_BITS = 32;
  parameter int unsigned PAGE_BITS = 16;
  parameter int unsigned BLOCK_BITS = 8;
  parameter int unsigned WORD_SIZE = 4;

  typedef mem#(ADDR_BITS, PAGE_BITS, BLOCK_BITS, WORD_SIZE) mem_t;
  mem_t m;
  typedef mem_t::addr_t addr_t;
  typedef mem_t::word_t word_t;

  function new();
    m = new();
  endfunction


  function void run2();
    addr_t base_addr = 'hf300;
    word_t word = 'h98;
    word_t data;

    m.write(base_addr, word);

    data = m.read(base_addr);

    $display("word = %x %s data = %x", word, ((word==data)?"==":"!="), data);

    m.show();
    m.dump();
    
  endfunction
  

  function void run();
    bit [(WORD_SIZE*8)-1:0] data;
    addr_t base_addr = 'h7460_0000;
    signed_index_t i;
    bit[(WORD_SIZE*8)-1:0] array[100];

    m.set_word_restriction(base_addr + 'h3f, RESTRICT_WRITE);
//    m.set_block_restriction(base_addr + 'h0100, RESTRICT_WRITE);

    for(i = 0; i < 100; i++) begin
      data = ($urandom() << 32) | $urandom();
      array[i] = data;
      m.write(base_addr + i*WORD_SIZE, data);
      if(m.last_operation_failed())
	$display("** error: %s", m.get_last_op_string());
    end

    for(i = 0; i < 100 ; i++) begin
      data = m.read(base_addr + i*WORD_SIZE);
      if(m.last_operation_failed())
	$display("** error: %s", m.get_last_op_string());
      else
	if(data != array[i])
	  $display("error %x -- actual = %x expected = %x", base_addr + i*WORD_SIZE, data, array[i]);
    end
    m.show();
    m.dump();
  endfunction
  
endclass

module top;

  initial begin
    test t = new();
    t.run();
  end
  
endmodule
