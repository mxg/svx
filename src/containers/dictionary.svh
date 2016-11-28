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
// class: dictionary
//
// A dictionary is a specialization of map#(KEY,T,P) where key is type
// string.
//
// The first(), last(), next(), and prev() functions are implemented so
// that iterations over the dictionary will be in sorted order by key.
// ----------------------------------------------------------------------

class dictionary #(type T=void_t, type P=void_traits)
  extends map #(string,T,P);

  // this_t is defined in the base class
  this_t this_map;

  // We use an internal vector to keep the keys in sort order.
  vector#(string, string_traits) keys;
  list_bidir_iterator#(string, string_traits) keys_iter;
  
  // function: first
  //
  // Construct a sorted list of map keys so that a dictinary iterator
  // can return the keys in sorted order.
  virtual function bit first(ref string index);

    string key;
    bit ok;
    map_fwd_iterator#(string, T, P) map_iter = new();
    $cast(this_map, this);
    map_iter.bind_map(this_map);
    
    if(keys == null)
      keys = new();
    else
      keys.clear();

    // Grab the keys and put them into a vector for sorting.
    m_map.first(index);
    do begin
      keys.appendc(index);
    end while(m_map.next(index));

    // sort the keys
    keys.sort();
    
    keys_iter = new(keys);
    ok = keys_iter.first();
    index = keys_iter.get();

    return ok;
  endfunction

  // function: last
  //
  virtual function bit last (ref string index);
    bit ok;
    if(keys_iter == null)
      return 0;
    ok = keys_iter.last();
    index = keys_iter.get();
    return ok;
  endfunction

  // function: next
  //
  virtual function bit next(ref string index);
    bit ok;
    if(keys_iter == null)
      return 0;
    ok = keys_iter.next();
    index = keys_iter.get();
    return ok;
  endfunction

  // function: prev()
  //
  virtual function bit prev(ref string index);
    bit ok;
    if(keys_iter == null)
      return 0;
    ok = keys_iter.prev();
    index = keys_iter.get();
    return ok;
  endfunction

endclass
