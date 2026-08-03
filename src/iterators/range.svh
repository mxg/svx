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
// range_base
//----------------------------------------------------------------------
virtual class range_base;
  protected index_t ub; // upper bound
  protected index_t lb; // lower cound
  protected signed_index_t idx;

  function new(index_t size, index_t lower_bound, index_t upper_bound);

    lb = lower_bound;
    ub = upper_bound;

    // Make sure upper and lower bounds are within range of the
    // vector.
    if(lb >= size)
      lb = size - 1;
    if(ub >= size)
      ub = size - 1;
    if(lb > ub) begin
      // swap ub and lb
      index_t tmp;
      tmp = lb;
      ub = lb;
      lb = tmp;
    end
  endfunction

  function index_t get_lower_bound();
    return lb;
  endfunction

  function index_t get_upper_bound();
    return ub;
  endfunction
endclass

//----------------------------------------------------------------------
// range
//----------------------------------------------------------------------
class range#(type T=int, type P=void_traits)
  extends range_base
  implements bidir_iterator_base#(T,P);

  typedef bidir_iterator_base #(T,P) iter_t;
  
  protected iter_t iter;

  function new(iter_t it, index_t lower_bound, index_t upper_bound);
    super.new(it.size(), lower_bound, upper_bound);
    iter = it;
  endfunction
  
  //--------------------------------------------------------------------
  // set
  //
  // Set the value of the item at the current index
  //--------------------------------------------------------------------
  virtual function void set(T t);
    if(!is_empty()) begin
      iter.set(t);
    end
  endfunction

  //--------------------------------------------------------------------
  // get
  //
  // Retrieve the item at the current index
  //--------------------------------------------------------------------
  virtual function T get();
    if(is_empty())
      return P::empty;
    else
      return iter.get();
  endfunction

  //--------------------------------------------------------------------
  // size
  //--------------------------------------------------------------------
  virtual function size_t size();
    return (ub - lb) + 1;
  endfunction
    
  //--------------------------------------------------------------------
  // is_empty
  //--------------------------------------------------------------------
  virtual function bit is_empty();
    return iter == null || iter.is_empty();
  endfunction

  //--------------------------------------------------------------------
  // first
  //--------------------------------------------------------------------
  virtual function bit first();
    idx = lb;
    if(is_empty())
      return 0;
    void'(iter.first());
    void'(iter.skip(lb));
    return 1;
  endfunction

  //--------------------------------------------------------------------
  // next
  //--------------------------------------------------------------------
  virtual function bit next();
    if(is_empty() || ((idx > lb) && (idx > ub)))
      return 0;
    if(idx <= ub) begin
      idx++;
      return iter.next();
    end
    return 1;
  endfunction    

  //--------------------------------------------------------------------
  // is_last
  //--------------------------------------------------------------------
  virtual function bit is_last();
    return (!is_empty() && (idx >= ub));
  endfunction

  //--------------------------------------------------------------------
  // at_end
  //--------------------------------------------------------------------
  virtual function bit at_end();
    return(!is_empty() && (idx > ub));
  endfunction

  //--------------------------------------------------------------------
  // last
  //--------------------------------------------------------------------
  virtual function bit last();
    idx = ub;
    if(is_empty())
      return 0;
    void'(iter.first());
    void'(iter.skip(ub));
    return (iter.size() > 0);
  endfunction

  //--------------------------------------------------------------------
  // prev
  //--------------------------------------------------------------------
  virtual function bit prev();
    if(is_empty())
      return 0;
    if(idx >= lb && idx >= 0) begin
      idx--;
      return iter.prev();
    end
    return 1;
  endfunction

  //--------------------------------------------------------------------
  // is_first
  //--------------------------------------------------------------------
  virtual function bit is_first();
    return (!is_empty() && (idx == lb));
  endfunction

  //--------------------------------------------------------------------
  // at_beginning
  //--------------------------------------------------------------------
  virtual function bit at_beginning();
    return(!is_empty() && (idx < signed_index_t'(lb)));
  endfunction 

  //--------------------------------------------------------------------
  // skip
  //--------------------------------------------------------------------
  virtual function bit skip(signed_index_t distance);
    return iter.skip(distance);
  endfunction

endclass

//
// Some convenience typedefs for ranges
//
typedef range#(int8_t,    int8_traits   ) range_int8;
typedef range#(uint8_t,   uint8_traits  ) range_uint8;
typedef range#(int16_t,   int16_traits  ) range_int16;
typedef range#(uint16_t,  uint16_traits ) range_uint16;
typedef range#(int32_t,   int32_traits  ) range_int32;
typedef range#(uint32_t,  uint32_traits ) range_uint32;
typedef range#(int64_t,   int64_traits  ) range_int64;
typedef range#(uint64_t,  uint64_traits ) range_uint64;
typedef range#(int128_t,  int128_traits ) range_int128;
typedef range#(uint128_t, uint128_traits) range_uint128;
typedef range#(real,      real_traits   ) range_real;
typedef range#(string,    string_traits ) range_string;
	       
