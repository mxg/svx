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
// Copyright 2024-2026 Mark Glasser
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
//
// Top-level environment
//----------------------------------------------------------------------
class env extends uvm_component;

  stage_1 s1;
  stage_2 s2;
  stage_3 s3;
  agreement pipeline_done;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //--------------------------------------------------------------------
  // build_phase
  //--------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    s1 = new("stage_1", this);
    s2 = new("stage_2", this);
    s3 = new("stage_3", this);
    pipeline_done = new("pipeline_done");
    uvm_resource_db#(agreement)::set("*", "pipeline_done", 
				     pipeline_done, this);
  endfunction

  //--------------------------------------------------------------------
  // connect_phase
  //--------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    s2.seq_item_port.connect(s1.seq_item_export);
    s3.seq_item_port.connect(s2.seq_item_export);
  endfunction

  //--------------------------------------------------------------------
  // run_phase
  //
  // Each stage has its own done flag.  The simulation is complete
  // when all the done flags are set, meaning there are no more
  // sequence items in flight.
  //--------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #0;
    pipeline_done.wait_for_agreement(this);
    phase.drop_objection(this);
  endtask

endclass
