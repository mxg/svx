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
// class: stack
//
// Based on the vector class
//----------------------------------------------------------------------
class stack #(type T=int, type P=void_traits) extends vector#(T,P);

  typedef stack#(T,P) this_t;

  //--------------------------------------------------------------------
  // function: pop
  //
  // Remove the item off the top of the stack and return it
  //--------------------------------------------------------------------
  virtual function T pop();
    if(is_empty())
      return P::empty;

    return m_vector.pop_front();
  endfunction

  //--------------------------------------------------------------------
  // function: push
  //
  // Put an item on the top of the stack
  //--------------------------------------------------------------------
  virtual function void push(T t);
    m_vector.push_front(t);
  endfunction

  //--------------------------------------------------------------------
  // function: is_empty
  //--------------------------------------------------------------------
  virtual function bit is_empty();
    return (size() == 0);
  endfunction

  //--------------------------------------------------------------------
  // function: clone
  //
  // Clone a stack
  //--------------------------------------------------------------------
  function this_t clone();
    this_t s = new();
    s.copy(this);
    return s;
  endfunction

endclass

//----------------------------------------------------------------------
// Common stack types
typedef stack#(int,              int_traits               ) int_stack;
typedef stack#(int unsigned,     int_unsigned_traits      ) intus_stack;
typedef stack#(longint,          longint_traits           ) longint_stack;
typedef stack#(longint unsigned, longint_unsigned_traits  ) longintus_stack;
typedef stack#(long_long_int_t,  long_long_int_traits     ) longlongint_stack;
typedef stack#(real,             real_traits              ) real_stack;
typedef stack#(string,           string_traits            ) string_stack;
