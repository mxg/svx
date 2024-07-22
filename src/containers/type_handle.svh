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
// class: type_handle_base
//----------------------------------------------------------------------
virtual class type_handle_base extends object;

  pure virtual function type_handle_base get_type_handle();

endclass

//----------------------------------------------------------------------
// class: type_handle
//----------------------------------------------------------------------
class type_handle #(type T=int) extends type_handle_base;

  typedef type_handle#(T) this_t;
  static this_t my_type;

  static function this_t get_type();
    if(my_type == null)
      my_type = new();
    return my_type;
  endfunction

  function type_handle_base get_type_handle();
    return get_type();
  endfunction

endclass

//----------------------------------------------------------------------
// type_container_base
//
// Non-parameterized base class for type containers
//
// The convert2string() virtual function provides a place to "print"
// each object.  The return value from this function is a string
// representing the human readable form of the object in the container.
//----------------------------------------------------------------------
class type_container_base;

  virtual function string convert2string();
    return "";
  endfunction

  virtual function type_handle_base get_type_handle();
    return null;
  endfunction
  
endclass

//----------------------------------------------------------------------
// type_container
//
// Contains an object of type T with a handle
//----------------------------------------------------------------------
class type_container#(type T) extends type_container_base;

  local type_handle#(T) th;
  local T t;

  function new();
    th = type_handle#(T)::get_type();
  endfunction

  // Get the type handle for this container's type.
  function type_handle_base get_type_handle();
    return th.get_type_handle();
  endfunction

  // Put a new object into the container.  This will replace the current
  // object.
  virtual function void set(T x);
    t = x;
  endfunction

  // Retrieve the object from the container.
  virtual function T get();
    return t;
  endfunction

endclass

