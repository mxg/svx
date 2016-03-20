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
//
// Sparse Memory Model
//
//----------------------------------------------------------------------
class mem#(int unsigned ADDR_BITS = 32,
	   int unsigned PAGE_BITS = 16,
	   int unsigned BLOCK_BITS = 8,
	   int unsigned WORD_SIZE = 4)
  extends mem_base#(ADDR_BITS, PAGE_BITS, BLOCK_BITS, WORD_SIZE);

  typedef mem_page#(ADDR_BITS, PAGE_BITS, BLOCK_BITS, WORD_SIZE) page_t;
  typedef map#(page_key_t, page_t, class_traits#(page_t)) page_map_t;

  // The page map is the skeleton of the memory data structure
  local page_map_t page_map;

  function new();
    super.new(this);
    page_map = new();
  endfunction

  //--------------------------------------------------------------------
  // write
  //
  // Write data into a location identified by addr.  Look up the page
  // and delegate the write to the page.  If the page doesn't exist then
  // add it.
  //--------------------------------------------------------------------  
  function void write(addr_t addr, word_t data);

    restrict_t page_restriction;
    page_t page;
    page_key_t page_key = get_page_key(addr);

    next_operation(OP_WRITE, addr);

    // check page-level security
    page_restriction = get_page_restriction(addr);
    if(page_restriction == RESTRICT_WRITE || page_restriction == RESTRICT_READ_WRITE) begin
      set_error(ERROR_PAGE_SECURITY_VIOLATION);
      return;
    end
    
    page = page_map.get(page_key);
    if(page == null) begin
      // add a new page
      page = new(mem_root);
      page_map.insert(page_key, page);
    end

    page.write(addr, data);
    
  endfunction

  //--------------------------------------------------------------------
  // read
  //--------------------------------------------------------------------  
  function word_t read(addr_t addr);

    restrict_t page_restriction;
    page_t page;
    page_key_t page_key = get_page_key(addr);

    next_operation(OP_READ, addr);

    // check page-level security
    page_restriction = get_page_restriction(addr);
    if(page_restriction == RESTRICT_READ || page_restriction == RESTRICT_READ_WRITE) begin
      set_error(ERROR_PAGE_SECURITY_VIOLATION);
      return 0;
    end

    page = page_map.get(page_key);
    if(page == null)
      return 0;

    return page.read(addr);

  endfunction

  //--------------------------------------------------------------------
  // write byte
  //--------------------------------------------------------------------  
  function void write_byte(addr_t addr, byte_t data);

    restrict_t page_restriction;
    page_t page;
    page_key_t page_key = get_page_key(addr);

    next_operation(OP_WRITE_BYTE, addr);

    // check page-level security
    page_restriction = get_page_restriction(addr);
    if(page_restriction == RESTRICT_WRITE || page_restriction == RESTRICT_READ_WRITE) begin
      set_error(ERROR_PAGE_SECURITY_VIOLATION);
      return;
    end
    
    page = page_map.get(page_key);
    if(page == null) begin
      // add a new page
      page = new(mem_root);
      page_map.insert(page_key, page);
    end

    page.write_byte (addr, data);
    
  endfunction
  
  //--------------------------------------------------------------------
  // read byte
  //--------------------------------------------------------------------  
  function byte_t read_byte(addr_t addr);

    restrict_t page_restriction;
    page_t page;
    page_key_t page_key = get_page_key(addr);

    next_operation(OP_READ_BYTE, addr);

    // check page-level security
    page_restriction = get_page_restriction(addr);
    if(page_restriction == RESTRICT_READ || page_restriction == RESTRICT_READ_WRITE) begin
      set_error(ERROR_PAGE_SECURITY_VIOLATION);
      return 0;
    end

    // First, find the page.  If it doesn't exist, the we're done
    page = page_map.get(page_key);
    if(page == null) begin
      return 0;
    end

    return page.read_byte(addr);

  endfunction

  //====================================================================
  //
  // Security Interface
  //
  //====================================================================
  //--------------------------------------------------------------------
  // page-level security
  //--------------------------------------------------------------------
  function void set_page_restriction(addr_t addr, restrict_t r);
    set_restriction(get_page_key(addr), r);
  endfunction

  function restrict_t get_page_restriction(addr_t addr);
    return get_restriction(get_page_key(addr));
  endfunction

  function void clear_page_restriction(addr_t addr);
    clear_restriction(get_page_key(addr));
  endfunction  

  //--------------------------------------------------------------------
  // block-level security
  //--------------------------------------------------------------------
  function void set_block_restriction(addr_t addr, restrict_t r);

    page_key_t page_key = get_page_key(addr);
    page_t page = page_map.get(page_key);

    if(page == null) begin
      page = new(mem_root);
      page_map.insert(page_key, page);
    end

    page.set_restriction(get_block_addr(addr), r);
    
  endfunction

  function void clear_block_restriction(addr_t addr);

    page_t page  = page_map.get(get_page_key(addr));

    if(page != null)
      page.clear_restriction(get_block_addr(addr));

  endfunction

  //--------------------------------------------------------------------
  // word-level security
  //--------------------------------------------------------------------
  function void set_word_restriction(addr_t addr, restrict_t r);

    page_key_t page_key = get_page_key(addr);
    page_t page = page_map.get(page_key);

    if(page == null) begin
      page = new(mem_root);
      page_map.insert(page_key, page);
    end

    page.set_word_restriction(addr, r);
    
  endfunction

  function void clear_word_restriction(addr_t addr);

    page_t page = page_map.get(get_page_key(addr));

    if(page != null)
      page.clear_word_restriction(addr);

  endfunction

  //--------------------------------------------------------------------
  // security interrogation
  //--------------------------------------------------------------------
  function bit is_readable(addr_t addr);
    restrict_t r = get_addr_restriction(addr);
    return !(r == RESTRICT_READ || r == RESTRICT_READ_WRITE);
  endfunction

  function bit is_writable(addr_t addr);
    restrict_t r = get_addr_restriction(addr);
    return !(r == RESTRICT_WRITE || r == RESTRICT_READ_WRITE);
  endfunction

  function restrict_t get_addr_restriction(addr_t addr);
    
    restrict_t r;
    page_t page;

    r = get_page_restriction(addr);
    if(r != RESTRICT_NONE)
      return r;

    page = page_map.get(get_page_key(addr));
    if( page == null)
      return RESTRICT_NONE;

    return page.get_addr_restriction(addr);
    
  endfunction

  //====================================================================
  //
  // Error Reporting Interface
  //
  //====================================================================

  // These fields are updated for each operation.  They are used by the
  // error reporting methods to identify the operation in error, should
  // an error occur.
  local error_t last_error;
  local addr_t last_addr;
  local operation_t last_operation;

  // This function is used to signal that an error has occured.  It is
  // called from the mem_base::set_error() function and should not be
  // called directly.
  function void set_last_error(error_t err);
    last_error = err;
  endfunction

  // Sets the error reporting fields in case an error occurs.  Also
  // clears the last error, unless the last error was a parameter error.
  // Parameter errors cannot be cleared.
  local function void next_operation(operation_t op, addr_t addr);
    if(last_error != ERROR_PARAMETERS_WRONG)
      last_error = ERROR_NONE;
    last_operation = op;
    last_addr = addr;
  endfunction

  // Answer the question: did the previous operation fail?
  function bit last_operation_failed();
    return (last_error != ERROR_NONE);
  endfunction

  // For the curious, return the enum that identifies the last error.
  function error_t get_last_error();
    return last_error;
  endfunction

  // Return a string that has information about the error that just occurred.
  function string get_last_op_string();

    string msg;
    string s;

    msg = "*** ";
    
    case(last_operation)
      OP_NONE:
	msg = { msg, "-- none --" };
      OP_READ:
	msg = { msg, "read word" };
      OP_WRITE:
	msg = { msg, "write word" };
      OP_READ_BYTE:
	msg = { msg, "read byte" };
      OP_WRITE_BYTE:
	msg = { msg, "write byte" };
    endcase

    $sformat(s, " @ %x : ", last_addr);
    msg = { msg, s };
    
    case(last_error)
      ERROR_NONE:
	msg = {msg, "success" };
      ERROR_PARAMETERS_WRONG:
	msg = { msg, "class parameters are erronenous" };
      ERROR_MISALIGNMENT:
	msg = { msg, "address not aligned to a word boundary" };
      ERROR_PAGE_SECURITY_VIOLATION:
	msg = { msg, "page security violation" };
      ERROR_BLOCK_SECURITY_VIOLATION:
	msg = { msg, "block security violation" };
      ERROR_WORD_SECURITY_VIOLATION:
	msg = { msg, "word security violation" };
      ERROR_ADDRESS_BOUNDS:
	msg = {msg, "address bounds violation" };
    endcase

    return msg;
    
  endfunction

  //====================================================================
  //
  // Dumping
  //
  //====================================================================
  function void dump_security(addr_t addr = 0);

    map_fwd_iterator#(addr_t, restrict_t, restrict_traits) iter;
    map_fwd_iterator#(page_key_t, page_t, class_traits#(page_t)) page_iter;
    page_key_t page_key;
    page_t page;

    $display("\n----- SECURITY MAP -----");

    iter = new(security_map);
    iter.first();
    while(!iter.at_end()) begin
      restrict_t r = iter.get();
      page_key = iter.get_index();
      $display("page: %x  restriction = %s", page_key, r.name());
      iter.next();
    end

    // Traverse the page map
    page_iter = new(page_map);
    page_iter.first();
    while(!page_iter.at_end()) begin
      page = page_iter.get();
      page_key = page_iter.get_index();
      $display("security map for page %x", page_key);
      page.dump_security(construct_addr(page_key, 0, 0));
      page_iter.next();
    end

    $display("----- END SECURITY MAP -----");
    
  endfunction

  //--------------------------------------------------------------------
  // dump
  //
  // Dump the entire memory.  Traverse the page map and dump the pages.
  // We don't use the addr argument in this implementation of dump().
  // However we need the argument to satisfy the virtual function
  // prototype in the base class.
  //--------------------------------------------------------------------
  function void dump(addr_t addr=0);

    map_fwd_iterator#(page_key_t, page_t, class_traits#(page_t)) page_iter;
    page_t page;
    page_key_t page_key;
    
    page_iter = new(page_map);

    // Traverse the page map
    page_iter.first();
    while(!page_iter.at_end()) begin
      page = page_iter.get();
      page_key = page_iter.get_index();
      page.dump(construct_addr(page_key, 0, 0));
      page_iter.next();
    end
    
  endfunction
  
endclass
