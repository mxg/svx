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

typedef class map_iterator;

//----------------------------------------------------------------------
// multimap
//
// A multimap is a map where each entry is a queue of items.
//----------------------------------------------------------------------

class multimap #(type KEY=int, type T=void_t, type P=void_traits)
  extends typed_container #(T,P);

  typedef deque#(T,P) deque_t;
  typedef class_traits #(deque_t) traits_t;
  typedef map#(KEY, deque_t, traits_t) map_t;
  typedef map_iterator#(KEY, deque_t, traits_t) map_iter_t;

  map_t m_map;

  //--------------------------------------------------------------------
  // constructor
  //--------------------------------------------------------------------
  function new();
    m_map = new();
  endfunction

  //--------------------------------------------------------------------
  // get_map
  //
  // ** Don't use this function **
  //
  // Returns a handle to the internal map used to implement a
  // multimap.  Required by the multimap_iterator, but is not for
  // general use.  If SystemVerilog supported friends this would not
  // be necessary.
  //--------------------------------------------------------------------
  function map_t get_map();
    return m_map;
  endfunction

  //--------------------------------------------------------------------
  // get
  //
  // If the key exists in the map then return the last item inserted
  // for that key. If the key is not in the map then return empty.
  //--------------------------------------------------------------------
  virtual function T get(KEY key);
    deque_t q = m_map.get(key);
    return (q == traits_t::empty)
      ? P::empty
      : q.peek_back();
  endfunction

  //--------------------------------------------------------------------
  // get_all
  //
  // We clone the deque because we don't want to hand back a handle to
  // the internal data structure.
  //--------------------------------------------------------------------
  virtual function deque_t get_all(KEY key);
    deque_t q_copy;
    deque_t q = m_map.get(key);
    if (q == traits_t::empty)
      return q;
    q_copy = q.clone();
    return q_copy;
  endfunction
  
  //--------------------------------------------------------------------
  // insert
  //--------------------------------------------------------------------
  virtual function void insert (KEY key, T item);
    deque_t q = m_map.get(key);
    if(q == traits_t::empty) begin
      q = new();
      void'(m_map.insert(key, q));
    end
    q.push_back(item);
  endfunction

  //--------------------------------------------------------------------
  // size
  //
  // Returns the number of items stored in the map.  The number of
  // items in the multimap is the sum of the number of items in all
  // the queues (deques).
  //--------------------------------------------------------------------
  virtual function size_t size();

    map_iter_t iter = new(m_map);
    size_t sz = 0;

    void'(iter.first());
    while(!iter.at_end()) begin
      deque_t d = iter.get();
      sz += d.size();
      void'(iter.next());
    end

    return sz;
    
  endfunction

  //--------------------------------------------------------------------
  // size_nonzero
  //
  // Sometimes we just need to know if there is at least one entry in
  // the multimap.  In those cases, traversing the entire map to count
  // all the items is not very efficient.  So this function lets you
  // find out if anything is in the map without counting all the
  // items.
  //--------------------------------------------------------------------
  virtual function bit size_nonzero();
    return (m_map.size() > 0);
  endfunction

  //--------------------------------------------------------------------
  // contains
  //
  // Does the multimap contain a specific key?
  //--------------------------------------------------------------------
  virtual function bit contains(KEY key);
    deque_t q = m_map.get(key);
    return ((q != traits_t::empty)  && (q.size() > 0));
  endfunction

  //--------------------------------------------------------------------
  // count
  //
  // How many entires as associated with a specific key?
  //--------------------------------------------------------------------
  virtual function size_t count(KEY key);
    deque_t q = m_map.get(key);
    return (q == traits_t::empty)
      ? 0
      : q.size();
  endfunction

  //--------------------------------------------------------------------
  // is_empty
  //
  // Are there any items in the map?
  //--------------------------------------------------------------------
  virtual function bit is_empty();
    return (m_map.is_empty());
  endfunction

  //--------------------------------------------------------------------
  // delete
  //
  // Removes the item(s) with the given ~key~ from the map.
  //--------------------------------------------------------------------
  virtual function bit delete (KEY key);
    deque_t q = m_map.get(key);
    if(q == traits_t::empty)
      return 0;
    void'(m_map.delete(key));
    return 1;
  endfunction

  //--------------------------------------------------------------------
  // clear
  //
  // Remove all of the elements from the map.
  //--------------------------------------------------------------------
  virtual function void clear();
    m_map.clear();
  endfunction

endclass
