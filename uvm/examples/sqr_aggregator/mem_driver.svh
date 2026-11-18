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
// mem_driver
//----------------------------------------------------------------------
class mem_driver extends uvm_component;

  uvm_seq_item_pull_port #(mem_txn) seq_item_port;

  local uint32_t mem_idx;
  local string vif_name;
  local virtual mem_channel_if vif;
  local agreement ok_to_shutdown;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    string strnum;
    
    seq_item_port = new("seq_item_port", this);

    // Locate the index of the memory interface.
    if(!uvm_resource_db#(uint32_t)::read_by_name(get_full_name(),
						 "mem_idx", mem_idx, this)) begin
      `uvm_error("MEM/BUILD", "Missing memory interface index")
      return;
    end

    // Locate the virtual interface.
    strnum.itoa(mem_idx);
    vif_name = {"mem_if_", strnum};
    if(!uvm_resource_db#(virtual mem_channel_if)::read_by_name(get_full_name(), 
							   vif_name, vif, this)) begin
      `uvm_error("MEM/BUILD", {"Missing virtual interface for ", vif_name})
      return;
    end

    // Locate the agreement
    if(!uvm_resource_db#(agreement)::read_by_name(get_full_name(),
					      "ok_to_shutdown",
					      ok_to_shutdown, this)) begin
      `uvm_error("MEM/BUILD", "Unable to locate agreement.")
    end

  endfunction


  task run_phase(uvm_phase phase);

    mem_txn txn;

    forever begin
      seq_item_port.get_next_item(txn);

      ok_to_shutdown.disagree(this);
      vif.en <= 1;

      case(txn.txn_type)
	mem_txn::MEM_READ:
	  begin
	    vif.rw <= 0;
	    vif.addr <= txn.addr;
	    @(posedge vif.clk);
	    txn.data = vif.data_out;
	  end
	
	mem_txn::MEM_WRITE:
	  begin
	    vif.rw <= 1;
	    vif.addr <= txn.addr;
	    vif.data_in <= txn.data;
	    @(posedge vif.clk);
	  end
      endcase

      vif.en <= 0;
      @(negedge vif.clk);
      seq_item_port.item_done(txn);
      ok_to_shutdown.agree(this);

    end
    
  endtask
  
endclass
