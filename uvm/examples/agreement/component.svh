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
// component
//----------------------------------------------------------------------
class component extends uvm_component;

  agreement ok_to_shutdown;
  uint32_t delay;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Retrieve the agreement from the resource database.  All
    // instances of component shares the same agreement instance.
    if(!uvm_resource_db#(agreement)::read_by_name(get_name(),
						  "ok_to_shutdown",
						  ok_to_shutdown, this)) begin
      `uvm_error("MISSING AGREEMENT",
		 "Cannot obtain agreement from the resource database.")
    end
  endfunction

  task run_phase(uvm_phase phase);
    ok_to_shutdown.disagree(this);
    #(delay);
    $display("%10t: %s", $time, get_name());
    ok_to_shutdown.agree(this);
    #100;
    $display("This message should never display!");
  endtask

endclass
