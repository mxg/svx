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
// class: deque
//
// A deque is a vector with fifo and lifo (stack) properties.  You can
// push and pop the front and the back of a deque.
//----------------------------------------------------------------------
class deque #(type T=int, type P=void_traits) extends vector#(T,P);

  typedef deque#(T,P) this_t;

  //--------------------------------------------------------------------
  // function: pop_front
  //--------------------------------------------------------------------
  virtual function T pop_front();
    return m_vector.pop_front();
  endfunction

  //--------------------------------------------------------------------
  // function: pop_back
  //--------------------------------------------------------------------
  virtual function T pop_back();
    return m_vector.pop_back();
  endfunction

  //--------------------------------------------------------------------
  // function: push_front
  //--------------------------------------------------------------------
  virtual function void push_front(T t);
    m_vector.push_front(t);
  endfunction

  //--------------------------------------------------------------------
  // function: push_back
  //--------------------------------------------------------------------
  virtual function void push_back(T t);
    m_vector.push_back(t);
  endfunction

  //--------------------------------------------------------------------
  // function: shuffle
  //--------------------------------------------------------------------
  virtual function void shuffle();
    m_vector.shuffle();
  endfunction

  //--------------------------------------------------------------------
  // function: reverse
  //--------------------------------------------------------------------
  virtual function void reverse();
    m_vector.reverse();
  endfunction

  //--------------------------------------------------------------------
  // function: clone
  //
  // Clone a stack
  //--------------------------------------------------------------------
  function this_t clone();
    this_t d = new();
    d.copy(this);
    return d;
  endfunction

endclass

//----------------------------------------------------------------------
// Common deque types
typedef deque#(int32_t,   int32_traits  ) int32_deque;
typedef deque#(uint32_t,  uint32_traits ) uint32_deque;
typedef deque#(int64_t,   int64_traits  ) int64_deque;
typedef deque#(uint64_t,  uint64_traits ) uint64_deque;
typedef deque#(int128_t,  int128_traits ) int128_deque;
typedef deque#(uint128_t, uint128_traits) uint128_deque;
typedef deque#(real,      real_traits   ) real_deque;
typedef deque#(string,    string_traits ) string_deque;
