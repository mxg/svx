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
//----------------------------------------------------------------------
class env extends uvm_component;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);

    uint32_t number = 382;

    // Put a new resource into the resource database
    uvm_resource_db#(uint32_t)::set("*", "number", number, this);

  endfunction

  //--------------------------------------------------------------------
  // connect_phase
  //--------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);

    uint32_t number;
    uint32_t new_number;
    uint32_t old_number;
    cached_resource#(uint32_t) cr = new(get_full_name(), "number");

    // Retrieve the resource and cache it.
    if(!cr.read(number, this))
      `uvm_error("CR/ENV", "Resource is not available")

    if(number != 382)
      `uvm_error("CR/ENV", "Uh oh, the resource value does not match")

    // Now, let's put a new value in the resource database.
    new_number = 67;
    uvm_resource_db#(uint32_t)::set_override("*", "number", new_number, this);

    // Retrieve the value from the cached resource.
    if(!cr.read(old_number, this))
      `uvm_error("CR/ENV", "Resource is not available")    

    // The number in the cached resource should reflect the old value,
    // not the new one.
    if(old_number == 67)
      `uvm_error("CR/ENV", "We didn't get the cached value.")

    // Update the cache.
    if(!cr.get_the_latest(old_number, this))
      `uvm_error("CR/ENV", "Resource is not available")    

    if(old_number != 67)
      `uvm_error("CR/ENV", "The cache was not updated");
      
  endfunction

  //--------------------------------------------------------------------
  // run_phase
  //--------------------------------------------------------------------
  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    fork
      first_process();
      second_process();
    join_any

    phase.drop_objection(this);
    
  endtask

  //--------------------------------------------------------------------
  // first_process
  //--------------------------------------------------------------------
  task first_process();
    cached_resource#(uint32_t) cr = new(get_full_name(), "number");
    
    #100ns;
    cr.write(265, this);
    #85ns;
    cr.write(92, this);
    #16ns;
    cr.write(866, this);
    #48ns;
    cr.write(1122, this);
    #0;
    cr.write(34, this);
    #0;
    cr.write(942, this);

  endtask

  //--------------------------------------------------------------------
  // second_process
  //--------------------------------------------------------------------
  task second_process();
    uint32_t number;
    cached_resource#(uint32_t) cr = new(get_full_name(), "number");
    
    forever begin
      cr.wait_for_change();
      if(!cr.read(number, this))
	`uvm_error("CR/SECOND", "Error reading number.")
      $display("%10t: number changed to %0d", $time, number);
    end
    
  endtask

endclass

