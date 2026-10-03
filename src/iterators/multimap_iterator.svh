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

//----------------------------------------------------------------------
// multimap_iterator_base
//----------------------------------------------------------------------
virtual class multimap_iterator_base#(type KEY=int,
				      type T=int,
				      type P=void_traits);

  typedef deque#(T,P) deque_t;
  typedef class_traits #(deque_t) traits_t;
  typedef multimap#(KEY,T,P) multimap_t;
  typedef map_iterator#(KEY, deque_t, traits_t) map_iter_t;
  typedef list_iterator#(T,P) list_iter_t;

  protected multimap_t m_map;
  protected map_iter_t map_iter;
  protected list_iter_t list_iter;

  //--------------------------------------------------------------------
  // constructor
  //
  // Optionally, bind a map to the iterator.
  //--------------------------------------------------------------------
  function new(multimap_t map_inst = null);
    bind_map(map_inst);
  endfunction

  //--------------------------------------------------------------------
  // bind_map
  //
  // Bind a map to the iterator
  //--------------------------------------------------------------------
   virtual function void bind_map(multimap_t m = null);
     if(m == null)
       return;
     m_map = m;
     map_iter = new(m_map.get_map());
     list_iter = new();
   endfunction

  //--------------------------------------------------------------------
  // get_index
  //
  // Reteive the index (key) associated with the item at the current
  // position.
  //--------------------------------------------------------------------
  virtual function KEY get_index();
    return map_iter.get_index();
  endfunction
  
  //--------------------------------------------------------------------
  // size
  //--------------------------------------------------------------------
  virtual function size_t size();
    return (m_map == null) ? 0 : m_map.size();
  endfunction

  //--------------------------------------------------------------------
  // is_empty
  //--------------------------------------------------------------------
  virtual function bit is_empty();
    return (m_map == null) || (m_map.size_nonzero() == 0);
  endfunction
    
endclass

//----------------------------------------------------------------------
// multimap_iterator
//----------------------------------------------------------------------
class multimap_iterator#(type KEY=int, type T=int, type P=void_traits)
  extends multimap_iterator_base#(KEY,T,P)
  implements fwd_intf#(T,P), bkwd_intf#(T,P);

  //--------------------------------------------------------------------
  // constructor
  //--------------------------------------------------------------------
  function new(multimap_t map_inst = null);
    super.new(map_inst);
  endfunction

  //--------------------------------------------------------------------
  // set
  //
  // Set the value of the item at the current position
  //--------------------------------------------------------------------
  virtual function void set(T t);
    list_iter.set(t);
  endfunction
  
  //--------------------------------------------------------------------
  // get
  //
  // Retrieve the item at the current position
  //--------------------------------------------------------------------
  virtual function T get();
    if(is_empty())
      return P::empty;
    return list_iter.get();
  endfunction

  //--------------------------------------------------------------------
  // get_index
  //--------------------------------------------------------------------
  virtual function KEY get_index();
    return super.get_index();
  endfunction
  
  //--------------------------------------------------------------------
  // first
  //--------------------------------------------------------------------
  virtual function bit first();
    deque_t q;

    if(is_empty())
      return 0;
    
    void'(map_iter.first());
    q = map_iter.get();
    list_iter.bind_list(q);
    void'(list_iter.first());
    return 1;
    
  endfunction
  
  //--------------------------------------------------------------------
  // next
  //--------------------------------------------------------------------
  virtual function bit next();

    deque_t q;
    
    if(is_empty()  || at_end())
      return 0;

    // If we're at the end of this deque then let's go to the next
    // one.
    if(!list_iter.is_last()) begin
      void'(list_iter.next());
      return 1;
    end
    
    void'(map_iter.next());
    if(map_iter.at_end())
      return 0;
    q = map_iter.get();
    list_iter.bind_list(q);
    void'(list_iter.first());

    return 1;

  endfunction
    
  //--------------------------------------------------------------------
  // is_last
  //--------------------------------------------------------------------
  virtual function bit is_last();

    if(is_empty())
      return 0;

    return (map_iter.is_last() && list_iter.is_last());

  endfunction
    
  //--------------------------------------------------------------------
  // at_end
  //--------------------------------------------------------------------
  virtual function bit at_end();

    if(is_empty())
      return 1;

    return (map_iter.at_end());

  endfunction

  //--------------------------------------------------------------------
  // last
  //--------------------------------------------------------------------
  virtual function bit last();

    deque_t q;

    if(is_empty())
      return 0;

    void'(map_iter.last());
    q = map_iter.get();
    list_iter.bind_list(q);
    void'(list_iter.last());

    return 1;

  endfunction
    
  //--------------------------------------------------------------------
  // prev
  //--------------------------------------------------------------------
  virtual function bit prev();

    deque_t q;

    if(is_empty())
      return 0;

    if(!list_iter.is_first()) begin
      void'(list_iter.prev());
      return 1;
    end
    
    void'(map_iter.prev());
    if(map_iter.at_beginning())
      return 0;
    q = map_iter.get();
    list_iter.bind_list(q);
    void'(list_iter.last());

    return 1;

  endfunction

  //--------------------------------------------------------------------
  // is_first
  //--------------------------------------------------------------------
  virtual function bit is_first();
    if(is_empty())
      return 0;
    return (map_iter.is_first() && list_iter.is_first());
  endfunction
    
  //--------------------------------------------------------------------
  // at_beginning
  //--------------------------------------------------------------------
  virtual function bit at_beginning();
    
    if(is_empty())
      return 1;
    
    return (map_iter.at_beginning());
    
  endfunction

  //--------------------------------------------------------------------
  // skip
  //
  // Skip 0 or more places forward or backward -- forward for a
  // positive distance, backward for a negative distance.
  //--------------------------------------------------------------------
  virtual function bit skip(signed_index_t distance);

    signed_index_t ix;

    if(distance == 0)
      return 1;

    if(distance > 0) begin
      for(ix = 0; ix < distance; ix++)
	if(next() == 0)
	  return 0;
    end

    if(distance < 0) begin
      for(ix = distance; ix < 0; ix++)
	if(prev() == 0)
	  return 0;
    end
    
    return 1;
  endfunction

  //--------------------------------------------------------------------
  // The Verilator compiler doesn't seem to be able to find the
  // implementations in the base class, so we give it a hint.
  virtual function size_t size();
    return super.size();
  endfunction
    
  virtual function bit is_empty();
    return super.is_empty();
  endfunction
    
endclass
