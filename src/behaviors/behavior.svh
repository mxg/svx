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
// Behavior
//
// A behavior is an object that contains a task or a function.  These
// are akin to functors.  However, as SystemVerilog does not support
// operator overloading behaviors are not true functors.  Behaviors can
// be bound to contexts.  A context is a data object that supplies data
// for the behavior or is manipulated by the behavior.
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// behavior_if
//
// Primary interface for behaviors.  exec() launches the behavior as a
// blocking task and nb_exec() launches it as a non-blocking function.
//----------------------------------------------------------------------
interface class behavior_if;
  pure virtual task exec();
  pure virtual function void nb_exec();
endclass

//----------------------------------------------------------------------
// generic_behavior
//
// The generic_behavior class is an artifact that's necessary because
// SystemVerilog does not support multiple inheritance.  It can be used
// as a base handle for launching polymorphic behaviors.
//----------------------------------------------------------------------
virtual class generic_behavior
  implements behavior_if;

  virtual task exec();
    // empty function
  endtask

  virtual function void nb_exec();
    // empty function
  endfunction

endclass

//----------------------------------------------------------------------
// generic_context_behavior
//
// The generic_context_behavior is a parameterized class where the
// parameter is the type of the context object.  The methods in this
// class provide means for binding a context object to a behavior
//----------------------------------------------------------------------
virtual class generic_context_behavior#(type T=int)
  extends generic_behavior;

  protected T c;

  virtual task exec();
    // empty function
  endtask

   virtual function void nb_exec();
    // empty function
  endfunction

  // bind_context
  //
  // Bind a context object to the behavior
  virtual function void bind_context(T cntxt);
    c = cntxt;
  endfunction

  // apply
  //
  // Bind a context object to the behavior and launch the behavior as a
  // blocking task.
  virtual task apply(T cntxt);
    bind_context(cntxt);
    exec();
  endtask

  // nb_apply
  //
  // Bind a context object to the behavior and launch the behavcior as a
  // non-blocking function.
  virtual function void nb_apply(T cntxt);
    bind_context(cntxt);
    nb_exec();
  endfunction

  // get_context
  //
  // Retrieve the context object.
  virtual function T get_context();
    return c;
  endfunction
    
endclass

//----------------------------------------------------------------------
// fcn_behavior
//
// A fcn_behavior is a behavior specialized for functions. Both exec and
// nb_exec are implemented.  Of course, exec will not consume any time
// even through it's technically a blocking task.  To create a
// fcn_behavior derive an object from this class an implement fcn().
// There is no need to re-implement exec and nb_exec().
//
// fcn() returns a bit indicating zuccess or failure -- one for success,
// zero for failure.  The notion of what constitutes success and failure
// is entirely user defined.
//----------------------------------------------------------------------
class fcn_behavior #(type T=int) extends generic_context_behavior#(T);

  virtual function bit fcn();
    $display("Doh! Someone forgot to implement fcn in fcn_behavior_base");
    return 0;
  endfunction

  virtual task exec();
    void'(fcn());
  endtask

  virtual function void nb_exec();
    void'(fcn());
  endfunction

endclass

//----------------------------------------------------------------------
// reduce_behavior
//
// A reduce behavior is a behavior that is used in map/reduce
// operations.  The reduce behavior takes two parameters -- one for the
// type of the context (T) , and one for the type of the return value of
// the function (R).  Reduce behaviors are always functions.  Task
// behaviors are not supported for map/reduce operations.
//----------------------------------------------------------------------
class reduce_behavior#(type T=int,
                       type R=T)
  extends generic_context_behavior#(T);

  virtual function R reduce(T t, R accum);
    $display("Doh! Someone forgot to implement reduce() in reduce_behavior");
  endfunction

endclass

//----------------------------------------------------------------------
// task_behavior
//
// A task behavior is a generic behavior specialized for blocking tasks.
// Task behaviors can be run in either blocking or non-blocking mode.
// In non-blocking mode the task is invoked using a fork/join_none
// construct to allow it to operate "in the background."  It still may
// consume time.
//
// To create a task_behavior derive a class from this one and provide an
// implementation of tsk().  There is no need to provide implementations
// for the other functions. (i.e. don't touch!).
//
// Some additional facilities are available for tasks launched using
// nb_exec().  The task wait_until_done() will block until the launched
// process terminates.  Also, you can optionally implement
// termination_hook() which is a function that will run when the task
// tsk() completes.
//----------------------------------------------------------------------
class task_behavior #(type T=int) extends generic_context_behavior#(T);

  local process proc;

  // tsk
  //
  // User defined task that provides the behavior
  virtual task tsk();
    $error("Doh! Someone forgot to implement tsk in task_behavior");
  endtask

  // exec
  //
  // Launch the task in blocking mode
  virtual task exec();
    tsk();
  endtask

  // nb_exec
  //
  // Launch the behavior as a non-blocking function.  The task is called
  // using fork/join_none.  The process will continue after the function
  // returns.
  virtual function void nb_exec();
    fork
      begin
        proc = process::self();
        tsk();
      end
      begin
	// Wait until the process completes and then run the
	// termination_hook.
        #0;
        proc.await();
        termination_hook();
      end
    join_none
  endfunction

  // wait_until_done
  //
  // Block until a process launched by nb_exec() terminates.
  virtual task wait_until_done();
    #0;
    proc.await();
  endtask

  // termination_hook
  //
  // Optionally, do something when a task launched by nb_exec()
  // terminates.  This could issue a notification, for example.
  virtual function void termination_hook();
  endfunction

endclass


