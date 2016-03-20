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
// Memory Spaces
//
//----------------------------------------------------------------------

// These typedefs are forward references.  They are here so we don't
// have to get so worried about the order in which the classes are
// declared.
typedef class mem_field;
typedef class mem_register;
typedef class mem_memory;
typedef class mem_region;
typedef class mem_view;
  
//----------------------------------------------------------------------
// mem_field
//
// For a field, the offset and size refer to bits within the field
//----------------------------------------------------------------------
class mem_field #(int unsigned ADDR_SIZE = 32)
  extends mem_space #(ADDR_SIZE);

  function new(string name, mem_space_t parent, addr_t _offset, size_t _size);
    super.new(name, parent, FIELD, _offset, _size);
  endfunction

  function mem_space_type_t get_type();
    return FIELD;
  endfunction

  function bit check_child(mem_space_t child);
    return 0; // fields cannot have children
  endfunction
  

endclass

//----------------------------------------------------------------------
// mem_register
//----------------------------------------------------------------------
class mem_register #(int unsigned ADDR_SIZE = 32)
  extends mem_space #(ADDR_SIZE);

  function new(string name, mem_space_t parent, addr_t _offset, size_t _size);
    super.new(name, parent, REGISTER, _offset, _size);
  endfunction

  function mem_space_type_t get_type();
    return REGISTER;
  endfunction

  function bit check_child(mem_space_t child);
    return (child.get_type() == FIELD);
  endfunction

  function void add_field(string name, addr_t _offset, size_t _size);
    mem_field #(ADDR_SIZE) field = new(name, this, _offset, _size);
  endfunction
  
endclass

//----------------------------------------------------------------------
// mem_memory
//----------------------------------------------------------------------
class mem_memory #(int unsigned ADDR_SIZE = 32)
  extends mem_space #(ADDR_SIZE);

  function new(string name, mem_space_t parent, addr_t _offset, size_t _size);
    super.new(name, parent, MEMORY, _offset, _size);
  endfunction

  function mem_space_type_t get_type();
    return MEMORY;
  endfunction

  function bit check_child(mem_space_t child);
    return 0; // memories cannot have children
  endfunction

endclass

//----------------------------------------------------------------------
// mem_region
//----------------------------------------------------------------------
class mem_region #(int unsigned ADDR_SIZE = 32)
  extends mem_space #(ADDR_SIZE);
  
  function new(string name, mem_space_t parent, addr_t _offset, size_t _size);
    super.new(name, parent, REGION, _offset, _size);
  endfunction

  function mem_space_type_t get_type();
    return REGION;
  endfunction

  function bit check_child(mem_space_t child);
    // regions can have children of any type -- except FIELD
    return (child.get_type() != FIELD);
  endfunction

  function void add_register(string name, addr_t _offset, size_t _size);
    mem_register #(ADDR_SIZE) register = new(name, this, _offset, _size);
  endfunction

  function void add_memory(string name, addr_t _offset, size_t _size);
    mem_memory #(ADDR_SIZE) memory = new(name, this, _offset, _size);
  endfunction

  function void add_region(string name, addr_t _offset, size_t _size);
    mem_region #(ADDR_SIZE) region = new(name, this, _offset, _size);
  endfunction

  function void add_view(string name, addr_t _offset, size_t _size);
    mem_view #(ADDR_SIZE) view = new(name, this, _offset, _size);
  endfunction
  
endclass

//----------------------------------------------------------------------
// mem_view
//
// A view is like a region, except that it shares a base address with
// other views at the same level of hierarchy.  in other words, VIEWS
// can overlap each other, where other space types cannot overlap at
// all.
//----------------------------------------------------------------------
class mem_view #(int unsigned ADDR_SIZE = 32)
  extends mem_space #(ADDR_SIZE);

  function new(string name, mem_space_t parent, addr_t _offset, size_t _size);
    super.new(name, parent, VIEW, _offset, _size);
  endfunction

  function mem_space_type_t get_type();
    return VIEW;
  endfunction

  function bit check_child(mem_space_t child);
    // views can have children of any type -- except FIELD
    return (child.get_type() != FIELD);
  endfunction

  function void add_register(string name, addr_t _offset, size_t _size);
    mem_register #(ADDR_SIZE) register = new(name, this, _offset, _size);
  endfunction

  function void add_memory(string name, addr_t _offset, size_t _size);
    mem_memory #(ADDR_SIZE) memory = new(name, this, _offset, _size);
  endfunction

  function void add_region(string name, addr_t _offset, size_t _size);
    mem_region #(ADDR_SIZE) region = new(name, this, _offset, _size);
  endfunction

  function void add_view(string name, addr_t _offset, size_t _size);
    mem_view #(ADDR_SIZE) view = new(name, this, _offset, _size);
  endfunction

endclass
