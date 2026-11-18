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
// trivial_seq
//
// This sequence is expected to NOT be bound to a sequencer when it is
// launched, making it a virtual sequence.  As such it is responsible
// for obtaining sequencer handles to launch sequence items.  We use
// a data structure called a sequencer aggregator to locate the
// sequencer handles.  The sequencer aggregator is available in the
// resource database.
//----------------------------------------------------------------------
class trivial_seq extends uvm_sequence#(mem_txn);

  localparam string MSG_ID = "TRIVIAL_SEQ/PRE_START";

  typedef class_traits#(uvm_sequencer_base) sequencer_traits;
  typedef deque#(uvm_sequencer_base, sequencer_traits) deque_t;  

  local uvm_sequencer_base cfg_sqr;
  local deque_t mem_sqrs;
  local agreement ok_to_shutdown;
  local sqr_aggregator sqrs;
  local bit errors;
  
  function new(string name);
    super.new(name);
  endfunction

  //--------------------------------------------------------------------
  // pre_start
  //
  // Locate the agreement and sequencer aggregator in the resource
  // database.  Locate the sequencer handles in the sequencer
  // aggregator.
  //--------------------------------------------------------------------
  task pre_start();
    // Locate the agreement
    if(!uvm_resource_db#(agreement)::read_by_name(get_full_name(),
						  "ok_to_shutdown",
						  ok_to_shutdown, this)) begin
      `uvm_error(MSG_ID, "Unable to locate agreement.")
      errors = 1;
    end

    // Locate the sequencer aggregator
    if(!uvm_resource_db#(sqr_aggregator)::read_by_name(get_full_name(),
						       "sqrs", sqrs, this)) begin
      `uvm_error(MSG_ID, "Unable to locate sequencer aggregator.")
      errors = 1;
      return;  // cannot proceed if read_by_name() fails.
    end

    // Locate the sequencers in the sequencer aggregator
    cfg_sqr = sqrs.lookup_name("cfg");
    if(cfg_sqr == null) begin
      `uvm_error(MSG_ID,
		 "No cfg sequencer in the sequencer aggregator")
      errors = 1;
    end
    
    mem_sqrs = sqrs.lookup_kind("mem");
    if(mem_sqrs == null || mem_sqrs.size() == 0) begin
      `uvm_error(MSG_ID,
		 "No mem sequencers in the sequencer aggregator")
      errors = 1;
    end
    
  endtask

  //--------------------------------------------------------------------
  // body
  //
  // Send transactions to the driver via the sequencer handles.
  //--------------------------------------------------------------------
  task body();

    cfg_txn cfg;
    mem_txn mem;
    mem_txn mem_rsp;

    // No need to print a message, error messages have already been
    // printed (above).
    if(errors)
      return;

    ok_to_shutdown.disagree(this);

    // Configure the memory device. 
    cfg = new();
    cfg.txn_type = cfg_txn::CFG_ACTIVATE_ALL_RW;
    start_item(cfg, -1, cfg_sqr);
    finish_item(cfg);

    // Launch a bunch of write transactions.
    for(uint32_t idx = 0; idx < 100; idx++) begin
      index_t channel = index_t'($urandom_range(3,0));
      mem = new();
      mem.txn_type = mem_txn::MEM_WRITE;
      //  Generate a randomized address; ensure it is word-aligned.
      mem.addr = ($urandom_range(32'hffffff00, 32'hfffff000)) & 32'hfffffffc;
      mem.data = $urandom();
      start_item(mem, -1, mem_sqrs.read(channel));
      finish_item(mem);
      get_response(mem_rsp);
    end
    ok_to_shutdown.agree(this);
    
  endtask

endclass
