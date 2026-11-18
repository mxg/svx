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
// sqr_aggregator
//----------------------------------------------------------------------
class sqr_aggregator;

  typedef class_traits#(uvm_sequencer_base) sequencer_traits;
  typedef uvm_sequencer_base sqr_q_t[$];
  typedef deque#(uvm_sequencer_base, sequencer_traits) deque_t;
  typedef map_iterator#(string, uvm_sequencer_base, sequencer_traits) map_iterator_t;

  local map#(string, uvm_sequencer_base, sequencer_traits) sqr_table;
  local map#(string, uvm_sequencer_base, sequencer_traits) name_table;
  local map#(string, deque_t, class_traits#(deque_t)) kind_table;

  function new();
    sqr_table = new();
    name_table = new();
    kind_table = new();
  endfunction

  //--------------------------------------------------------------------
  // add
  //
  // Add a new sequencer to the aggregator.
  //--------------------------------------------------------------------
  function void add(uvm_sequencer_base sqr, string name, string kind);
    deque_t q;
    string path;

    if(sqr == null) begin
      `uvm_error("SVX/SQR_AGGR",
		 "Attempt to put a null sequencer into the sequencer aggregator.")
      return;
    end
	
    path = sqr.get_full_name();
    void'(sqr_table.insert(path, sqr));

    if(kind != "") begin
      if(kind_table.exists(kind))
	q = kind_table.get(kind);
      else begin
	q = new();
	void'(kind_table.insert(kind, q));
      end
      q.push_back(sqr);
    end

    if(name != "") begin
      if(name_table.exists(name))
	`uvm_info("SQR_AGGREGATOR",
		  $sformatf("replacing sequencer with name %s", name),
		  UVM_NONE)
      void'(name_table.insert(name, sqr));
    end
    
  endfunction

  //--------------------------------------------------------------------
  // lookup_path
  //
  // Lookup a sequencer by full path
  //--------------------------------------------------------------------
  function uvm_sequencer_base lookup_path(string path);
    return sqr_table.get(path);
  endfunction

  //--------------------------------------------------------------------
  // Lookup a sequencer by name
  //--------------------------------------------------------------------
  function uvm_sequencer_base lookup_name(string name);
    return name_table.get(name);
  endfunction

  //--------------------------------------------------------------------
  // lookup_path_regex
  //
  // Lookup sequencers using a regular expression that matches path
  // names.
  //--------------------------------------------------------------------
  function deque_t lookup_path_regex(string regex);
    deque_t q = new();
    map_iterator_t iter = new(sqr_table);
    void'(iter.first());
    while(!iter.at_end()) begin
      string path = iter.get_index();
      if(uvm_re_match(regex, path) == 1)
	q.push_back(sqr_table.get(path));
    end
    return q;
  endfunction

  //--------------------------------------------------------------------
  // lookup_kind
  //
  // Return a queue of all sequencers that match 'kind'.
  //--------------------------------------------------------------------
  function deque_t lookup_kind(string kind);
    return kind_table.get(kind);
  endfunction

  //--------------------------------------------------------------------
  // Dump
  //
  // Let's see everything
  //--------------------------------------------------------------------
  function void dump();
    map_iterator_t iter;
    map_iterator#(string, deque_t, class_traits#(deque_t)) kind_iter;
    list_iterator#(uvm_sequencer_base, sequencer_traits) q_iter;
    
    $display("--- SEQUENCER AGGREGATOR ---");

    // Dump name table
    $display("  by name:");
    iter = new(name_table);
    void'(iter.first());
    while(!iter.at_end()) begin
      string name = iter.get_index();
      uvm_sequencer_base sqr = name_table.get(name);
      $display("    %s -> %s", name, sqr.get_full_name());
    end

    // Dump kind table
    $display("  by kind:");
    kind_iter = new(kind_table);
    void'(kind_iter.first());
    while(!kind_iter.at_end()) begin
      string kind = kind_iter.get_index();
      deque_t q = kind_table.get(kind);
      $display("    %s", kind);
      q_iter = new(q);
      void'(q_iter.first());
      while(!q_iter.at_end()) begin
	uvm_sequencer_base sqr = q_iter.get();
	$display("      %s", sqr.get_full_name());
      end
    end

    // Dump sequencer table
    $display("  by path:");
    iter = new(sqr_table);
    void'(iter.first());
    while(!iter.at_end()) begin
      string path = iter.get_index();
      $display("    %s", path);
    end

  endfunction

endclass


