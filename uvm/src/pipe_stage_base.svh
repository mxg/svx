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
// pipe_stage_base
//
// Base class for all pipe stages.
//----------------------------------------------------------------------
class pipe_stage_base #(type SEQ = uvm_sequence_item)
  extends uvm_component;

  // Export for sending a sequence downstream
  uvm_seq_item_pull_export #(SEQ) seq_item_export;

  // Sequencer for sending a sequence downstream.  Note that it is
  // protected so that it cannot be reached from outside.
  protected uvm_sequencer#(SEQ) sqr;

  protected agreement pipeline_done;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    sqr = new("sequencer", this);
    seq_item_export = new("seq_item_export", this);
    if(!uvm_resource_db#(agreement)::read_by_name(get_name(), 
					      "pipeline_done", 
					      pipeline_done, this))
      `uvm_error("SVX/PIPELINE", "Agreement pipeline_done is not available")
  endfunction

  function void connect_phase(uvm_phase phase);
    seq_item_export.connect(sqr.seq_item_export);
  endfunction

  // Virtual function for performing some action with a sequence item.
  // A common use case is to send the transaction downstream through
  // the internal sequencer.
  virtual task process_item(SEQ item);
  endtask

endclass
