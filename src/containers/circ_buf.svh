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

/* verilator lint_off WIDTHTRUNC */
//----------------------------------------------------------------------
// circ_buf
//----------------------------------------------------------------------
class circ_buf #(type T=int, type P=void_traits, size_t S=8)
  extends typed_container #(T,P);

  local index_t head;
  local index_t tail;
  local size_t count;
  local T buffer[S];

  //--------------------------------------------------------------------
  // constructor
  //--------------------------------------------------------------------
  function new();
    clear();
  endfunction

  //--------------------------------------------------------------------
  // size
  //--------------------------------------------------------------------
  virtual function size_t size();
    return count;
  endfunction

  //--------------------------------------------------------------------
  // is_empty
  //--------------------------------------------------------------------
  virtual function bit is_empty();
    return (count == 0);
  endfunction

  //--------------------------------------------------------------------
  // clear
  //--------------------------------------------------------------------
  virtual function void clear();
    tail = 0;
    head = 0;
    count = 0;
  endfunction

  //--------------------------------------------------------------------
  // is_full
  //--------------------------------------------------------------------
  virtual function bit is_full();
    return (count == S);
  endfunction

  //--------------------------------------------------------------------
  // push_tail
  //--------------------------------------------------------------------
  virtual function void push_tail(T t);
    
    if(is_full()) begin
      $display("** ERROR: cannot push new item into full circular buffer");
      return;
    end
    
    buffer[tail] = t;
    tail++;
    if(tail >= S)
      tail = 0;
    count ++;
    
  endfunction

  //--------------------------------------------------------------------
  // pop_head
  //--------------------------------------------------------------------
  virtual function T pop_head();

    T t;
    
    if(is_empty()) begin
      $display("** ERROR: circular buffer is empty");
      return m_empty;
    end
    
    t = buffer[head];
    head++;
    if(head >= S)
      head = 0;
    count --;
    
    return t;

  endfunction
endclass

/* verilator lint_on WIDTHTRUNC */
