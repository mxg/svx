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
// Processes
//
// The process object provides process semantics for behaviors.
// Processes are launched as separate threads which run concurrently.
// Processes can be started, suspended, resumed, and killed.  SVX
// processes use SystemVerilog processes and process handles.
//
// A process must be bound to a behavior.  The behavior can be a fcn or
// a task behavior, althought task behaviors make more sense as
// processes.
//
// To create a process declare a process_behavior object using the
// parameter to specify the type of the context object.  Then you bind
// both the behavior and the context object to the process_behavior.
// The context will be bound to the behavior before the process is
// launched.
// ----------------------------------------------------------------------

// forward declaration
typedef class master_process;

//----------------------------------------------------------------------
// class: process_if
//
// Interface for process control. This mimics the interface for the
// built-in process class.
//----------------------------------------------------------------------
interface class process_if;

  pure virtual function void suspend();
  pure virtual function void resume();
  pure virtual function void kill();
  pure virtual function bit is_done();
  pure virtual task await();
    
endclass

//----------------------------------------------------------------------
// class: process_base
//
// Non-parameterized base class for processes
//----------------------------------------------------------------------
class process_base
  implements process_if, behavior_if;

  local process process_handle;
  local pid_t pid;
  local generic_behavior beh;

  //--------------------------------------------------------------------
  // process handle management methods
  //--------------------------------------------------------------------

  function process get_process_handle();
    return process_handle;
  endfunction

  function void set_process_handle(process ph);
    process_handle = ph;
  endfunction

  // This should only be used by the master process and not by users
  function void set_pid(pid_t p);
    pid = p;
  endfunction

  function pid_t get_pid();
    return pid;
  endfunction

  // set_generic_behavior
  //
  // Bind a behavior to a process
  protected function void set_generic_behavior(generic_behavior b);
    beh = b;
  endfunction

  //--------------------------------------------------------------------
  // behavior_if methods
  //
  // Delegate to the bound behavior
  //--------------------------------------------------------------------

  virtual task exec();
    beh.exec();
  endtask

  virtual function void nb_exec();
    beh.nb_exec();
  endfunction
  
  //--------------------------------------------------------------------
  // process_if methods
  //--------------------------------------------------------------------
  
  virtual function void start();
    master_process mp = master_process::get_master_process();
    mp.launch(this);
  endfunction

  virtual function void suspend();
    if(process_handle != null)
      process_handle.suspend();
  endfunction

  virtual function void resume();
    if(process_handle != null)
      process_handle.resume();
  endfunction

  virtual function void kill();
    if(process_handle == null)
      return;
    process_handle.kill();
    process_handle = null;
  endfunction

  virtual function bit is_done();
    return(process_handle.status() == process::KILLED ||
           process_handle.status() == process::FINISHED);
  endfunction

  virtual task await();
    #0;
    wait(pid != 0);
    if(process_handle != null) begin
      if(!is_done())
	 process_handle.await();
    end
  endtask

endclass

//----------------------------------------------------------------------
// class: process_behavior
//
// Process behavior parameterized with the context type.  Contains a
// handle to a generic_behavior.
//----------------------------------------------------------------------
class process_behavior #(type T=int)
  extends process_base;

  typedef generic_context_behavior#(T) behavior_t;
  local behavior_t behavior;

  // constructor
  //
  // Optionally bind a behavior to the process_behacior object.
  function new(behavior_t b = null);
    set_behavior(b);
  endfunction

  // set_behavior
  //
  // Bind a behavior to the process_behaior 
  virtual function void set_behavior(behavior_t b);
    behavior = b;
    set_generic_behavior(b);
  endfunction

  // bind_context
  //
  // Bind the context object to the underlying behavior.
  virtual function void bind_context(T cntxt);
    behavior.bind_context(cntxt);
  endfunction

  // apply
  //
  // Bind the context to the behavior and launch the process.
  virtual task apply(T cntxt);
    bind_context(cntxt);
    start();
  endtask

  // get_context
  //
  // Retrieve the context object from the behavior.
  virtual function T get_context();
    return behavior.get_context();
  endfunction

endclass

//----------------------------------------------------------------------
// process_traits
//
// A traits class or process objects.  This makes it easy to create data
// structures -- vectors, maps, etc. -- that contain processes.
// ----------------------------------------------------------------------
class process_traits extends void_t;

  typedef process_base empty_t;
  const static empty_t empty = null;

  static function bit equal(input process_base a,
			    input process_base b);
    return (a == b);
  endfunction

  static function int compare(input process_base a,
			      input process_base b);
    return !equal(a,b);
  endfunction

  static function void sort(process_base vec[$]);
  endfunction

endclass
