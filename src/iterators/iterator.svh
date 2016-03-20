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
// Iterator Base Classes
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// class: iterator_base
//----------------------------------------------------------------------
interface class iterator_base;

  // Skip forward or backward in an ordered container. Skip forward if
  // distance is greater than zero; skip backward if the distance is
  // less than zero; don't move the index at all if distance is zero.
  // In no case can the index be moved beyond the beginning or end of
  // the ordered container.  The result of skip() must be a valid index.
  pure virtual function bit skip(signed_index_t distance);
endclass

//----------------------------------------------------------------------
// class: fwd_iterator
//
// The forward iterator provides an index into an ordered
// container. Operations on the iterator allow the iterator be reset to
// the beginning of the ordered container or move the index in the
// foward direction -- e.g. increasing the index.
//----------------------------------------------------------------------
interface class fwd_iterator extends iterator_base;

  // Move the iterator to the first item in the ordered container --
  // typically the one with the smallest index.  Return 1 if the
  // operation is successful; 0 otherwise.  The operation will be
  // unsuccessful if the iterator is not bound to a container or the
  // container is empty.
  pure virtual function bit first();

  // Move the iterator to the next item in the ordered container.  Next
  // means move forward.  A call to next() is semantically equivalent to
  // calling skip(1).  A call to next() can move the iterator the to end
  // state, which is beyond the end of the list an dnot pointing to a
  // valid item.  Return a 1 if the operation succeeds, a 0 otherwise.
  // The next() operation can fail if the iterator is not bound to a
  // container, the container is empty, or the iterator is in the end
  // state.
  //
  // Note that next() functionality is not exactly the same as the array
  // operation of the same name defined in the SystemVerilog language.
  // The SystemVerilog next() returns 0 when the last index is
  // retrieved.  In the implementations here it is expected that next()
  // will return 0 onky _after_ the last index is retrieved.  This lets
  // you write idioms such as:
  //
  //    iter.first();
  //    while(!iter.at_end()) begin
  //      iter.next();
  //    end
  //
  // Here is another idiom for traversing a container in the forward
  // direction:
  //
  //    iter.first();
  //    do begin
  //      iter.next();
  //    end while(!iter.at_end());
  //
  pure virtual function bit next();

  // Is_last() asks the question: "is the iterator pointing to the last
  // item in the ordered container?"  If so, return 1, otherwise return
  // 0.
  pure virtual function bit is_last();

  // At_end() queries the iterator as to whether or not it is in the end
  // state.  If so, return 1, otherwise return 0.
  pure virtual function bit at_end();
endclass

//----------------------------------------------------------------------
// class: bkwd_iterator
//----------------------------------------------------------------------
interface class bkwd_iterator extends iterator_base;

  // Move the iterator to the last item in the ordered container --
  // typically the one with the highest index.  Return 1 if the
  // operation was successful, 0 otherwise.  The operation can fail if
  // the iterator is not bound to a container or if the container is
  // empty.
  pure virtual function bit last();

  // Move the iterator to the previous item in the list, typically the
  // one with the next smaller index.  Prev() is semantically equivalent
  // to skip(-1).  Return 1 if the operation is successful, otherwise
  // return 0.  The operation an fail if the iterator is not bound to a
  // container, the container is empty, or the iterator is already at
  // the beginning of the container.
  pure virtual function bit prev();

  // Is_first() asks the question: "is the iterator pointing to the
  // first item in the bound ordered container?"  If so, return 1,
  // otherwise return 0.
  pure virtual function bit is_first();

  // At_beginning return 1 if the itertor is at the beginning of the
  // list. That is, the iterator is beyond the first item in the list
  // (going in a backwards direction).
  pure virtual function bit at_beginning();
endclass

//----------------------------------------------------------------------
// class: random_iterator
//----------------------------------------------------------------------
interface class random_iterator extends iterator_base;

  // Randomly select a valid element in the bound container.  The
  // function will return 1 if it succeeds, otherwise it wil return a 0.
  // Random() will fail if the iterator is not bound to a container or
  // if the container is empty.
  pure virtual function bit random();
  pure virtual function void set_seed(int seed);
  pure virtual function void set_default_seed();
endclass

//----------------------------------------------------------------------
// class: typed_iterator
//
// A typed iterator is an iterator that additionally has a current
// object that can be retrieved.  All iterators extend typed_iterator#()
// and implement various iterator interfaces.
//----------------------------------------------------------------------
virtual class typed_iterator #(type T=int, type P=void_traits)
  extends object;

  protected T m_empty;

  function new();
    assert($cast(m_empty, P::empty));
  endfunction

  // Set the value of the item at the current index
  pure virtual function void set(T t);

  // Retrieve the iterm at the current index
  pure virtual function T get();

endclass
