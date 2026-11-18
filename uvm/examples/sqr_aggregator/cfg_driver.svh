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
// cfg_driver
//----------------------------------------------------------------------
class cfg_driver extends uvm_component;

  uvm_seq_item_pull_port #(cfg_txn) seq_item_port;

  local virtual configure_if vif;
  local agreement ok_to_shutdown;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);

    seq_item_port = new("seq_item_port", this);

    // Locate the virtual interface.
    if(!uvm_resource_db#(virtual configure_if)::read_by_name(get_full_name(), 
							   "cfg_if", vif, this)) begin
      `uvm_error("CFG/BUILD", "Missing virtual interface for cfg_if")
      return;
    end

    // Locate the agreement
    if(!uvm_resource_db#(agreement)::read_by_name(get_full_name(),
					      "ok_to_shutdown",
					      ok_to_shutdown, this)) begin
      `uvm_error("CFG/BUILD", "Unable to locate agreement.")
    end
    
  endfunction

  task run_phase(uvm_phase phase);

    cfg_txn txn;
    logic [3:0] act = 4'b0000;
    logic [3:0]	ro = 4'b0000;
    bit	has_been_reset;

    // Wait until the device is out of reset before proceeding.
    if(!has_been_reset) begin
      @(negedge vif.rst_n);
      @(posedge vif.rst_n);
      has_been_reset = 1;
    end
    
    // Put known values on the pins to start things out.
    vif.cb.activate  <= act;
    vif.cb.read_only <= ro;
    vif.cb.configure <= 1'b0;   

    forever begin
      seq_item_port.get_next_item(txn);
      ok_to_shutdown.disagree(this);

      if(txn.channel > 3) begin
	`uvm_warning("CFG/RUN", $sformatf("Illegal channel %0d", txn.channel))
	ok_to_shutdown.agree(this);
	seq_item_port.item_done();
	continue;
      end

      $display("cfg: %s @ %0d", txn.txn_type.name(), txn.channel);

      // Save the current values as temporaries.
      act = vif.activate;
      ro  = vif.read_only;

      // Update the temporaries based on the command from the
      // transaction object.
      case(txn.txn_type)
	cfg_txn::CFG_ACTIVATE_RW:
	  begin
	    act[txn.channel] = 1'b1;
	    ro[txn.channel] = 1'b0;
	  end
	
	cfg_txn::CFG_ACTIVATE_RO:
	  begin
	    act[txn.channel] = 1;
	    ro[txn.channel] = 1'b1;
	  end
	
	cfg_txn::CFG_DEACTIVATE:
	  begin
	    act[txn.channel] = 1'b0;
	  end

	cfg_txn::CFG_ACTIVATE_ALL_RW:
	  begin
	    act = 4'b1111;
	    ro = 4'b0000;
	  end
	
	cfg_txn::CFG_ACTIVATE_ALL_RO:
	  begin
	    act = 4'b1111;
	    ro = 4'b1111;
	  end
	
	cfg_txn::CFG_DEACTIVATE_ALL:
	  begin
	    act = 4'b0000;
	  end

      endcase

      // Post the temporaries to the real signals based on the timing
      // in the clocking block.
      @(vif.cb);
      vif.cb.activate  <= act;
      vif.cb.read_only <= ro;
      vif.cb.configure <= 1'b1;
      @(vif.cb);
      vif.cb.configure <= 1'b0;      
      
      seq_item_port.item_done();
      ok_to_shutdown.agree(this);
    end
    
  endtask

endclass
