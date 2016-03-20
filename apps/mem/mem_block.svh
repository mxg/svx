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
// block
//
// A block is a vector of words, a word is one or more bytes.
//----------------------------------------------------------------------
class mem_block#(int unsigned ADDR_BITS = 32,
		 int unsigned PAGE_BITS = 16,
		 int unsigned BLOCK_BITS = 8,
		 int unsigned WORD_SIZE = 4)
  extends mem_base#(ADDR_BITS, PAGE_BITS, BLOCK_BITS, WORD_SIZE);

  local vector#(byte_t, byte_unsigned_traits) byte_vector;

  function new(mem_t root);
    super.new(root);
    byte_vector = new();
  endfunction

  //--------------------------------------------------------------------
  // write
  //--------------------------------------------------------------------  
  function void write(addr_t addr, word_t data);

    index_t index;
    byte_addr_t word_base;
    byte_t b;
    byte_addr_t byte_addr;
    restrict_t word_restriction;

    if(!is_word_aligned(addr)) begin
      set_error(ERROR_MISALIGNMENT);
      return;
    end

    // check word-level security
    word_restriction = get_restriction(get_aligned_byte_addr(addr));
    if(word_restriction == RESTRICT_WRITE || word_restriction == RESTRICT_READ_WRITE) begin
      set_error(ERROR_WORD_SECURITY_VIOLATION);
      return;
    end

    // big-endian write
    byte_addr = get_byte_addr(addr);
    for(index = 0; index < WORD_SIZE; index++) begin
      word_base = (WORD_SIZE - index) * 8 - 1;
      b = data[word_base -: 8];
      byte_vector.write(byte_addr + index, b);
    end
    
  endfunction

  //--------------------------------------------------------------------
  // read
  //--------------------------------------------------------------------  
  function word_t read(addr_t addr);
    
    byte_addr_t byte_addr;
    byte_addr_t word_base;
    word_t data;
    index_t index;
    byte_t b;
    restrict_t word_restriction;

    if(!is_word_aligned(addr)) begin
      set_error(ERROR_MISALIGNMENT);
      return 0;
    end

    // check word-level security
    word_restriction = get_restriction(get_aligned_byte_addr(addr));
    if(word_restriction == RESTRICT_READ || word_restriction == RESTRICT_READ_WRITE) begin
      set_error(ERROR_WORD_SECURITY_VIOLATION);
      return 0;
    end

    // big-endian read
    byte_addr = get_byte_addr(addr);
    for(index = 0; index < WORD_SIZE; index++) begin
      word_base = (WORD_SIZE - index) * 8 - 1;
      b = byte_vector.read(byte_addr + index);
      data[word_base -: 8] = b;
    end

    return data;
    
  endfunction

  //--------------------------------------------------------------------
  // read byte
  //--------------------------------------------------------------------  
  function byte_t read_byte(addr_t addr);

    restrict_t word_restriction;
    byte_addr_t byte_addr = get_byte_addr(addr);

    // check word-level security
    word_restriction = get_restriction(byte_addr);
    if(word_restriction == RESTRICT_WRITE || word_restriction == RESTRICT_READ_WRITE) begin
      set_error(ERROR_WORD_SECURITY_VIOLATION);
      return 0;
    end
    
    return byte_vector.read(byte_addr);
  endfunction
  
  //--------------------------------------------------------------------
  // write byte
  //--------------------------------------------------------------------  
  function void write_byte(addr_t addr, byte_t data);
    
    restrict_t word_restriction;
    byte_addr_t byte_addr = get_byte_addr(addr);
    
    // check word-level security
    word_restriction = get_restriction(byte_addr);
    if(word_restriction == RESTRICT_READ || word_restriction == RESTRICT_READ_WRITE) begin
      set_error(ERROR_WORD_SECURITY_VIOLATION);
      return;
    end

    byte_vector.write(byte_addr, data);
  endfunction

  //--------------------------------------------------------------------
  // get_addr_restriction
  //--------------------------------------------------------------------
  function restrict_t get_addr_restriction(addr_t addr);
    return get_restriction(get_aligned_byte_addr(addr));
  endfunction

  //--------------------------------------------------------------------
  // dump security map
  //--------------------------------------------------------------------

  function void dump_security(addr_t addr = 0);

    map_fwd_iterator#(addr_t, restrict_t, restrict_traits) iter;
    byte_addr_t word_addr;

    iter = new(security_map);
    iter.first();
    while(!iter.at_end()) begin
      restrict_t r = iter.get();
      word_addr = iter.get_index();
      $display("word: %x  restriction = %s", word_addr, r.name());
      iter.next();
    end

  endfunction
  
  //--------------------------------------------------------------------
  // dump
  //
  // Dump this block
  //--------------------------------------------------------------------
  function void dump(addr_t addr=0);

    list_fwd_iterator#(byte_t, byte_unsigned_traits) byte_iter;
    byte b;
    index_t count;

    byte_iter = new(byte_vector);
    if(!byte_iter.first())
      return;
    
    while(!byte_iter.at_end()) begin
      if(count == 0)
	$write("%x:", addr);
      
      b = byte_iter.get();
      count++;
      addr++;
      $write(" %2x", b);

      if(count >= 16) begin
	count = 0;
	$display();
      end
      
      byte_iter.next();
    end
    $display();
    
  endfunction

endclass
