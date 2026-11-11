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
// pipe_stage
//
// Base class for all stages except the first stage. The run_phase()
// task spawns two processes.  One, enqueue_items pulls upstream items
// through the seq_item_port and puts them into a fifo.  It
// essentially makes the stage look like a driver.  The other,
// dequeue_items, takes items from the fifo and processes them.
// Processing can include any computation.  If the stage is not the
// last stage then process_items must send the item downstream by
// calling sqr.execute_item().
//----------------------------------------------------------------------
class pipe_stage#(type SEQ = uvm_sequence_item)
  extends pipe_stage_base #(SEQ);

  uvm_seq_item_pull_port #(SEQ) seq_item_port;
  uvm_tlm_fifo#(SEQ) fifo;
  local int32_t fifo_size;

  // constructor
  //
  // The internal fifo is unbounded if size == 0.
  function new(string name, uvm_component parent, int32_t size = 0);
    super.new(name, parent);
    fifo_size = size;
  endfunction

  //--------------------------------------------------------------------
  // build_phase
  //--------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq_item_port = new("seq_item_port", this);
    fifo = new("fifo", this, fifo_size);
  endfunction

  //--------------------------------------------------------------------
  // run_phase
  //
  // Launch the two processes that drive the stage's activities.
  //--------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    fork
      enqueue_items();
      dequeue_items();
    join
  endtask

  //--------------------------------------------------------------------
  // enqueue_items
  //
  // Pull items from upstream and put them into the fifo.
  //--------------------------------------------------------------------
  task enqueue_items();
    SEQ item;
    forever begin
      seq_item_port.get_next_item(item);
      pipeline_done.disagree(this);
      fifo.put(item);
      seq_item_port.item_done();
    end
  endtask

  //--------------------------------------------------------------------
  // is_idle
  //
  // Is the device idle?  You can override this functioh to supply
  // your own stage-specific criteria for determining idleness.
  // --------------------------------------------------------------------
  virtual function bit is_idle();
    return (fifo.used() == 0);
  endfunction

  //--------------------------------------------------------------------
  // dequeue_items
  //
  // Take items from the fifo and call process_item.  Process_item()
  // is a virtual function that can perform anu desired computation
  // with the sequence item.  If this stage is not the last one then
  // it must call sqwr.execute_item() to send it downstream.
  // --------------------------------------------------------------------
  task dequeue_items();
    SEQ item;
    forever begin
      fifo.get(item);
      process_item(item);
      // Are we done?
      if(is_idle())
	pipeline_done.agree(this);
    end
  endtask

  function void report_phase(uvm_phase phase);
    $display("%s: fifo has %0d entries", get_name(), fifo.used());
  endfunction

endclass
