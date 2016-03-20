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
// class: list_iterator_base
//
// Base class for list iterators.  List iterators can be used to iterate
// over vectors or any class derived from vector#(), including stack,
// queue, and deque.
// ----------------------------------------------------------------------
virtual class list_iterator_base#(type T=int, type P=void_traits)
  extends typed_iterator#(T,P);
  
  typedef vector#(T,P) list_t;
  // Vector over which we will be iterating
  protected list_t m_list;
  // Index representing the current location of the iterator.  It is a
  // number [0, N-1] where N is the number of items in the vector.
  protected signed_index_t idx;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // constructor
  //
  // If a vector is supplied as an argument then it is bound to the
  // iterator.  If the argument is optional then the iterator remains
  // unbound and bind_list() must be called to bind the iterator to a
  // vector.
  function new(list_t list = null);
    super.new();
    bind_list(list);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // bind_list
  //
  // Bind a vector to the iterator.  A vector must be bound in order for
  // the iterator to do anything useful.
  virtual function void bind_list(list_t list = null);
    m_list = list;
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  // set
  //
  // Set the value of the item at the current location of the iterator.
  virtual function void set(T t);
    if(m_list != null)
      m_list.write(idx, t);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // get
  //
  // Retrieve the object at the current location of the iterator.
  virtual function T get();
    if(m_list == null)
      return P::empty;
    else
      return m_list.read(idx);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // skip
  //
  // Skip forward or backward.  If distance is positive then the
  // iterator moves forward, if distance is negaitve then the iterator
  // moves backward.  In no case will the current position of the
  // iterator by moved out of bounds.  That is the current position can
  // never be less than 0 or greater than N-1.
  virtual function bit skip(signed_index_t distance);
    signed_index_t tmp_idx;

    // Increment or decrement the index using the distance.  Distance
    // may be less than zero.
    tmp_idx = idx + distance;

    // Is the new (computed) index within range of the current list?
    if ((m_list == null) || (tmp_idx < 0) || (tmp_idx >= m_list.size()))
      return 0;

    // New index is in the valid range, 
    idx = tmp_idx;
    return 1;
  endfunction

endclass

//----------------------------------------------------------------------
// class list_fwd_iterator
//
// Traverse the vector in the forward direction.
//----------------------------------------------------------------------
class list_fwd_iterator#(type T=int, type P=void_traits)
  extends list_iterator_base#(T,P)
  implements fwd_iterator;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // constructor
  //
  // Optionally bind the iterator to a vector.
  function new(list_t list_inst = null);
    super.new(list_inst);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // first
  //
  // Move the current position of the iterator to the first item in the
  // vector -- i.e. the 0th position.
  virtual function bit first();
    idx = 0;
    return (m_list != null && m_list.size() > 0);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // next
  //
  // Advance the current position to the next item, the one whose index
  // is one greater than the current index.  If the next() position is
  // beyond the end of the vector then the iterator is in the at_end()
  // condition.
  virtual function bit next();
    if((m_list == null) || (m_list.size() == 0) ||
       (idx > 0 && (idx >= m_list.size())))
      return 0;
    idx++;
    return 1;
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // is_last()
  //
  // Answer the question: is the current position the last item in the
  // vector?
  virtual function bit is_last();
    return ((m_list != null) && (m_list.size() > 0) && (idx >= m_list.size() - 1));
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // at_end
  //
  // Answer the question: is the current position at the end of the
  // list?  Note that is_last() and at_end() are two different
  // conditions. At_end() is the condition where the current postion is
  // past the end of the list and not referring to a valid location.
  virtual function bit at_end();
    if(m_list == null || m_list.size() == 0)
      return 1;
    return (idx >= m_list.size());
  endfunction

endclass


//----------------------------------------------------------------------
// class: list_bkwd_iterator
//
// Traverse the vector in the backward direction.
//----------------------------------------------------------------------
class list_bkwd_iterator#(type T=int, type P=void_traits)
  extends list_iterator_base#(T,P)
  implements bkwd_iterator;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // constructor
  //
  // Optionally bind a vector to the iterator. 
  function new(list_t list_inst = null);
    super.new(list_inst);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // last
  //
  // Most the current position to the last item in the vector -- i.e. to
  // position N-1.
  virtual function bit last();
    if(m_list == null)
      return 0;
    idx = m_list.size() - 1;
    return (m_list.size() > 0);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // prev
  //
  // Move the current postion to the item whose index is one less than
  // the current one.  If the current position becomes negative, that
  // is, goes beyond the beginning of the vector, then the iterator is
  // in the condition at_beginning().
  virtual function bit prev();
    if(m_list == null || m_list.size() == 0 || idx < 0)
      return 0;
    idx--;
    return 1;
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // is_first
  //
  // Answer the question: Is the current position the first item in the
  // vector, the 0th position?
  virtual function bit is_first();
    return ((m_list != null) && ((m_list.size() > 0) && (idx == 0)));
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // at_beginning
  //
  // Answer the question: Is the current position of the iterator beyond
  // the first item.
  virtual function bit at_beginning();
    if(m_list == null || m_list.size() == 0)
      return 1;
    return (idx < 0);
  endfunction

endclass

//----------------------------------------------------------------------
// class: list_random_iterator
//
// Choose a random item in the vector.
//----------------------------------------------------------------------
class list_random_iterator#(type T=int, type P=void_traits)
  extends list_iterator_base#(T,P)
  implements random_iterator;

  local const int default_seed = 1;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // constructor
  //
  // Optionally bind a vector to the iterator
  function new(list_t list_inst = null);
    super.new(list_inst);
    set_default_seed();
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // set_seed
  //
  // Set a new random seed for the RNG
  virtual function void set_seed(int seed);
    int n = $urandom(seed);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // set_default_seed
  //
  // set a new default seed for the RNG
  virtual function void set_default_seed();
    set_seed(default_seed);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // random
  //
  // Choose a random item in the vector and set the current position to
  // this randomly chosen item.
  virtual function bit random();
    int unsigned n;

    if((m_list == null) || (m_list.size() == 0))
      return 0;

    n = $urandom() % m_list.size();
    idx = n;
    return 1;

  endfunction

endclass

//----------------------------------------------------------------------
// class: list_bidir_iterator
//
// Traverse the vector in either the foward or backward direction.
//----------------------------------------------------------------------
class list_bidir_iterator#(type T=int, type P=void_traits)
  extends list_iterator_base#(T,P)
  implements fwd_iterator, bkwd_iterator;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  function new(list_t list_inst = null);
    super.new(list_inst);
  endfunction
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit first();
    idx = 0;
    return (m_list != null && m_list.size() > 0);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit next();
    if((m_list == null) || (m_list.size() == 0) ||
       (idx > 0 && (idx >= m_list.size())))
      return 0;
    idx++;
    return 1;
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit is_last();
    return ((m_list != null) && (m_list.size() > 0) && (idx >= m_list.size() - 1));
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit at_end();
    if(m_list == null || m_list.size() == 0)
      return 1;
    return (idx >= m_list.size());    
  endfunction
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit last();
    if(m_list == null)
      return 0;
    idx = m_list.size() - 1;
    return (m_list.size() > 0);
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit prev();
    if(m_list == null || m_list.size() == 0 || idx < 0)
      return 0;
    idx--;
    return 1;
  endfunction
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit is_first();
    return ((m_list != null) && ((m_list.size() > 0) && (idx == 0)));
  endfunction

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  virtual function bit at_beginning();
    if(m_list == null || m_list.size() == 0)
      return 1;
    return (idx < 0);
  endfunction

endclass

//----------------------------------------------------------------------
// Common list iterators
//
// Forward iterators
typedef list_fwd_iterator#(int,              int_traits             ) list_fwd_int_iterator;
typedef list_fwd_iterator#(int unsigned,     int_unsigned_traits    ) list_fwd_intus_iterator;
typedef list_fwd_iterator#(longint,          longint_traits         ) list_fwd_longint_iterator;
typedef list_fwd_iterator#(longint unsigned, longint_unsigned_traits) list_fwd_longintus_iterator;
typedef list_fwd_iterator#(long_long_int_t,  long_long_int_traits   ) list_fwd_longlongint_iterator;
typedef list_fwd_iterator#(real,             real_traits            ) list_fwd_real_iterator;
typedef list_fwd_iterator#(string,           string_traits          ) list_fwd_string_iterator;

//
// Backward iterators
//
typedef list_bkwd_iterator#(int,              int_traits             ) list_bkwd_int_iterator;
typedef list_bkwd_iterator#(int unsigned,     int_unsigned_traits    ) list_bkwd_intus_iterator;
typedef list_bkwd_iterator#(longint,          longint_traits         ) list_bkwd_longint_iterator;
typedef list_bkwd_iterator#(longint unsigned, longint_unsigned_traits) list_bkwd_longintus_iterator;
typedef list_bkwd_iterator#(long_long_int_t,  long_long_int_traits   ) list_bkwd_longlongint_iterator;
typedef list_bkwd_iterator#(real,             real_traits            ) list_bkwd_real_iterator;
typedef list_bkwd_iterator#(string,           string_traits          ) list_bkwd_string_iterator;

//
// Bidirectional iterators
//
typedef list_bidir_iterator#(int,              int_traits             ) list_bidir_int_iterator;
typedef list_bidir_iterator#(int unsigned,     int_unsigned_traits    ) list_bidir_intus_iterator;
typedef list_bidir_iterator#(longint,          longint_traits         ) list_bidir_longint_iterator;
typedef list_bidir_iterator#(longint unsigned, longint_unsigned_traits) list_bidir_longintus_iterator;
typedef list_bidir_iterator#(long_long_int_t,  long_long_int_traits   ) list_bidir_longlongint_iterator;
typedef list_bidir_iterator#(real,             real_traits            ) list_bidir_real_iterator;
typedef list_bidir_iterator#(string,           string_traits          ) list_bidir_string_iterator;
