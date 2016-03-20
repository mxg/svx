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
// Concurrency
//
// Processes can naturally run concurrently.  The nature of a process is
// that it can be launched independently of other processes.  The
// facilities in this file are based on process groups -- groups of
// processes that can be started, suspended, resumed, or killed
// simultaneously.
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// class: process_group
//
// Manage a group of processes that are operating concurrently.  A set
// of processes are maintained as a list.
//----------------------------------------------------------------------
class process_group extends process_base;

  protected deque#(process_base, process_traits) processes;
  typedef list_fwd_iterator#(process_base, process_traits) iterator_t;

  function new();
    processes = new();
  endfunction

  //--------------------------------------------------------------------
  // function: add_process
  //
  // Add a process to the process group
  //--------------------------------------------------------------------
  function void add_process(process_base p);
    processes.push_back(p);
  endfunction

  //--------------------------------------------------------------------
  // task: exec
  //
  // Start all the processes in the group running.
  //--------------------------------------------------------------------
  virtual task exec();

    iterator_t iter = new(processes);

    if(!iter.first())
      return;
    
    do begin
      process_base p = iter.get();
      p.start();
      #0;
      iter.next();
    end    
    while(!iter.at_end());

  endtask

  //--------------------------------------------------------------------
  // function: suspend
  //
  // Suspend all the processes in the group
  //--------------------------------------------------------------------
  virtual function void suspend();

    iterator_t iter = new(processes);

    if(!iter.first())
      return;
    
    do begin
      process_base p = iter.get();
      p.suspend();
      iter.next();
    end
    while(!iter.at_end());

  endfunction

  //--------------------------------------------------------------------
  // function: resume
  //
  // Resume all the processes in the group
  //--------------------------------------------------------------------
  virtual function void resume();

    iterator_t iter = new(processes);

    if(!iter.first())
      return;

    do begin
      process_base p = iter.get();
      p.resume();
      iter.next();
    end
    while(!iter.at_end());

  endfunction

  //--------------------------------------------------------------------
  // function: kill
  // 
  // Kill all the processes in the group
  //--------------------------------------------------------------------
  virtual function void kill();

    iterator_t iter = new(processes);

    if(!iter.first())
      return;

    do begin
      process_base p = iter.get();
      p.kill();
      iter.next();
    end
    while(!iter.at_end());

  endfunction

  //--------------------------------------------------------------------
  // task: await
  //
  // Wait for all the processes in the group to complete.
  //--------------------------------------------------------------------
  task await();

    iterator_t iter = new(processes);

    if(!iter.first())
      return;

    do begin
      process_base p = iter.get();
      p.await();
      iter.next();
    end
    while(!iter.at_end());

  endtask

  //--------------------------------------------------------------------
  // function: is_done
  //
  // Return one if all processes are done, otherwise return zero.
  //--------------------------------------------------------------------
  function bit is_done();

    process_base p;
    iterator_t iter = new(processes);
    bit done = 1;

    // If there are no processes, then they are all done!
    if(!iter.first())
      return 1;

    do begin
      p = iter.get();
      done &= p.is_done();
      iter.next();
    end
    while(!iter.at_end());

    return done;

  endfunction

endclass

//----------------------------------------------------------------------
// class: timer
//
// A simple timer processes.  It terminates when the delay has expired.
//----------------------------------------------------------------------
class timer extends process_base;

  time delay;

  function new(time t = 0);
    delay = t;
  endfunction

  task tsk();
    #delay;
  endtask

endclass

//----------------------------------------------------------------------
// class: process_group_timeout
//
// This class IS-A process group with the additional semantic of a timer
// process.  All of the processes shut down when the first process
// terminates.  The timer processes ensures that no process will run
// longer than the specified time.  That is, if the timer process is the
// first to terminate then the max time has expired and all the other
// processes in the group are shut down.
// ----------------------------------------------------------------------
class process_group_timeout extends process_group;

  timer timer_proc;

  function new(time t = 0);
    super.new();
    timer_proc = new(t);
    add_process(timer_proc);
  endfunction

  task exec();

    super.exec();

    // This little process, which does not run under the master process,
    // will kill all the processes in the group when the tiner expires. 
    await();
    kill();
    $display("%6t: timeout", $time);

  endtask

endclass
