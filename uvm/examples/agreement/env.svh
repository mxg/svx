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
//
// Each component is assigned a different delay.  The simulation will
// terminate when the longest dela has expired.
// ----------------------------------------------------------------------
class env extends uvm_component;

  component A;
  component B;
  component C;
  agreement ok_to_shutdown;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    A = new("A", this);
    B = new("B", this);
    C = new("C", this);
    A.delay = 10;
    B.delay = 49;
    C.delay = 30;
    ok_to_shutdown = new();

    // Put the new agreement into the resource database.
    uvm_resource_db#(agreement)::set("*", "ok_to_shutdown", 
				     ok_to_shutdown, this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // Let the processes start up before we wait for agreement.
    #0;
    ok_to_shutdown.wait_for_agreement(this);
    $display("%10t: Agreement has been reached.", $time);
    phase.drop_objection(this);
  endtask

endclass


  
  
