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
//
// class: map
//
// Implements a class-based dynamic associative array. Allows sparse
// arrays to be allocated on demand, and passed and stored by reference.
//----------------------------------------------------------------------

class map #(type KEY=int, type T=void_t, type P=void_traits)
  extends typed_container #(T,P);

  typedef map #(KEY,T,P) this_t;

  protected T m_map[KEY];

  // Use the default constructor, no need to provide one explicitly

  //====================================================================
  // group: Map Implementation Interface
  //====================================================================

  //--------------------------------------------------------------------
  // function: get
  //
  // Returns the item with the given ~key~.
  //--------------------------------------------------------------------
  virtual function T get(KEY key);
    if (!m_map.exists(key))
      return m_empty;
    return m_map[key];
  endfunction
  
  //--------------------------------------------------------------------
  // function: insert
  //
  // Adds the given (~key~, ~item~) pair to the map. The return value
  // indicated whether or not the key is a duplicate -- i.e. is already
  // in the database.  The value is overwritten for duplicates.
  //--------------------------------------------------------------------
  virtual function bit insert (KEY key, T item);

    bit rtn = !(m_map.exists(key));

    m_map[key] = item;

    return rtn;

  endfunction

  //--------------------------------------------------------------------
  // function: size
  //
  // Returns the number of uniquely keyed items stored in the map.
  //--------------------------------------------------------------------
  virtual function size_t size();
    return m_map.num();
  endfunction

  //--------------------------------------------------------------------
  // function: delete
  //
  // Removes the item with the given ~key~ from the map.
  //--------------------------------------------------------------------
  virtual function bit delete (KEY key);
    if (!exists(key))
      return 0;
    m_map.delete(key);
    return 1;
  endfunction

  //--------------------------------------------------------------------
  // function: clear
  //
  // Remove all of the elements from the map.
  //--------------------------------------------------------------------
  virtual function void clear();
    m_map.delete();
  endfunction

  //--------------------------------------------------------------------
  // function: exists
  //
  // Returns 1 if a item with the given ~key~ exists in the map,
  // 0 otherwise.
  //--------------------------------------------------------------------
  virtual function bit exists (KEY key);
    return (m_map.exists(key) != 0);
  endfunction

  //--------------------------------------------------------------------
  // function: copy
  //
  // Perform a shallow copy of a map. Copy the map supplied as an
  // argument into this map.
  //--------------------------------------------------------------------
  function void copy(this_t rhs);

    T t;
    KEY idx;

    if(rhs == null)
      return;

    clear(); // empty the map

    if(rhs.first(idx)) begin
       do begin
         t = rhs.get(idx);
         insert(idx, t);
       end
       while(rhs.next(idx));
     end
       
  endfunction

  //--------------------------------------------------------------------
  // function: clone
  //
  // Clone the map.  The implementaiton is based on copy()
  //--------------------------------------------------------------------
  function this_t clone();
    this_t m = new();
    m.copy(this);
    return m;
  endfunction

  //--------------------------------------------------------------------
  // function: compare
  //
  // Compare two maps.  Maps are either equal or not.  The notion of one
  // map being less than or greater than onother is undefined.  This
  // function will return 1 if the two are not equal, or zero if they
  // are.  It will never return a value less than zero.
  // --------------------------------------------------------------------
  virtual function int compare(this_t m);
    return !equal(m);
  endfunction


  //--------------------------------------------------------------------
  // function: equal
  //
  // Determine if the map supplied by the argument t is equal to this
  // one.  The two maps are equal if all of the elements are equal.  To
  // elements are equal if 1) they have the same key, and 2) P::equal()
  // returns 1.
  //--------------------------------------------------------------------
  virtual function bit equal(this_t m);

    T t;
    KEY idx;
    bit eq;

    // Two maps cannot be equal if they have a different number of
    // elements.
    if(m == null || size() != m.size())
      return 0;

    // Traverse all of the keys in the map to determine pair-wise
    // equivalence.  For each key, look it up in this map.  Then find
    // its counterpart in the argument map. The maps are not equal if
    // the counterpart is not located.  If it its, then equivalence
    // between elements is determined by P::equal().  If the
    // counterpart does not exist in the argument map, then get() will
    // return P::empty.  IN that case P::equal() compares the element
    // with P::empty.
    eq = 1;
    if(m_map.first(idx)) begin
       do begin
         t = m_map[idx];
         eq &= P::equal(t, m.get(idx));
       end
      while(eq && m_map.next(idx));
    end

    return eq;
       
  endfunction

  //====================================================================  
  // group: Iteration Implementation Interface
  //
  // These functions are for use by iterators and should not be used
  // directly.  These must be public in order for the iterators to have
  // access.  However, they are not part of the public interface.  Don't
  // call them!
  //====================================================================  

  // function: first
  //
  virtual function bit first(ref KEY index);
    return m_map.first(index);
  endfunction

  // function: last
  //
  virtual function bit last (ref KEY index);
    return m_map.last(index);
  endfunction

  // function: get_last
  // non-virtual function
  // The reason this is non-virtal is so that any overriding virtual
  // functions still correctly get the last element without modifying
  // the state of the iterator.
  //
  function KEY get_last();
    KEY k;
    m_map.last(k);
    return k;
  endfunction

  // function: next
  //
  virtual function bit next(ref KEY index);
    return m_map.next(index);
  endfunction

  // function: prev()
  //
  virtual function bit prev(ref KEY index);
    return m_map.prev(index);
  endfunction

endclass

//----------------------------------------------------------------------
// class: singleton_map
//----------------------------------------------------------------------
class singleton_map  #(type KEY=int, type T=void_t, type P=void_traits)
  extends map #(KEY,T,P);

  typedef singleton_map#(KEY,T,P) this_t;
  static local this_t t;

  protected function new();
    // You can't call new() for this class!  You can only obtain handles
    // to the class object thrpugh the get_inst() function
  endfunction
  
  static function this_t get_inst();
    if(t == null)
      t = new();
    return t;
  endfunction

endclass
