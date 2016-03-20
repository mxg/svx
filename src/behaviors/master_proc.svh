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
// Master Process
//
// In order to manage the concurreny we need to control the parent/child
// relationshipsd of the processes.  We do this by ensuring that all
// processes (well, all processes launched by SVX process objects) are
// hosted under a single parent.  This parent is known as the master
// process.  It's a teeny tiny executive that launches processes and
// tracks them in a list.
//
// The master process is in a class derived from process_behavior.  So
// we can use the usual process_behavior mechanisms for launching and
// controlling the master process itself.
//
// Generally, users should not operate the master process explicitly.
// The master process is a singleton and will be automatically launched
// the first time new() is called.  That is the first time someone
// retrieves a handle to the master process.  Users can call reboot() if
// there is a need to restart the master process.
// ----------------------------------------------------------------------

//----------------------------------------------------------------------
// class: master_control
//
// Data context for the master process
//----------------------------------------------------------------------
class master_control;

  // The master process has its own PID
  pid_t pid;

  // Map of processes to PIDs
  map#(process_base, pid_t, int_traits) active_processes;

  // Deque of available PIDs.
  intus_deque available;

  // initialize a new master control context
  function new();
    available = new();
    active_processes = new();
    pid = 0;
  endfunction

  // increment the pid
  function pid_t incr_pid();
    pid++;
    return pid;
  endfunction

  // get_new_pid
  //
  // Return a new pid.  If one is availble in the list of available pids
  // then use that.  Otherwise, increment the high-water pid and return
  // that as a new pid.
  function pid_t get_new_pid();

    pid_t pid;
    
    if(available.size() > 0)
      pid = available.pop_front();
    else
      pid = incr_pid();

    return pid;
    
  endfunction
  

  // show_available
  //
  // Show pids on the available list

  function void show_available();

    list_fwd_intus_iterator iter = new(available);

    if(!iter.first()) begin
      $display("none available");
      return;
    end
    $write("available :");
    while(!iter.at_end()) begin
      $write("%4d", iter.get());
      iter.next();
    end
    $display();

  endfunction

  // show_active
  //
  // Show list of currently active pids

  function void show_active();

    process_base p;
    map_fwd_iterator#(process_base, pid_t, int_traits) iter = new(active_processes);

    $write("active :");
    iter.first();
    while(!iter.at_end()) begin
      p = iter.get_index();
      $write("%4d", p.get_pid());
      iter.next();
    end
    $display();

  endfunction

endclass

//----------------------------------------------------------------------
// class: master_process
//
// This class is the master executive for processes.  It manages all the
// processes created using the process model classes.  It is a singleton,
// there is only one master process.
//----------------------------------------------------------------------
class master_process extends process_behavior #(master_control);

  static local  master_process mp;
  //local mailbox#(process_base) process_queue;
  local semaphore sm;
  local queue#(process_base, class_traits#(process_base)) process_queue;
  local master_control master_context;

  //--------------------------------------------------------------------
  // We protect the constructor because master_process is a singleton
  //--------------------------------------------------------------------
  protected function new();
    process_queue = new();
    sm = new();
    bootup();
  endfunction

  //--------------------------------------------------------------------
  // Clear everything out and restart the master process
  //--------------------------------------------------------------------
  function void reboot();
    mp.kill();
    bootup();
  endfunction

  //--------------------------------------------------------------------
  // Retrieve the singleton instances of master_process.
  //--------------------------------------------------------------------
  static function master_process get_master_process();
    if(mp == null)
      mp = new();
    return mp;
  endfunction

  //--------------------------------------------------------------------
  // launch
  //
  // Launch a new process by putting it in the process queue.  The
  // master process will pull it from the queue and launch it.
  // --------------------------------------------------------------------
  function void launch(process_base b);
    sm.put(1);
    process_queue.put(b);
  endfunction

  //--------------------------------------------------------------------
  // bootup
  //
  // Create all the structures needed by the master process and start up
  // the master proess (i.e. the run task).  This function is run only
  // once when the singleton object is first created.
  //--------------------------------------------------------------------
  local function void bootup();

    process_base p;
    process ph;
    
    // clear out the input queue
    process_queue.clear();

    // clear semaphore
    while(sm.try_get(1) != 0);

    master_context = new();  // new master_control
    set_pid(master_context.incr_pid());
    fork
      begin
	ph = process::self;
        set_process_handle(ph);
        tsk();
      end
    join_none

  endfunction

  //--------------------------------------------------------------------
  // tsk
  //
  // This is THE master process.  It pulls process objects from the
  // input queue and starts them running. This process is the parent of
  // all other processes.
  //--------------------------------------------------------------------    
  task tsk();

    process_base proc;

    forever begin

      // Retrieve the next behavior from the input queue that is ready
      // to be launched.  Get() blocks when there are no behaviors in
      // the queue.
      sm.get(1);
      proc = process_queue.get();
      if(proc == null) begin
	$display("uh oh... something has gone terribly wrong");
	continue;
      end
          
      fork
	
        begin

	  // task preamble.
          // Run the task.  First, get a pid.  If there is one available
          // on the available list then snag that.  Otherwise, increment
          // the pid high-water mark and use that as the new pid.

          automatic process_base p = proc;
          p.set_process_handle(process::self());
          p.set_pid(master_context.get_new_pid());
          master_context.active_processes.insert(p, p.get_pid());

	  // execute task
          p.exec();

	  // task postamble.
	  // Remove the process from the active list and put the pid on
	  // the available list.
          master_context.active_processes.delete(p);
          master_context.available.push_back(p.get_pid());
        end

      join_none

      #0;  // let the process start before we get another one

    end // forever

    // The process should run forever, we should never get here.
    $display("FATAL: master process has terminated");
    $finish;
    
  endtask

  function void show_active();
    master_context.show_active();
  endfunction


endclass
