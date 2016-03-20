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
// Map-Reduce
//
// Map-reduce is a divide-and-conquer programming technique.  A problem
// is divided int parts, each part is operated on separately and then
// the results are brought together at the end.  The "map" part of
// map-reduce is to map a process to a collection of contexts and launch
// the processes.  The "reduce" part is to take the results from each
// mapped process and aggreate or reduce them to a single result.
// ----------------------------------------------------------------------

//----------------------------------------------------------------------
// map_task
//
// An object that maps a task behavior to a vector of objects.  For each
// object in the vector a process is created and the object is bound to
// the process.
// ----------------------------------------------------------------------
class map_task#(type T=int,
                type P=int_traits,
                type B=task_behavior#(T));

  static task map(vector#(T,P) v);

    B beh;
    list_fwd_iterator#(T,P) iter;
    
    if(v == null)
      return;

    beh = new();
    iter = new(v);
    
    iter.first();
    while(!iter.at_end()) begin
      beh.apply(iter.get());
      iter.next();
    end

  endtask

endclass

//----------------------------------------------------------------------
// map_fcn
//
// map_fcn operates similarly to map_task except that the behavior is a
// function instead of a task with a process.  There is no launching of
// processes.  Instead, the the function is execued in-line for each
// element of the context vector.
// ----------------------------------------------------------------------
class map_fcn#(type T=int,
               type P=int_traits,
               type B=fcn_behavior#(T));
  
  static function void map(vector#(T,P) v);

    B beh;
    list_fwd_iterator#(T,P) iter;
    
    if(v == null)
      return;

    beh = new();
    iter = new(v);
    
    iter.first();
    while(!iter.at_end()) begin
      beh.nb_apply(iter.get());
      iter.next();
    end

  endfunction

endclass

//----------------------------------------------------------------------
// map_concurrent
//
// Map a process to a context vector and execute the processes
// concurrently.
// ----------------------------------------------------------------------
class map_concurrent#(type T=int,
                      type P=int_traits,
                      type B=task_behavior#(T));

  static task map(vector#(T,P) v);
    
    B beh;
    list_fwd_iterator#(T,P) iter;
    process_behavior#(T) p;
    process_group pg;
    
    if(v == null)
      return;

    pg = new();
    iter = new(v);

    // Put a process in the process group for every item in the vector.
    // Create a behavior and a process; bind the behavior to the
    // process; set the context as the next item in the vector; and
    // place the process in the process group.
    iter.first();
    while(!iter.at_end()) begin
      beh = new();
      p = new(beh);
      p.bind_context(iter.get());
      pg.add_process(p);
      iter.next();
    end

    // Launch all the processes in parallel and wait until they are all
    // done.  This is a procedural equivalent of fork/join
    pg.exec();
    pg.await();
    
  endtask

endclass

//----------------------------------------------------------------------
// reduce
//
// Once all the tasks or functions have been run against a context
// vector now reduce the result.  This required a reduce_behavior
// object.  It operates like a fcn_behavior, but takes two arguments,
// one is the context object and the other is the result of application
// of the reduce behavior to the previous context object.  This gives us
// a way to accumulate the results and ultimately return a single
// result.
// ----------------------------------------------------------------------
class reduce #(type T=int,
               type R=int,
               type P=int_traits,
               type B=reduce_behavior#(T,R));

  static function R reduce(vector#(T,P) v);

    B beh;
    list_fwd_iterator#(T,P) iter;
    R accum;
    
    if(v == null)
      return P::empty;

    beh = new();
    iter = new(v);
    
    iter.first();
    while(!iter.at_end()) begin
      accum = beh.reduce(iter.get(), accum);
      iter.next();
    end

    return accum;

  endfunction
  
endclass

