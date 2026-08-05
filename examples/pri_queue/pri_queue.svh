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
//----------------------------------------------------------------------
class pri_queue #(type T=int, type P=void_traits);

  map#(pri_t, queue#(T, P), class_traits#(queue#(T, P))) qmap;
  map_bidir_iterator#(pri_t, queue#(T,P),
		      class_traits#(queue#(T,P))) iter;


  function new();
    qmap = new();
    iter = new(qmap);
  endfunction

  //--------------------------------------------------------------------
  // is_empty
  //--------------------------------------------------------------------
  function bit is_empty();
    return qmap.is_empty();
  endfunction
  
  //--------------------------------------------------------------------
  // insert
  //--------------------------------------------------------------------
  function insert(pri_t pri, T item);
    queue#(T,P) q;
    
    if(qmap.get(pri) == null) begin
      q = new();
      void'(qmap.insert(pri, q));
    end
      
    q = qmap.get(pri);
    q.put(item);
  endfunction

  //--------------------------------------------------------------------
  // pull
  //--------------------------------------------------------------------
  function T pull();
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

    item = q.get();

    // If there are no more items with the same priority the remove
    // the queue.
    if(q.is_empty()) begin
      void'(qmap.delete(pri));
    end

    return item;
    
  endfunction

endclass


  
