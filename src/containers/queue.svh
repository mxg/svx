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
// class: queue
//
// A queue is a vector with fifo properties.  You can put an item on the
// head of the queue and get an item from the tail of the queue.  Get()
// is a mutating operation.  In other words, it removes the item from
// the queue.
//----------------------------------------------------------------------
class queue #(type T=int, type P=void_traits) extends vector#(T,P);

  typedef queue#(T,P) this_t;

  //--------------------------------------------------------------------
  // function: put
  //
  // Put an item into the head of the queue
  //--------------------------------------------------------------------
  virtual function void put(T t);
    m_vector.push_front(t);
  endfunction

  //--------------------------------------------------------------------
  // function: get
  //
  // pop an item off the tail of the queue.  Return an empty item if the
  // queue is empty.
  //--------------------------------------------------------------------
  virtual function T get();
    if(is_empty())
      return P::empty;
    return m_vector.pop_back();
  endfunction

  //--------------------------------------------------------------------
  // function: peek
  //
  // Return the item at the tail of the queue without modifying the
  // queue.  Successive calls to peek (without intervening calls to
  // get()) will return the same value
  //--------------------------------------------------------------------
  virtual function T peek();
    if(is_empty())
      return P::empty;
    return m_vector[$];
  endfunction

  //--------------------------------------------------------------------
  // function: is_empty
  //--------------------------------------------------------------------
  virtual function bit is_empty();
    return (size() == 0);
  endfunction

  //--------------------------------------------------------------------
  // function: clone
  //
  // Clone a stack
  //--------------------------------------------------------------------
  function this_t clone();
    this_t q = new();
    q.copy(this);
    return q;
  endfunction  
  
endclass

//----------------------------------------------------------------------
// Common queue types
typedef queue#(int,              int_traits               ) int_queue;
typedef queue#(int unsigned,     int_unsigned_traits      ) intus_queue;
typedef queue#(longint,          longint_traits           ) longint_queue;
typedef queue#(longint unsigned, longint_unsigned_traits  ) longintus_queue;
typedef queue#(long_long_int_t,  long_long_int_traits     ) longlongint_queue;
typedef queue#(real,             real_traits              ) real_queue;
typedef queue#(string,           string_traits            ) string_queue;

//----------------------------------------------------------------------
// fixed_size_queue
//----------------------------------------------------------------------
class fixed_size_queue #(type T=int, type P=void_traits)
  extends queue #(T,P);

  typedef fixed_size_queue#(T,P) this_t;

  local int unsigned max_size;
  local bit push_ok;

  //--------------------------------------------------------------------
  // constructor
  //--------------------------------------------------------------------
  function new(int unsigned n = 1);
    set_max_size(n);
    push_ok = 0;
  endfunction

  //--------------------------------------------------------------------
  // set_max_size
  //
  // Change the maximum size.  The maximum size is the maximum number of
  // entries that can be in the queue at the same time.  The new size is
  // massaged to ensure that he queue is never in an illegal state.  If
  // zero is passed in the we rever to the minimum size of one.  If the
  // new size is less than the number of elements already in the queue
  // then we use the number of elements in the queue as the new size.
  // That way we an never have more elements in the queue than allowed
  // by the current setting of max_size
  //--------------------------------------------------------------------
  virtual function void set_max_size(int unsigned n);
    if(n == 0)
      n = 1;
    if(n < size())
      n = size();
    max_size = n;
  endfunction

  //--------------------------------------------------------------------
  // get_max_size
  //
  // Return the current value of max_size
  //--------------------------------------------------------------------
  virtual function int unsigned get_max_size();
    return max_size;
  endfunction

  //--------------------------------------------------------------------
  // put
  //
  // Insert a new value at the tail of the queue.  If the insertion
  // would cause the queue to hold more than the allowed maximum then we
  // don't do the push.  The state variable push_ok is updated to
  // reflect whether or not the push succeeded.
  //--------------------------------------------------------------------
  virtual function void put(T t);
    if(size() < max_size) begin
      super.put(t);
      push_ok = 1;
    end
    else
      push_ok = 0;
  endfunction

  //--------------------------------------------------------------------
  // last_push_succeeded
  //
  // Return the status of the last push.  Did it succeed?
  //--------------------------------------------------------------------
  virtual function bit last_push_succeeded();
    return push_ok;
  endfunction

  //--------------------------------------------------------------------
  // is_full
  //
  // Return one if the size of the queue has read the max size allowed,
  // zero otherwise.
  //--------------------------------------------------------------------
  virtual function bit is_full();
    return (size() >= get_max_size());
  endfunction
  
  //--------------------------------------------------------------------
  // copy
  //
  // Make a copy of the queue.  For the fixed_size_queue some additional
  // state variables must be copied in addition to the contents of the
  // queue itself.
  //--------------------------------------------------------------------
  function void copy(this_t q);
    super.copy(q);
    set_max_size(q.get_max_size());
    push_ok = q.last_push_succeeded();
  endfunction

  //--------------------------------------------------------------------
  // clone
  //
  // The usual clone function for making an identical copy of the queue.
  //--------------------------------------------------------------------
  function this_t clone();
    this_t q = new();
    q.copy(this);
    return q;
  endfunction  

  //--------------------------------------------------------------------
  // equal
  //
  // Determine if this fixed_size_vector is equivalent to one passed in
  // as an argument.  Because fixed_size_queue is derived from vector we
  // can assign the fixed_size_queue to an argument of the base type.
  // This lets us be consistent with queue::equal().  Then we do some
  // cast magic to cast it to this type (this_t).
  //--------------------------------------------------------------------
  virtual function bit equal(vector#(T,P) v);
    this_t q;

    if(!$cast(q, v))
      return 0;
    
    return (super.equal(v) &&
            (get_max_size() == q.get_max_size()) &&
            (push_ok == q.last_push_succeeded()));
  endfunction

endclass
