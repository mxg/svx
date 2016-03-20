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
// Bounded Memory
//
//----------------------------------------------------------------------
class mem_bounded #(int unsigned ADDR_BITS = 32,
		    int unsigned PAGE_BITS = 16,
		    int unsigned BLOCK_BITS = 8,
		    int unsigned WORD_SIZE = 4)
  extends mem#(ADDR_BITS, PAGE_BITS, BLOCK_BITS, WORD_SIZE);

  // lower address bound -- cannot access memory below this point.
  local addr_t lower_bound;

  // upper address bound -- cannot access memory above this point.
  local addr_t upper_bound;

  // bounds can be changed until they are locked. Bounds are locked when
  // the first read or write occurs, or when they are explicitly locked
  local bit bounds_lock;

  function new(addr_t lower = '0, addr_t upper = '1);
    super.new();
    set_bounds(lower, upper);
    bounds_lock = 0;
  endfunction

  //====================================================================
  //
  // Bounds Accessors
  //
  //====================================================================

  function void set_bounds(addr_t lower, addr_t upper);
    if(get_bounds_lock())
      return;
    set_lower_bound(lower);
    set_upper_bound(upper);
  endfunction

  function void set_lower_bound(addr_t lower);
    if(get_bounds_lock())
      return;
    lower_bound = lower;
  endfunction

  function void set_upper_bound(addr_t upper);
    if(get_bounds_lock())
      return;
    upper_bound = upper;
  endfunction

  function addr_t get_lower_bound();
    return lower_bound;
  endfunction

  function addr_t get_upper_bound();
    return upper_bound;
  endfunction

  function void set_bounds_lock();
    bounds_lock = 1;
  endfunction

  function bit get_bounds_lock();
    return bounds_lock;
  endfunction

  //--------------------------------------------------------------------
  //  write
  //--------------------------------------------------------------------  
  function void write(addr_t addr, word_t data);

    set_bounds_lock();
    
    if(addr < lower_bound || addr > upper_bound) begin
      set_error(ERROR_ADDRESS_BOUNDS);
      return;
    end

    super.write(addr, data);
      
  endfunction
  
  //--------------------------------------------------------------------
  // read
  //--------------------------------------------------------------------  
  function word_t read(addr_t addr);

    set_bounds_lock();

    if(addr < lower_bound || addr > upper_bound) begin
      set_error(ERROR_ADDRESS_BOUNDS);
      return 0;
    end

    return super.read(addr);
    
  endfunction
  
  //--------------------------------------------------------------------
  // write_byte
  //--------------------------------------------------------------------  
  function void write_byte(addr_t addr, byte_t data);

    set_bounds_lock();

    if(addr < lower_bound || addr > upper_bound) begin
      set_error(ERROR_ADDRESS_BOUNDS);
      return;
    end

    super.write_byte(addr, data);
    
  endfunction
  
  //--------------------------------------------------------------------
  // read_byte
  //--------------------------------------------------------------------  
  function byte_t read_byte(addr_t addr);

    set_bounds_lock();

    if(addr < lower_bound || addr > upper_bound) begin
      set_error(ERROR_ADDRESS_BOUNDS);
      return;
    end

    return super.read_byte(addr);

  endfunction

  //--------------------------------------------------------------------
  // dump
  //--------------------------------------------------------------------
  function void dump(addr_t addr = 0);
    $display("lower_bound = %x", get_lower_bound());
    $display("upper_bound = %x", get_upper_bound());
    super.dump(addr);
  endfunction
  
endclass

