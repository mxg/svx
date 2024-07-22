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
// class: vector
//
// Vector class.  The uderlying structure is based on the built-in queue.
// Provides an interface for funciton mapping and for combining vectors in
// addition to the usual funcitons provided by the queue structure.
//
// Space for the elements in the vector do not have to be
// pre-allocated. The vector will allocate space when writting a new
// element above the current high water mark.  This becomes the new high
// water mark.  When you write a new element above the current high water
// mark a new, larger vector is allocated and a shallow copy is done to
// move the elements from the old vector to the new one.  This is a
// fairly expensive operation and should be done infrequently.
//----------------------------------------------------------------------
class vector #(type T=int, type P=void_traits)
  extends typed_container #(T,P);

  typedef vector #(T,P) this_t;
  typedef T vector_type[$];

  protected vector_type m_vector;

  // Default constructor used, no need to explicitly supply one
  
  //--------------------------------------------------------------------
  // create
  //
  // Create a new vector and populate it with a literal list
  //--------------------------------------------------------------------
  static function this_t create(vector_type list);
    this_t v = new();
    v.m_vector = list;
    return v;
  endfunction
  //--------------------------------------------------------------------
  // function: extend
  //
  // Extend the vector to a larger size than it is currently.  Do this
  // by pushing new elements onto the array that forms the foundation of
  // the vector object.
  //--------------------------------------------------------------------
  function void extend(size_t sz);

    size_t i;

    for(i = 0; i < sz; i++)
      m_vector.push_back(m_empty);

  endfunction
      
  //--------------------------------------------------------------------
  // Group: Vector Manipulaton Interface
  //
  // Basic vector manipulation functions. 
  //--------------------------------------------------------------------

  //--------------------------------------------------------------------
  // function: write
  //
  // Write the vector element at a specified index.  If the new element
  // would be outsize the current extents of the vector, then extend the
  // vector to fit the new element.
  //--------------------------------------------------------------------
  function void write(index_t idx, T t);
    if(idx >= size())
      extend(idx-size()+1);
    m_vector[idx] = t;
  endfunction

  //--------------------------------------------------------------------
  // function: read
  //
  // Read the vector element at a specified index.  If the index is
  // outside the extents of the vector then return the empty element.
  //--------------------------------------------------------------------
  function T read(index_t idx);
    if(idx >= size())
      return m_empty;
    return m_vector[idx];
  endfunction

  //--------------------------------------------------------------------
  // function:  size
  //--------------------------------------------------------------------
  function size_t size();
    return m_vector.size();
  endfunction

  //--------------------------------------------------------------------
  // function: clear
  //
  // remove all the elements in the vector; return it to an empty
  // state.
  //--------------------------------------------------------------------
  function void clear();
    m_vector.delete();
  endfunction

  //--------------------------------------------------------------------
  // function: copy
  //
  // Perform a shallow copy of a vector.
  //--------------------------------------------------------------------
  function void copy(this_t vec);

    T t;
    int unsigned idx;

    if(vec == null)
      return;

    clear(); // empty the vector

    for(idx = 0; idx < vec.size(); idx++) begin
      t = vec.read(idx);
      m_vector.push_back(t);
    end

  endfunction

  //--------------------------------------------------------------------
  // function: clone
  //
  // Clone a vector
  //--------------------------------------------------------------------
  function this_t clone();
    this_t v = new();
    v.copy(this);
    return v;
  endfunction

  //--------------------------------------------------------------------
  // function: compare
  //
  // Compare two vectors.  The vectors are either equal or not.  The
  // notion of one vector being less than or greater than another vector
  // is undefined.
  // --------------------------------------------------------------------
  function int compare(this_t v);
    return !equal(v);
  endfunction

  //--------------------------------------------------------------------
  // function: equal
  //
  // Compare a member of the vector with another for equality
  //--------------------------------------------------------------------
  virtual function bit equal(this_t v);
    int unsigned i;

    if(v.size() != size())
      return 0;

    for(i = 0; i < size() && P::equal(read(i), v.read(i)); i++);

    return (i >= size());

  endfunction

  //--------------------------------------------------------------------
  // function: sort
  //
  // Sort the vector. Use the sort function defined in the traits class
  // for this type.
  //--------------------------------------------------------------------
  function void sort();
    void'(P::sort(m_vector));
  endfunction

  //====================================================================
  //
  // Group: Vector Combination Interface
  //
  // These functions are for adding to an existing vector, either in
  // bulk or one at a time.
  //====================================================================  

  //--------------------------------------------------------------------
  // function: appendv
  //
  // Appends a literal vector passed in as an argument to the vector.
  // This could also be used to extend a vector.
  //--------------------------------------------------------------------
  function void appendv(vector_type v);
    m_vector = { m_vector, v };
  endfunction

  //--------------------------------------------------------------------
  // function: appendc
  //
  // Appends a literal element to the vector.  This could also be used
  // to extend a vector by one.
  //--------------------------------------------------------------------
  function void appendc(T t);
    m_vector = { m_vector, t };
  endfunction

  //--------------------------------------------------------------------
  // function: append
  //
  // Like appendv(), this function appends a vector passed in as an
  // argument to the vector. Unlike appendv(), append() takes a vector
  // class as an argument not a literal vector.
  //--------------------------------------------------------------------
  function void append(this_t v);
    appendv(v.m_vector);
  endfunction

endclass

//----------------------------------------------------------------------
// Common vector types
typedef vector#(int,              int_traits               ) int_vector;
typedef vector#(int unsigned,     int_unsigned_traits      ) intus_vector;
typedef vector#(longint,          longint_traits           ) longint_vector;
typedef vector#(longint unsigned, longint_unsigned_traits  ) longintus_vector;
typedef vector#(long_long_int_t,  long_long_int_traits     ) longlongint_vector;
typedef vector#(real,             real_traits              ) real_vector;
typedef vector#(string,           string_traits            ) string_vector;
