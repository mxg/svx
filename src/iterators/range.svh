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
// range
//----------------------------------------------------------------------
class range_base#(type T=int, type P=void_traits)
  implements typed_iterator#(T,P);

  typedef bidir_iterator_base #(T,P) iter_t;
  
  protected iter_t iter;
  protected index_t ub; // upper bound
  protected index_t lb; // lower cound
  protected index_t idx;

  function index_t get_lower_bound();
    return lb;
  endfunction

  function index_t get_upper_bound();
    return ub;
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
  // Retrieve the iterm at the current index
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
    return iter.size();
  endfunction
    
  //--------------------------------------------------------------------
  // is_empty
  //--------------------------------------------------------------------
  virtual function bit is_empty();
    return iter.is_empty();
  endfunction
  
endclass

//----------------------------------------------------------------------
// range
//----------------------------------------------------------------------
class range#(type T=int, type P=void_traits)
  extends range_base#(T,P)
  implements bidir_intf;

  function new(iter_t it, index_t lower_bound, index_t upper_bound);

    iter = it;
    lb = lower_bound;
    ub = upper_bound;

    // Make sure upper and lower bounds are within range of the
    // vector.
    if(lb >= iter.size())
      lb = iter.size() - 1;
    if(ub >= iter.size())
      ub = iter.size();
    if(lb > ub) begin
      index_t tmp;
      tmp = lb;
      ub = lb;
      lb = tmp;
    end
  endfunction

  // The compiler should find this in the bse class.
  virtual function void set(T t);
    super.set(t);
  endfunction
  
  virtual function T get();
    return super.get();
  endfunction

  // The Verilator compiler doesn't seem to be able to find the
  // implementations in the base class, so we give it a hint.
  virtual function size_t size();
    return super.size();
  endfunction
    
  virtual function bit is_empty();
    return super.is_empty();
  endfunction

  //--------------------------------------------------------------------
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
  //--------------------------------------------------------------------
  virtual function bit next();
    if(is_empty() || ((idx > lb) && (idx > ub)))
      return 0;
    if(idx <= ub) begin
      idx++;
      void'(iter.next());
    end
    return 1;
  endfunction    

  //--------------------------------------------------------------------
  //--------------------------------------------------------------------
  virtual function bit is_last();
    return (!is_empty() && (idx >= ub));
  endfunction

  //--------------------------------------------------------------------
  //--------------------------------------------------------------------
  virtual function bit at_end();
    if(is_empty())
      return 1;
    return (idx > ub);    
  endfunction

  //--------------------------------------------------------------------
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
  //--------------------------------------------------------------------
  virtual function bit prev();
    if(is_empty())
      return 0;
    if(idx >= lb && idx > 0) begin
      idx--;
      void'(iter.prev());
    end
    return 1;
  endfunction

  //--------------------------------------------------------------------
  //--------------------------------------------------------------------
  virtual function bit is_first();
    return (!is_empty() && (idx == lb));
  endfunction

  //--------------------------------------------------------------------
  //--------------------------------------------------------------------
  virtual function bit at_beginning();
    if(is_empty())
      return 1;
    return (idx < lb);
  endfunction 

  //--------------------------------------------------------------------
  //--------------------------------------------------------------------
  virtual function bit skip(signed_index_t distance);
    return iter.skip(distance);
  endfunction

endclass

typedef range#(int8_t,    int8_traits   ) int8_range;
typedef range#(uint8_t,   uint8_traits  ) uint8_range;
typedef range#(int16_t,   int16_traits  ) int16_range;
typedef range#(uint16_t,  uint16_traits ) uint16_range;
typedef range#(int32_t,   int32_traits  ) int32_range;
typedef range#(uint32_t,  uint32_traits ) uint32_range;
typedef range#(int64_t,   int64_traits  ) int64_range;
typedef range#(uint64_t,  uint64_traits ) uint64_range;
typedef range#(int128_t,  int128_traits ) int128_range;
typedef range#(uint128_t, uint128_traits) uint128_range;
typedef range#(real,      real_traits   ) real_range;
typedef range#(string,    string_traits ) string_range;
	       
