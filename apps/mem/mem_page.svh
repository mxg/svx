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
// page
//
// A page is a vector of blocks
//----------------------------------------------------------------------
class mem_page#(int unsigned ADDR_BITS = 32,
		int unsigned PAGE_BITS = 16,
		int unsigned BLOCK_BITS = 8,
		int unsigned WORD_SIZE = 4)
  extends mem_base#(ADDR_BITS, PAGE_BITS, BLOCK_BITS, WORD_SIZE);

  typedef mem_block#(ADDR_BITS, PAGE_BITS, BLOCK_BITS, WORD_SIZE) block_t;
  typedef map#(block_addr_t, block_t, class_traits#(block_t)) block_map_t;

  local block_map_t block_map;

  function new(mem_t root);
    super.new(root);
    block_map = new();
  endfunction

  //--------------------------------------------------------------------
  // write
  //--------------------------------------------------------------------
  function void write(addr_t addr, word_t data);

    restrict_t block_restriction;
    block_t block;
    block_addr_t block_addr;

    // check block-level security
    block_addr = get_block_addr(addr);
    block_restriction = get_restriction(block_addr);
    if(block_restriction == RESTRICT_WRITE || block_restriction == RESTRICT_READ_WRITE) begin
      set_error(ERROR_BLOCK_SECURITY_VIOLATION);
      return;
    end    
    
    // If the block doesn't exist, add it
    block = block_map.get(block_addr);
    if(block == null) begin
      block = new(mem_root);
      block_map.insert(block_addr, block);
    end

    block.write(addr, data);
    
  endfunction

  //--------------------------------------------------------------------
  // read
  //--------------------------------------------------------------------
  function word_t read(addr_t addr);

    restrict_t block_restriction;
    block_t block;
    block_addr_t block_addr;

    block_addr = get_block_addr(addr);
    block_restriction = get_restriction(block_addr);
    if(block_restriction == RESTRICT_READ || block_restriction == RESTRICT_READ_WRITE) begin
      set_error(ERROR_BLOCK_SECURITY_VIOLATION);
      return 0;
    end
    
    // If the block doesn't exist, return 0;
    block = block_map.get(block_addr);
    if(block == null)
      return 0;

    return block.read(addr);
    
  endfunction
  
  //--------------------------------------------------------------------
  // write byte
  //--------------------------------------------------------------------  
  function void write_byte(addr_t addr, byte_t data);

    restrict_t block_restriction;
    block_t block;
    block_addr_t block_addr;

    block_addr = get_block_addr(addr);
    block_restriction = get_restriction(block_addr);
    if(block_restriction == RESTRICT_WRITE || block_restriction == RESTRICT_READ_WRITE) begin
      set_error(ERROR_BLOCK_SECURITY_VIOLATION);
      return;
    end

    // If the block doesn't exist, add it
    block = block_map.get(block_addr);
    if(block == null) begin
      block = new(mem_root);
      block_map.insert(block_addr, block);
    end

    block.write_byte(addr, data);
  endfunction

  //--------------------------------------------------------------------
  // read byte
  //--------------------------------------------------------------------  
  function byte_t read_byte(addr_t addr);

    restrict_t block_restriction;
    block_t block;
    block_addr_t block_addr;

    block_addr = get_block_addr(addr);
    block_restriction = get_restriction(block_addr);
    if(block_restriction == RESTRICT_READ || block_restriction == RESTRICT_READ_WRITE) begin
      set_error(ERROR_BLOCK_SECURITY_VIOLATION);
      return 0;
    end

    // If the block doesn't exist, return 0;
    block = block_map.get(block_addr);
    if(block == null) begin
      return 0;
    end

    return block.read_byte(addr);

  endfunction

  //======================================================================
  //
  // security interface
  //
  //======================================================================

  //--------------------------------------------------------------------
  // Word-level security
  //--------------------------------------------------------------------
  
  function void set_word_restriction(addr_t addr, restrict_t r);

    block_addr_t block_addr = get_block_addr(addr);
    block_t block  = block_map.get(block_addr);

    // Retrieve block to set security.  If block doesn't exist, then add
    // it.
    if(block == null) begin
      block = new(mem_root);
      block_map.insert(block_addr, block);
    end

    block.set_restriction(get_aligned_byte_addr(addr), r);
    
  endfunction


  function clear_word_restriction(addr_t addr);

    block_t block = block_map.get(get_block_addr(addr));

    if(block != null)
      block.clear_restriction(get_aligned_byte_addr(addr));

  endfunction

  function restrict_t get_addr_restriction(addr_t addr);
    
    block_t block;
    restrict_t r;

    r = get_restriction(get_block_addr(addr));
    if(r != RESTRICT_NONE)
      return r;

    block = block_map.get(get_block_addr(addr));
    if(block != null)
      return block.get_addr_restriction(addr);
    else
      return RESTRICT_NONE;

  endfunction

  //--------------------------------------------------------------------
  // dump security map
  //--------------------------------------------------------------------

  function void dump_security(addr_t addr = 0);

    map_fwd_iterator#(addr_t, restrict_t, restrict_traits) iter;
    map_fwd_iterator#(block_addr_t, block_t, class_traits#(block_t)) block_iter;
    block_addr_t block_addr;
    block_t block;
    page_key_t page_key;

    iter = new(security_map);
    iter.first();
    while(!iter.at_end()) begin
      restrict_t r = iter.get();
      page_key = iter.get_index();
      $display("block: %x  restriction = %s", page_key, r.name());
      iter.next();
    end

    // Traverse the page map
    block_iter = new(block_map);
    block_iter.first();
    while(!block_iter.at_end()) begin
      block = block_iter.get();
      block_addr = block_iter.get_index();
      $display("security map for block %x", block_addr);
      block.dump_security(construct_addr(get_page_key(addr), block_addr, 0));
      block_iter.next();
    end
    
  endfunction

  //--------------------------------------------------------------------
  // dump
  //--------------------------------------------------------------------
  function void dump(addr_t addr=0);

    map_fwd_iterator#(block_addr_t, block_t, class_traits#(block_t)) block_iter;
    block_t block;
    page_key_t page_key;

    page_key = get_page_key(addr);

    block_iter = new(block_map);
    block_iter.first();
    while(!block_iter.at_end()) begin
      block = block_iter.get();
      $display("block addr = %x", block_iter.get_index());
      if(block != null)
	block.dump(construct_addr(page_key, block_iter.get_index(), 0));
      block_iter.next();
    end
    
  endfunction
  
endclass
