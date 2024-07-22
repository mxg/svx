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
// class: fcn_callbacks
//----------------------------------------------------------------------
class fcn_callbacks#(type T=int) extends fcn_behavior#(T);

  typedef fcn_behavior#(T) callback_t;
  deque#(callback_t) callbacks;

  function new();
    callbacks = new();
  endfunction

  function void add_callback(fcn_behavior#(T) cb);
    callbacks.push_back(cb);
  endfunction

  function bit fcn();

    callback_t cb;
    list_fwd_iterator#(callback_t, object_traits) iter;

    if(c == null || callbacks == null || callbacks.size() == 0)
      return 0;

    iter = new(callbacks);
    if(!iter.first())
      return 0;

    do begin
      cb = iter.get();
      cb.nb_apply(c);
      
    end
    while(iter.next());

    return 1;
    
  endfunction

endclass

//----------------------------------------------------------------------
// class: task_callbacks
//----------------------------------------------------------------------
class task_callbacks#(type T=int) extends task_behavior#(T);

  typedef task_behavior#(T) callback_t;
  deque#(callback_t) callbacks;

  function new();
    callbacks = new();
  endfunction

  function void add_callback(task_behavior#(T) cb);
    callbacks.push_back(cb);
  endfunction

  task tsk();

    callback_t cb;
    list_fwd_iterator#(task_behavior#(T), object_traits) iter;

    if(c == null || callbacks == null || callbacks.size() == 0)
      return;

    iter = new(callbacks);
    if(!iter.first())
      return;

    do begin
      cb = iter.get();
      cb.bind_context(c);
      cb.tsk();
    end
    while(iter.next());
    
  endtask

endclass
