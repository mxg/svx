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
// pri_queue
//
// The priority queue supports two operations, push and pop.  Push()
// inserts a new item into the queue.  Pop retrieves the item with
// the highest priority.

// The underlying structure of the priority queue is a map of queues
// -- that is, a map whose entries are queues.  The key for the map is
// the priority.  So, each unique priority value has its own queue of
// items.  Because each map entry is a queue, the items in each queue
// -- the items with the same priority -- are stored in the order in
// which they were inserted.
//
// To retrieve the item with the highest priority we rely on the fact
// that SystemVerilog's associative array is implemented using some
// sort of tree structure (the exact implementation details are
// unknown to SystemVerilog programmers). The associative array's
// last() function retrieves the key with the highest value.  Because
// the keys in the priority queue represent priorities, the last
// element is the one with the highest priority.
//----------------------------------------------------------------------
class pri_queue #(type T=int, type P=void_traits);

  // The priorty queue is a _compound_ data structure, a map of
  // queues. Each entry in the map is a queue.
  map#(pri_t, queue#(T, P), class_traits#(queue#(T, P))) qmap;
  map_bidir_iterator#(pri_t, queue#(T,P),
		      class_traits#(queue#(T,P))) iter;


  function new();
    qmap = new();     // create the map
    iter = new(qmap); // create the iterator and bind it to the map
  endfunction

  //--------------------------------------------------------------------
  // is_empty
  //
  // Does the queue contain any items?
  //--------------------------------------------------------------------
  function bit is_empty();
    return qmap.is_empty();
  endfunction
  
  //--------------------------------------------------------------------
  // push
  //
  // Put a new item into the queue.  The priority determines where it
  // is put into the queue
  //--------------------------------------------------------------------
  function push(pri_t pri, T item);
    queue#(T,P) q;

    // If the prioroty queue has no other items that match the
    // priority of the one we are pusing, then create a new queue for
    // it and insert it into the map.
    if(qmap.get(pri) == null) begin
      q = new();
      void'(qmap.insert(pri, q));
    end
    
    q = qmap.get(pri);
    q.put(item);
  endfunction

  //--------------------------------------------------------------------
  // pop
  //
  // Pop retrieves the highest priority item from the queue.
  //--------------------------------------------------------------------
  function T pop();
    queue#(T,P) q;
    T item;
    pri_t pri;

    if(iter.is_empty())
      return P::empty;

    // The last element in the map is the one with the highest
    // priority.
    void'(iter.last());
    pri = iter.get_index();
    q = iter.get();

    item = q.get(); // get() pops the item off the queue

    // If there are no more items with the same priority the remove
    // the queue.
    if(q.is_empty()) begin
      void'(qmap.delete(pri));
    end

    return item;
    
  endfunction

endclass


  
