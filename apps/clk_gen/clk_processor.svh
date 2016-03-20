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
// clk_behavior
//
// This is the task that drives each clock pin.  Information on how to
// operate comes from the bound context object.  The variable that holds
// the context object is c.
//----------------------------------------------------------------------
class clk_behavior#(int unsigned N=1)
  extends task_behavior#(clk_descriptor#(N));

  task tsk();

    if(c == null) begin
      $display("no clk descriptor -- terminating clock behavior");
      return;
    end

    if(c.verbose)
      $display("clock %s", c.to_str());

    // wait for the start event
    wait(c.start_event.triggered);

    // If there's an initial delay then delay.  If not, don't expend a
    // delta cycle.
    if(c.initial_delay > 0)
      #c.initial_delay;

    if(c.verbose)
      $display("clock %s starting at %0t", c.name, $time);

    // Run the clock forever
    forever begin
      c.ckif.clk[c.clk_index] <= 0;
      if(c.verbose)
	$display("clock %s = 0 @ %0t", c.name, $time);
      #c.time_lo;
      c.ckif.clk[c.clk_index] <= 1;
      if(c.verbose)
	$display("clock %s = 1 @ %0t", c.name, $time);
      #c.time_hi;
    end
    
  endtask
  
endclass

//----------------------------------------------------------------------
// clk_processor
//
// Takes a vector of clock descriptors and creates a clock process for
// each.
// ----------------------------------------------------------------------
class clk_processor#(int unsigned N=1) implements process_if;
  
  typedef vector#(clk_descriptor#(N), class_traits#(clk_descriptor#(N))) clk_vec_t;
  typedef list_fwd_iterator#(clk_descriptor#(N), class_traits#(clk_descriptor#(N))) iter_t;
  
  clk_behavior#(N) beh;
  clk_vec_t clk_vector;
  process_group clk_procs;

  // Establish the vector of clock descriptors.  Also validate the clock
  // descriptors.  If all of the descriptors are valid them we save the
  // vector, otherwise not.
  function void set_vector(clk_vec_t v);
    clk_descriptor#(N) cd;
    bit ok = 1;
    iter_t iter = new(v);

    if(v == null)
      return;

    // Validate each of the clock descriptors
    iter.first();
    while(!iter.at_end()) begin
      cd = iter.get();
      ok &= cd.validate();
      iter.next();
    end

    if(!ok)
      return;

    // we're good. let's go...
    clk_vector = v;
  endfunction

  // print clock descriptors
  function void print_descriptors();

    clk_descriptor#(N) cd;
    iter_t iter = new(clk_vector);

    if(clk_vector == null)
      return;

    // Validate each of the clock descriptors
    iter.first();
    while(!iter.at_end()) begin
      cd = iter.get();
      $display("%s", cd.to_str());
      iter.next();
    end

    
  endfunction

  // Set up the clock processes and initiate their execution.
  virtual task exec();

    process_behavior#(clk_descriptor#(N)) proc;
    iter_t iter = new(clk_vector);

    // Make sure there are not clock processes already running
    kill();
      
    clk_procs = new();

    // Load up the process group with all the clock processes
    iter.first();
    while(!iter.at_end()) begin
      beh = new();
      proc = new(beh);
      proc.bind_context(iter.get());
      clk_procs.add_process(proc);
      iter.next();
    end

    clk_procs.exec();
    
  endtask

  // Delegate all the fine-grained process control functions to the
  // underlying process group.

  virtual function void suspend();
    clk_procs.suspend();
  endfunction

  virtual function void resume();
    if(clk_procs != null)
      clk_procs.resume();
  endfunction

  virtual function void kill();
    if(clk_procs != null)
      clk_procs.kill();
    clk_procs = null;
  endfunction
  
  virtual function bit is_done();
    if(clk_procs != null)
      clk_procs.is_done();
  endfunction

  virtual task await();
    if(clk_procs != null)
      clk_procs.await();
  endtask

endclass


