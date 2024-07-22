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
// class: map_iterator_base
//
// Base clss for all map iterators.  It provides a means for binding a
// map to the iterator and for setting and getting the item at the
// current iterator position.
// ----------------------------------------------------------------------
virtual class map_iterator_base#(type KEY=int,
                                 type T=int,
                                 type P=void_traits)
  extends typed_iterator#(T,P);

  typedef map#(KEY,T,P) map_t;
  protected map_t m_map;
  protected KEY index;  // current iterator state

  typedef enum {INVALID, FIRST, VALID, LAST} state_t;
  protected state_t state;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // constructor
  //
  // Optionally, bind a map to the iterator
  function new(map_t map_inst = null);
    super.new();
    bind_map(map_inst);
    state = INVALID;
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // bind_map
  //
  // Bind a map to the iterator
   virtual function void bind_map(map_t m = null);
     m_map = m;
   endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // set
  //
  // Set the value of the item at the current position
  virtual function void set(T t);
    if(m_map == null)
      return;
    void'(m_map.insert(index, t));
  endfunction
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // get
  //
  // Retrieve the item at the current position
  virtual function T get();
    if(m_map == null)
      return m_empty;
    return m_map.get(index);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // get_index
  //
  // Reteive the index (key) associated with the item at the current
  // position.
  virtual function KEY get_index();
    return index;
  endfunction
  
endclass

//----------------------------------------------------------------------
// class: map_fwd_iterator
//
// Traverse the map in the forward direction.
//----------------------------------------------------------------------
class map_fwd_iterator#(type KEY=int, type T=int, type P=void_traits)
  extends map_iterator_base#(KEY,T,P)
  implements fwd_iterator;

  // constructor
  //
  // Optionally, bind a map to the iterator.
  function new(map_t map_inst = null);
    super.new(map_inst);
  endfunction  

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // first
  //
  // Move the current position to the first item in the map.  The item
  // that is chosen as the first one is based on the underlying
  // associative array.
  virtual function bit first();
    if(m_map == null || m_map.size() == 0)
      return 0;
    state = FIRST;
    return m_map.first(index);
  endfunction
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // next
  //
  // Move the current position to the next item item in the map.  The
  // item defined as the next one is based on the underlying associative
  // array.
  virtual function bit next();

    // check for error conditions
    if((m_map == null)    || (m_map.size() == 0) ||
       (state == INVALID) || (state == LAST))
      return 0;

    // Are we at the last item?  If so, change state to LAST.
    if((state == VALID || state == FIRST) && is_last()) begin
      state = LAST;
      return 1;
    end

    state = VALID;
    void'(m_map.next(index));
    return 1;

  endfunction
    
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // is_last
  //
  // Answer the question: Is the current item the last one in the map?
  virtual function bit is_last();

    KEY last_key;

    // check for error conditions
    if((m_map == null) || (m_map.size() == 0) || (state == INVALID))
      return 0;

    // Reteive the last key from the associative array and see if the
    // index is pointing to that item.
    void'(m_map.last(last_key));
    return (index == last_key);

  endfunction
    
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // at_end
  //
  // Answer the question: Are we at the end of the map -- past the lsat
  // item?
  virtual function bit at_end();
    return ((m_map != null) &&
	    ((m_map.size() == 0) || ((m_map.size() > 0) && (state == LAST))));
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // skip
  //
  // Skip forward the number of places specified by distance.  Since
  // this is a forward iterator we can only skip in the forward
  // direction.
  virtual function bit skip(signed_index_t distance);
    index_t ix;
    bit ok;

    // check for error conditions
    if( (m_map == null)    || m_map.size() == 0 ||
        (state == INVALID) || (distance < 0))
      return 0;

    // Use the next() operation to advance the current position.
    ok = 1;
    for(ix = 0; (ix < distance) && ok; ix++) begin
     ok = next();
    end

    return 1;
    
  endfunction
    
endclass

//----------------------------------------------------------------------
// class: map_bkwd_iterator
//
// Traverse the map in the backward direction
//----------------------------------------------------------------------
class map_bkwd_iterator#(type KEY=int, type T=int, type P=void_traits)
  extends map_iterator_base#(KEY,T,P)
  implements bkwd_iterator;

  // constructor
  //
  // Optionally, bind a map to the iterator
  function new(map_t map_inst = null);
    super.new(map_inst);
  endfunction  
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // last
  //
  // Move the current position to the last item in the map
  virtual function bit last();

    // check for error conditions
    if((m_map == null) || (m_map.size() == 0))
      return 0;
    
    state = LAST;
    return m_map.last(index);
    
  endfunction
    
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // prev
  //
  // Move the current position to the previous item in the map[
  virtual function bit prev();

    // check for error conditions
    if((m_map == null)  || (m_map.size() == 0) ||
       (state == FIRST) || (state == INVALID))
      return 0;

    // Is the current position already pointing to the first item in the
    // map?
    if((state == VALID || state == LAST) && is_first()) begin
      state = FIRST;
      return 1;
    end

    state = VALID;
    void'(m_map.prev(index));
    return 1;

  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // is_first()
  //
  // Answer the question: Is the current position pointing to the first
  // item in the map?
  virtual function bit is_first();

    KEY k;
    T t;

    // chgeck for error conditions
    if((m_map == null) || (m_map.size() == 0)  || (state == INVALID))
      return 0;

    if(!m_map.first(k))
      return 0;

    t = get();
    return (index == k);

  endfunction
    
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // at_beginning
  //
  // Answer the question: Is the current position at the beginning of
  // the map -- before the first item?
  virtual function bit at_beginning();
    return ((m_map != null) &&
	    ((m_map.size() == 0) || ((m_map.size() > 0) && (state == FIRST))));
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // skip
  //
  // Move the current position one or more places.  Since this is a
  // backward iterator we can only move backward -- that is, distance
  // can only be negative.
  virtual function bit skip(signed_index_t distance);
    index_t ix;
    bit ok;

    // check for error conditions    
    if((m_map == null) || (m_map.size() == 0) || (distance > 0))
      return 0;

    ok = 1;
    for(ix = 0; (ix < -distance) && ok; ix++) begin
     ok = prev();
    end

    return 1;
    
  endfunction
    
endclass

//----------------------------------------------------------------------
// class: map_random_iterator
//
// Map_random_iterator is derived from map_fwd_iterator in order to use
// the next() and skip() functionality.  I wish that SystemVerilog had
// the concept of private and public inheritance because the forward
// iterator functionality should not be available through this class --
// only the functions defined in the random_iterator interface should be
// available.  The others are there to implment the random_iterator
// functions.  To get fwd_iterator functionality use the fwd_iterator or
// bidir_iterator classes.
//----------------------------------------------------------------------
class map_random_iterator#(type KEY=int, type T=int, type P=void_traits)
  extends map_fwd_iterator#(KEY,T,P)
  implements random_iterator;

  local const int default_seed = 1;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // constructor
  //
  // Optionally, bind a map to the iterator.
  function new(map_t map_inst = null);
    super.new(map_inst);
    set_default_seed();
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // set_seed
  //
  // Set the seed for the RNG
  virtual function void set_seed(int seed);
    int n = $urandom(seed);
  endfunction

  // set_default_seed
  //
  // Set the seed back to the default for the RNG.
  virtual function void set_default_seed();
    set_seed(default_seed);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // random
  //
  // Choose a random entry from the map.
  virtual function bit random();
    index_t n;
    index_t ix;
    bit ok;

    // check for error conditions
    if((m_map == null) || (m_map.size() == 0))
      return 0;

    n = $urandom() % m_map.size();
    void'(first());
    void'(skip(n));
    
    return 1;

  endfunction

endclass


//----------------------------------------------------------------------
// class: map_bidir_iterator
//
// Traverse either forwards or backward through a map.  Becuase
// SystemVerilog does not allow multiple inheritance we had to duplicate
// code from the foward and backward iterators.  The only function that
// is different is the skip function which, in the bidirectional
// iterator, allows you to skip either forwards or backwards.1
// ----------------------------------------------------------------------
class map_bidir_iterator#(type KEY=int, type T=int, type P=void_traits)
  extends map_iterator_base#(KEY,T,P)
  implements fwd_iterator, bkwd_iterator;

  function new(map_t map_inst = null);
    super.new(map_inst);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit first();
    if(m_map == null || m_map.size() == 0)
      return 0;
    state = FIRST;
    return m_map.first(index);
  endfunction
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit next();
    if((m_map == null)    || (m_map.size() == 0) ||
       (state == INVALID) || (state == LAST))
      return 0;

    if((state == VALID || state == FIRST) && is_last()) begin
      state = LAST;
      return 1;
    end

    state = VALID;
    void'(m_map.next(index));
    return 1;

  endfunction
    
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit is_last();

    KEY last_key;

    if((m_map == null) || (m_map.size() == 0) || (state == INVALID))
      return 0;

    void'(m_map.last(last_key));
    return (index == last_key);

  endfunction
    
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit at_end();
    return ((m_map != null) &&
	    ((m_map.size() == 0) || ((m_map.size() > 0) && (state == LAST))));
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit last();
    if((m_map == null) || (m_map.size() == 0))
      return 0;
    state = LAST;
    return m_map.last(index);
  endfunction
    
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit prev();
    if((m_map == null)  || (m_map.size() == 0) ||
       (state == FIRST) || (state == INVALID))
      return 0;

    if((state == VALID || state == LAST) && is_first()) begin
      state = FIRST;
      return 1;
    end

    state = VALID;
    void'(m_map.prev(index));
    return 1;

  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit is_first();

    KEY k;
    T t;

    if((m_map == null) || (m_map.size() == 0)  || (state == INVALID))
      return 0;

    if(!m_map.first(k))
      return 0;

    t = get();
    return (index == k);

  endfunction
    
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit at_beginning();
    return ((m_map != null) &&
	    ((m_map.size() == 0) || ((m_map.size() > 0) && (state == FIRST))));
  endfunction

  virtual function bit skip(signed_index_t distance);
    index_t ix;
    bit ok;
    
    if((m_map == null) || (m_map.size() == 0) || (state == INVALID))
      return 0;

    if(distance > 0) begin
      ok = 1;
      for(ix = 0; (ix < distance) && ok; ix++) begin
       ok = next();
      end
    end
    
    if(distance < 0) begin
      ok = 1;
      for(ix = 0; (ix < -distance) && ok; ix++) begin
        ok = prev();
      end
    end

    return 1;
    
  endfunction

endclass
