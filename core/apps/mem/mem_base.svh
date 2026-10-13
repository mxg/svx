
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

typedef class mem;

virtual class mem_base#(uint32_t ADDR_BITS = 32,
			uint32_t PAGE_BITS = 16,
			uint32_t BLOCK_BITS = 8,
			uint32_t WORD_SIZE = 4)
  extends object;

  typedef mem#(ADDR_BITS, PAGE_BITS, BLOCK_BITS, WORD_SIZE) mem_t;
  typedef bit [ADDR_BITS-1:0] addr_t;
  typedef bit [(WORD_SIZE*8)-1:0] word_t;
  typedef byte unsigned byte_t;

  // Address of a page
  typedef bit [PAGE_BITS-1:0] page_key_t;

  // Address of a block within a page
  typedef bit [BLOCK_BITS-1:0] block_addr_t;

  // Address of a byte within a block
  localparam  uint32_t BYTE_ADDR_BITS = ADDR_BITS - PAGE_BITS - BLOCK_BITS;
  typedef bit [BYTE_ADDR_BITS-1:0] byte_addr_t;
 
  // Masks for retrieving the various parts of the address
  static const addr_t page_addr_mask  = ((addr_t'('1)) >> (ADDR_BITS - PAGE_BITS));
  static const addr_t block_addr_mask = ((addr_t'('1)) >> (ADDR_BITS - BLOCK_BITS));
  static const addr_t byte_addr_mask  = ((addr_t'('1)) >> (PAGE_BITS + BLOCK_BITS));
  static const addr_t word_addr_mask  = ((addr_t'('1)) >> (ADDR_BITS - $clog2(WORD_SIZE)));

  // Handle to the top memory object.  This is used for error reporting only.
  protected mem_t mem_root;

  // Security map -- maps addresses to restrictions
  protected map#(addr_t, restrict_t, restrict_traits) security_map;

  //--------------------------------------------------------------------
  // constructor
  //--------------------------------------------------------------------
  function new(mem_t root);
    mem_root = root;
    if(!check_parameters())
      set_error(ERROR_PARAMETERS_WRONG);
    security_map = new();
  endfunction

  //--------------------------------------------------------------------
  // function to do error checking on the class parameters.  Let's make
  // sure they are within the correct ranges and their values are
  // mutually consistent.
  // --------------------------------------------------------------------
  local function bit check_parameters();

    uint32_t word_bits;
    uint32_t one_bits;
    uint32_t word_size;
    bit ok = 1;

    ok &= ((ADDR_BITS > 0) && (PAGE_BITS > 0) && (BLOCK_BITS > 0) &&(WORD_SIZE > 0));

    // Count the number of 1 bits in WORD_SIZE.  There can only be one
    // if the value is indeed a power of 2.
    word_size = WORD_SIZE;
    while(word_size > 0) begin
      one_bits += word_size & 'h1;  // the low order bit
      word_size >>= 1;
    end

    ok &= (one_bits == 1);

    word_bits = $clog2(WORD_SIZE);
    ok &= (ADDR_BITS > (PAGE_BITS + BLOCK_BITS + word_bits));

    ok &= ( (ADDR_BITS - PAGE_BITS - BLOCK_BITS) > word_bits );

    return ok;
    
  endfunction

  //--------------------------------------------------------------------
  // Address part calculation interface
  //--------------------------------------------------------------------
  function page_key_t get_page_key(addr_t addr);
    addr_t x = (addr >> (addr_t'(ADDR_BITS) - addr_t'(PAGE_BITS))) & addr_t'(page_addr_mask);
    return page_key_t'(x);
//    return page_key_t'((addr >> addr_t'(ADDR_BITS - PAGE_BITS)) & addr_t'(page_addr_mask));
  endfunction

  function block_addr_t get_block_addr(addr_t addr);
    addr_t x = (addr >> addr_t'(BYTE_ADDR_BITS)) & addr_t'(block_addr_mask);
    return block_addr_t'(x);
//    return block_addr_t'((addr >> addr_t(BYTE_ADDR_BITS)) & addr_t'(block_addr_mask));
  endfunction

  function byte_addr_t get_byte_addr(addr_t addr);
    return byte_addr_t'(addr & byte_addr_mask);
  endfunction

  function byte_addr_t get_aligned_byte_addr(addr_t addr);
    return byte_addr_t'(addr & byte_addr_mask & ~word_addr_mask);
  endfunction

  function bit is_word_aligned(addr_t addr);
    return ((addr & word_addr_mask) == 0);
  endfunction

  function addr_t construct_addr(page_key_t page_key,
                                           block_addr_t block_addr,
                                           byte_addr_t byte_addr);
    return addr_t'((addr_t'(page_key) << (ADDR_BITS - PAGE_BITS)) |
		   (addr_t'(block_addr) << (ADDR_BITS - PAGE_BITS - BLOCK_BITS)) |
		   (addr_t'(byte_addr)));
  endfunction

  //====================================================================
  //
  // memory access interface
  //
  //====================================================================
  
  pure virtual function word_t read(addr_t addr);
  pure virtual function void write(addr_t addr, word_t data);
  pure virtual function byte_t read_byte(addr_t addr);
  pure virtual function void write_byte(addr_t addr, byte_t data);

  //--------------------------------------------------------------------
  // error reporting interface
  //--------------------------------------------------------------------
  function void set_error(error_t err);
    mem_root.set_last_error(err);
  endfunction

  //====================================================================
  //
  // Security Interface
  //
  // Every memory component has a security map that maps addresses to
  // restrictions.  The scope of the resiction is dependent on the type
  // of component.  The security map in the top-level component
  // restricts pages; the security map in the page component restricts
  // blocks; and the security map in the block component restricts
  // words.  The structure of the map is the same in each component
  // which is why we put the map and the access functions in the base
  // class.
  //
  //====================================================================

  //  set a security restriction in the local component secuirity map
  virtual function void set_restriction(addr_t addr, restrict_t r);
    void'(security_map.insert(addr, r));
  endfunction

  // Retrieve the security restriction in the local component security
  // map, if there is one.  Because the data structure of the security
  // map is map#() we know that if an entry does not exist for the
  // requested address then the empty element will be returned.  In this
  // case, using restrict traits, the empty element is RESTRICT_NONE.
  virtual function restrict_t get_restriction(addr_t addr);
    return security_map.get(addr);
  endfunction

  // clear the security restirction in the local component security map,
  // if there is one.
  virtual function void clear_restriction(addr_t addr);
    void'(security_map.delete(addr));
  endfunction

  // For a given address, return any security restriction associated
  // with that address, whether it comes from the page-, block-, or
  // word-level.  Each memory component is expected to provide this
  // function.  Users should only call the one in the top-level memory
  // component (i.e. mem#()) and not use the ones in the lower-level
  // components.
  pure virtual function restrict_t get_addr_restriction(addr_t addr);

  //====================================================================
  //
  // Dump Interface
  //
  // Each memory component is expected to dump its memory contents and
  // its security map.  The pure virtual functions provide the interface
  // for these operations. Only the function in the top-level component
  // should be called by the user.
  //====================================================================

  pure virtual function void dump_security(addr_t addr = 0);
  pure virtual function void dump(addr_t addr = 0);

  //====================================================================
  //
  // Debugging Interface
  //
  //====================================================================

  //--------------------------------------------------------------------
  // show the components of an address
  //--------------------------------------------------------------------
  function void show_addr(addr_t addr);
    $display("addr  = %b %x", addr, addr);
    $display("page  = %b %x", get_page_key(addr), get_page_key(addr));
    $display("block = %b %x", get_block_addr(addr), get_block_addr(addr));
    $display("byte  = %b %x", get_byte_addr(addr), get_byte_addr(addr));
  endfunction

  //--------------------------------------------------------------------
  // Show the memory organization. 
  //--------------------------------------------------------------------
  function void show();
    $display("address   = %0d bits", ADDR_BITS);
    $display("page      = %0d bits", PAGE_BITS);
    $display("block     = %0d bits", BLOCK_BITS);
    $display("byte addr = %0d bits", ADDR_BITS - PAGE_BITS - BLOCK_BITS);
    $display("word size = %0d bytes", WORD_SIZE);
    $display("page addr  mask = %b", page_addr_mask);
    $display("block addr mask = %b", block_addr_mask);
    $display("byte  addr mask = %b", byte_addr_mask);
    $display("word  addr mask = %b", word_addr_mask);
  endfunction
  
endclass
