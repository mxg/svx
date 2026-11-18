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
// env
//----------------------------------------------------------------------
class env extends uvm_component;

  local mem_agent mem_agt[4];
  local cfg_agent cfg_agt;
  local agreement ok_to_shutdown;
  local sqr_aggregator sqrs;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //--------------------------------------------------------------------
  //  build_phase
  //--------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    ok_to_shutdown = new("ok_to_shutdown");

    // Create a new sequence aggregator and put it in the resource
    // database.
    sqrs = new();
    uvm_resource_db#(sqr_aggregator)::set("*", "sqrs", sqrs, this);
    
    cfg_agt = new("cfg_agent", this);

    // Instantiate all of the memory interfaces.  Also, put the unique
    // index for each one into the resource database.
    for(uint32_t idx = 0; idx < 4; idx++) begin
      string strnum;
      string name;
      strnum.itoa(idx);
      name = {"mem_agent_", strnum};
      mem_agt[idx] = new(name, this);
      uvm_resource_db#(uint32_t)::set({"*.", name, ".*"},
				      "mem_idx", idx, this);
    end

    // Put the agreement into the resource database
    uvm_resource_db#(agreement)::set("*", "ok_to_shutdown",
				     ok_to_shutdown, this);
    

  endfunction

  //--------------------------------------------------------------------
  // connect_phase
  //
  // Put the sequencers into the sequencer aggregator.
  //--------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    sqrs.add(cfg_agt.sqr, "cfg", "cfg");
    for(uint32_t idx = 0; idx < 4; idx++) begin
      string strnum;
      strnum.itoa(idx);
      sqrs.add(mem_agt[idx].sqr, {"mem_", strnum}, "mem");
    end
  endfunction

  //--------------------------------------------------------------------
  // run_phase
  //--------------------------------------------------------------------
  task run_phase(uvm_phase phase);

    $display("running...");
    phase.raise_objection(this);

    // Run the test with a timeout. One of the processes will finish
    // first -- either the work to be done or the timeout. If the work
    // hangs or is taking too long the timeout will finish first and
    // the work process will be killed.
    fork
      begin
	do_stuff();
      end
      
      begin
	#100000000;
	`uvm_error("ENV", "*** TIMEOUT!! ***");
      end
    join_any

    disable fork;

    phase.drop_objection(this);
    
  endtask

  //--------------------------------------------------------------------
  // do_stuff
  //
  // Do the interesting work.
  //--------------------------------------------------------------------
  task do_stuff();
    trivial_seq seq;
    
    seq = new("trivial_seq");
    #20ns;
    seq.start(null);
    
    ok_to_shutdown.wait_for_agreement(this);
    $display("%10t: shutting down", $time);
  endtask
  
endclass
